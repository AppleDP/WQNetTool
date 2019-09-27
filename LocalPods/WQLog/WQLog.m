//
//  WQLog.m
//  WQLog
//
//  Created by admin on 16/8/25.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import "WQLog.h"

@interface WQLog ()
/** 记录日志标识 */
@property (nonatomic, assign) BOOL isRecordLog;
/** 日志文件路径 */
@property (nonatomic, assign, nullable) NSString *logFile;
/** 文件流 */
@property (nonatomic, strong, nullable) NSOutputStream *stream;
/** 写文件线程 */
@property (nonatomic, nonnull) dispatch_queue_t writeQueue;
@end

@implementation WQLog
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    }
    return instance;
}

static WQLog *instance;
+ (instancetype)shareInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

- (void)dealloc {
    [self.stream close];
}

- (dispatch_queue_t)writeQueue {
    if (_writeQueue == nil) {
        _writeQueue = dispatch_queue_create("WQControl Log Queue", DISPATCH_QUEUE_SERIAL);
    }
    return _writeQueue;
}

- (NSString *)recordLogWithDir:(NSString *)dir {
    @synchronized (self.logFile) {
        if (self.isRecordLog) {
#ifdef DEBUG
            WQLogInf(@"已经开启日志记录");
#endif
            return self.logFile;
        }
        BOOL isDir = NO;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
        if (exist) {
            // 路径存在
            if (!isDir) {
                // 路径是文件
                WQLogErr(@"日志缓存路径为文件");
                return nil;
            }
        }else {
            // 路径不存在，创建路径
            NSError *error;
            BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
            if (error || !result) {
                WQLogErr(@"创建日志记录路径错误");
                return nil;
            }
        }
        self.isRecordLog = YES;
        NSDateFormatter *formatter = [[NSDateFormatter alloc ] init];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
        NSString *date = [formatter stringFromDate:[NSDate date]];
        NSString *path = [dir stringByAppendingFormat:@"/WQLog_%@.log",date];
        self.logFile = path;
        [self.stream close];
        self.stream = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
        [self.stream open];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 崩溃信息监听
            NSSetUncaughtExceptionHandler(&wq_uncaughtExceptionHandler);
        });
        return self.logFile;
    }
}

- (void)clearLogCachesWithDir:(NSString *)dir
                       delete:(NSArray<NSString *> * _Nullable (^)(NSArray<NSString *> * _Nullable logPaths))deleteBlock {
    @synchronized (self.logFile) {
        // 获取文件夹下所有文件
        NSError *error;
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm changeCurrentDirectoryPath:dir];
        NSArray<NSString *> *directory = [fm contentsOfDirectoryAtPath:dir error:&error];
        if (error) {
            WQLogErr(@"获取文件夹下日志文件出错: %@",error);
            deleteBlock(nil);
            return;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^WQLog_\\d{4}(\\-)\\d{1,2}\\1\\d{1,2} \\d{1,2}(:)\\d{1,2}\\2\\d{1,2}\\2\\d{1,3}.log$"];
        NSArray<NSString *> *logNames = [directory filteredArrayUsingPredicate:predicate];
        NSMutableArray<NSString *> *logPaths = [[NSMutableArray alloc] initWithCapacity:logNames.count];
        for (int index = 0; index < logNames.count; index ++) {
            NSString *logName = logNames[index];
            NSString *logPath = [dir stringByAppendingPathComponent:logName];
            [logPaths addObject:logPath];
        }
        NSArray<NSString *> *deletePaths = deleteBlock(logPaths);
        for (int index = 0; index < deletePaths.count; index ++) {
            NSString *deletePath = deletePaths[index];
            if ([logPaths containsObject:deletePath]) {
                // 返回文件路径在日志路径中
                if ([deletePath isEqualToString:self.logFile]) {
                    // 删除当前日志文件
                    if (self.isRecordLog) {
                        // 关闭数据流
                        self.isRecordLog = NO;
                        self.logFile = nil;
                        [self.stream close];
                    }
                }
                BOOL result = [fm removeItemAtPath:deletePath error:&error];
                if (error || !result) {
                    WQLogErr(@"删除日志: %@ -- 错误: %@",[deletePath lastPathComponent],error);
                }else {
                    WQLogInf(@"删除日志: %@",[deletePath lastPathComponent]);
                }
            }else {
                WQLogWar(@"删除日志: %@ -- 错误: 不是日志文件",deletePath);
            }
        }
    }
}

- (void)log:(NSString *)file
      level:(WQLogLevel)level
       line:(int)line
     thread:(NSThread *)thread
        log:(NSString *)log,... {
    if (log) {
        va_list list;
        va_start(list, log);
        NSString *msg = [[NSString alloc] initWithFormat:log
                                               arguments:list];
        va_end(list);
        [self outputLog:file
                  level:level
                   line:line
                 thread:thread
                    log:msg];
    }
}


#pragma mark -- 私有方法 --
- (void)outputLog:(NSString *)file
            level:(WQLogLevel)level
             line:(int)line
           thread:(NSThread *)thread
              log:(NSString *)msg {
    NSString *levelStr = @"";
    NSString *headerStr = @"";
    NSString *footerStr = @"";
    switch (level) {
        case kWQLogDef:
            levelStr = @"WQDef";
            headerStr = @">> >> >>";
            footerStr = @"<< << <<";
            break;
        case kWQLogInf:
            levelStr = @"WQInf";
            headerStr = @">> >> >>";
            footerStr = @"<< << <<";
            break;
        case kWQLogErr:
            levelStr = @"WQErr";
            headerStr = @">> ## >>";
            footerStr = @"<< ## <<";
            break;
        case kWQLogWar:
            levelStr = @"WQWar";
            headerStr = @">> !! >>";
            footerStr = @"<< !! <<";
            break;
        case kWQLogMes:
            levelStr = @"WQMes";
            headerStr = @">> ** >>";
            footerStr = @"<< ** <<";
            break;
        case kWQLogOth:
            levelStr = @"WQOth";
            headerStr = @">> $$ >>";
            footerStr = @"<< $$ <<";
            break;
            
        default:
            levelStr = @"Unknow";
            headerStr = @">> ?? >>";
            footerStr = @"<< ?? <<";
            break;
    }
    NSString *queueName = [NSString stringWithUTF8String:dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
    NSString *threadName = [[NSThread currentThread] isMainThread] ? @"Main" : ([NSThread currentThread].name.length == 0 ? (queueName.length != 0 ? queueName : @"Child") : [NSThread currentThread].name);
    NSString *log = @"";
    log = [NSString stringWithFormat:@"%@ 文件: %@ --- 线程: %@ --- 类型: %@[%d]: %@ %@",
           headerStr,
           file,
           threadName,
           levelStr,
           line,
           msg,
           footerStr];    
    NSLog(@"%@",log);
    if (self.isRecordLog) {
        __weak typeof(self) wself = self;
        dispatch_async(self.writeQueue, ^{
            __strong typeof(wself) sself = wself;
            [sself recordLog:log];
        });
    }
}

void wq_uncaughtExceptionHandler(NSException *exception) {
    if (WQLogCtrl.isRecordLog) {
        // 堆栈数据
        NSArray *callStackSymbolsArr = [exception callStackSymbols];
        
        //获取在哪个类的哪个方法中实例化的数组
        NSString *mainMessage = wq_getMainCallStackSymbolMessageWithCallStackSymbolString(callStackSymbolsArr);
        if (mainMessage == nil) {
            mainMessage = @"崩溃方法定位失败,请您查看函数调用栈来查找crash原因";
        }
        NSString *crashName = [NSString stringWithFormat:@"\t\t        [Crash Type]: %@",exception.name];
        NSString *crashReason = [NSString stringWithFormat:@"\t\t    [Crash Reason]: %@",exception.reason];
        NSString *crashLocation = [NSString stringWithFormat:@"\t\t[Crash Location]: %@",mainMessage];
        NSMutableString *recordLog = [NSMutableString stringWithFormat:@"\n------------------ Crash Information Start ------------------\n%@\n%@\n%@\n函数堆栈:\n%@\n------------------ Crash Information Finish ------------------\n\n",crashName,crashReason,crashLocation,callStackSymbolsArr];
        [WQLogCtrl recordLog:recordLog];
    }
}

NSString* wq_getMainCallStackSymbolMessageWithCallStackSymbolString(NSArray<NSString *> *callStackSymbolsArr) {
    // 当前项目名称
    NSString *executableFile = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleExecutableKey];
    
    // 函数栈中关于当前项目的函数
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",executableFile];
    NSArray<NSString *> *projectMethodStackSymbols = [callStackSymbolsArr filteredArrayUsingPredicate:predicate];
    
    // 函数栈中关于当前项目的函数 +[类名 方法名] 或者 -[类名 方法名]
    __block NSMutableString *mainCallStackSymbolMsg = [[NSMutableString alloc] init];
    
    // 匹配出来的格式为 +[类名 方法名] 或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    for (int index = (int)projectMethodStackSymbols.count - 1; index >= 0; index --) {
        NSString *callStackSymbolString = projectMethodStackSymbols[index];
        [regularExp enumerateMatchesInString:callStackSymbolString options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbolString.length) usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
            if (result) {
                NSString *msg = [callStackSymbolString substringWithRange:result.range];
                [mainCallStackSymbolMsg appendFormat:@"\n\t\t\t\t%@",msg];
                *stop = YES;
            }
        }];
    }
    return mainCallStackSymbolMsg;
}

- (void)recordLog:(NSString *)log {
    // 记录日志
    @autoreleasepool {
        // 添加日期
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSString *date = [formater stringFromDate:[NSDate date]];
        NSMutableString *recordLog = [[NSMutableString alloc] initWithString:date];
        
        // 添加日志
        [recordLog appendString:@" "];
        [recordLog appendString:log];
        
        // 添加换行
        [recordLog appendString:@"\n"];
        
        // 写入文件
        NSData *recordD = [recordLog dataUsingEncoding:NSUTF8StringEncoding];
        [self.stream write:recordD.bytes maxLength:recordD.length];
    }
}
@end
