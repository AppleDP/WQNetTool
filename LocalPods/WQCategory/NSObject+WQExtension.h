//
//  NSObject+WQExtension.h
//  WQCategory
//
//  Created by iOS on 2018/5/22.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (WQExtension)
/**
 * 判断是否该类或该类的派生类
 *
 * @param classString 类名
 */
- (BOOL)wq_isKindOfClassWithString:(NSString *)classString;

/**
 * 判断是否该类本类
 */
- (BOOL)wq_isMemberOfClassWithString:(NSString *)classString;

/**
 * 执行 selector 语句，可有多个参数，selector 不存在 或 传入参数错误 时抛出异常
 *
 * @param aSelector SEL 方法
 * @param arguments 参数地址列表
 */
- (nullable id)wq_performSelector:(SEL)aSelector
                        arguments:(nullable void *)arguments,... NS_REQUIRES_NIL_TERMINATION;
@end
NS_ASSUME_NONNULL_END
