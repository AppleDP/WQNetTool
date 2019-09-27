//
//  NSObject+WQExtension.m
//  WQCategory
//
//  Created by iOS on 2018/5/22.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "NSObject+WQExtension.h"

@implementation NSObject (WQExtension)
- (BOOL)wq_isKindOfClassWithString:(NSString *)classString {
    Class c = NSClassFromString(classString);
    return [self isKindOfClass:c];
}

- (BOOL)wq_isMemberOfClassWithString:(NSString *)classString {
    Class c = NSClassFromString(classString);
    return [self isMemberOfClass:c];
}

- (nullable id)wq_performSelector:(SEL)aSelector
                        arguments:(void *)arguments,... {
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:aSelector];
    if (signature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = self;
        invocation.selector = aSelector;
        NSArray<NSString *> *params = [NSStringFromSelector(aSelector) componentsSeparatedByString:@":"];
        NSInteger paramCount = params.count - 1;
        NSInteger argIndex = 2;
        va_list list;
        void* arg = arguments; // 第一个参数
        va_start(list, arguments);
        int count = 0;
        while (arg) {
            count ++;
            if (count > paramCount) {
                @throw [NSException exceptionWithName:@"WQException" reason:@"传入参数错误" userInfo:nil];
                return nil;
            }
            [invocation setArgument:arg atIndex:argIndex ++];
            
            // 获取下一个参数
            arg = va_arg(list, void *);
        };
        va_end(list);
        [invocation retainArguments];
        [invocation invoke];
        const char *returnType = signature.methodReturnType;
        
        //声明返回值变量
        id returnValue;
        
        //如果没有返回值，也就是消息声明为void，那么returnValue=nil
        if( !strcmp(returnType, @encode(void)) ){
            returnValue =  nil;
        }else if( !strcmp(returnType, @encode(id)) ){
            //如果返回值为对象，那么为变量赋值
            [invocation getReturnValue:&returnValue];
        }else{
            //如果返回值为普通类型NSInteger  BOOL
            //返回值长度
            NSUInteger length = [signature methodReturnLength];
            
            //根据长度申请内存
            void *buffer = (void *)malloc(length);
            
            //为变量赋值
            [invocation getReturnValue:buffer];
            if (strcmp(returnType, @encode(void))  == 0) {
                returnValue = nil;
            }else if (strcmp(returnType, @encode(int))  == 0) {
                returnValue = [NSNumber numberWithInt:*((int *)buffer)];
            }else if (strcmp(returnType, @encode(unsigned int))  == 0) {
                returnValue = [NSNumber numberWithUnsignedInt:*((unsigned int *)buffer)];
            }else if (strcmp(returnType, @encode(float)) == 0) {
                returnValue = [NSNumber numberWithFloat:*((float *)buffer)];
            }else if (strcmp(returnType, @encode(double))  == 0) {
                returnValue = [NSNumber numberWithDouble:*((double *)buffer)];
            }else if (strcmp(returnType, @encode(BOOL)) == 0) {
                returnValue = [NSNumber numberWithBool:*((BOOL *)buffer)];
            }else if(strcmp(returnType, @encode(NSInteger)) == 0){
                returnValue = [NSNumber numberWithInteger:*((NSInteger *)buffer)];
            }else if (strcmp(returnType, @encode(char)) == 0) {
                returnValue = [NSNumber numberWithChar:*((char *)buffer)];
            }else if (strcmp(returnType, @encode(unsigned char)) == 0) {
                returnValue = [NSNumber numberWithUnsignedChar:*((unsigned char *)buffer)];
            }else if (strcmp(returnType, @encode(short)) == 0) {
                returnValue = [NSNumber numberWithShort:*((short *)buffer)];
            }else if (strcmp(returnType, @encode(unsigned short)) == 0) {
                returnValue = [NSNumber numberWithUnsignedShort:*((unsigned short *)buffer)];
            }else if (strcmp(returnType, @encode(long)) == 0) {
                returnValue = [NSNumber numberWithUnsignedLong:*((long *)buffer)];
            }else if (strcmp(returnType, @encode(long long)) == 0) {
                returnValue = [NSNumber numberWithUnsignedLongLong:*((long long *)buffer)];
            }else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
                returnValue = [NSNumber numberWithUnsignedLongLong:*((unsigned long long *)buffer)];
            }
            free(buffer);
        }
        return returnValue;
    }else {
        // 不存在这个方法，抛出异常
        @throw [NSException exceptionWithName:@"WQException" reason:@"不存在调用方法" userInfo:nil];
        return nil;
    }
}
@end
