//
//  WQLog.h
//  WQLog
//
//  Created by admin on 16/8/25.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WQLogCtrl [WQLog shareInstance]

#define WQLogDef(FORMAT,...) WQLoger(kWQLogDef, (FORMAT), ## __VA_ARGS__)
#define WQLogInf(FORMAT,...) WQLoger(kWQLogInf, (FORMAT), ## __VA_ARGS__)
#define WQLogErr(FORMAT,...) WQLoger(kWQLogErr, (FORMAT), ## __VA_ARGS__)
#define WQLogWar(FORMAT,...) WQLoger(kWQLogWar, (FORMAT), ## __VA_ARGS__)
#define WQLogMes(FORMAT,...) WQLoger(kWQLogMes, (FORMAT), ## __VA_ARGS__)
#define WQLogOth(FORMAT,...) WQLoger(kWQLogOth, (FORMAT), ## __VA_ARGS__)
#define WQLoger(LEVEL, FORMAT,...)   \
[WQLogCtrl log: [[NSString stringWithUTF8String:__FILE__] lastPathComponent]   \
         level: LEVEL  \
          line: __LINE__   \
        thread: [NSThread currentThread] \
           log: (FORMAT), ## __VA_ARGS__]

typedef enum {
    /** 默认日志，输出到控制台与文件 */
    kWQLogDef,
    /** 信息日志，输出到控制台与文件 */
    kWQLogInf,
    /** 错误日志，输出到控制台与文件 */
    kWQLogErr,
    /** 警告日志，输出到控制台与文件 */
    kWQLogWar,
    /** 信息日志2，输出到控制台与文件 */
    kWQLogMes,
    /** 自定义日志，发布时不输出到控制台，只输出到日志文件 */
    kWQLogOth,
}WQLogLevel;

NS_ASSUME_NONNULL_BEGIN
/**
 * @class WQLog
 *
 * @brief 日志输出
 * @superclass NSObject
 * @classdesign 控制日志输出格式，DEBUG 下输出：文件、线程、日志类型、行号、日志内容，Release 下输出：线程、日志类型、行号、日志内容
 */
@interface WQLog : NSObject
/**
 * 单例
 */
+ (instancetype)shareInstance;

/**
 * 缓存日志
 *
 * @param dir 日志缓存目录文件夹，文件夹不存在时会创建文件夹
 *
 * @return 日志文件路径
 */
- (nullable NSString *)recordLogWithDir:(NSString *)dir;

/**
 * 清除日志
 *
 * @param dir 日志缓存目录文件夹
 * @param deleteBlock 日志文件列表，返回需要删除的文件
 */
- (void)clearLogCachesWithDir:(NSString *)dir
                       delete:(NSArray<NSString *> * _Nullable (^)(NSArray<NSString *> * _Nullable logPaths))deleteBlock;


/*********************************** 内 部 调 用 ***********************************/
- (void)log:(NSString *)file
      level:(WQLogLevel)level
       line:(int)line
     thread:(NSThread *)thread
        log:(nullable NSString *)log,...;
@end
NS_ASSUME_NONNULL_END
