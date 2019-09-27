//
//  UIDevice+WQExtension.h
//  WQCategory
//
//  Created by iOS on 2019/1/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    is_iPhone_4 = 1,
    is_iPhone_5SE = 1 << 1,
    is_iPhone_678 = 1 << 2,
    is_iPhone_678P = 1 << 3,
    is_iPhone_X = 1 << 3,
    is_iPhone_Xr = 1 << 3,
    is_iPhone_Xs_Max = 1 << 3,
} WQiPhone;

NS_ASSUME_NONNULL_BEGIN
@interface UIDevice (WQExtension)
/**
 * 判断当前 iPhone 机型
 *
 * @param myPhone 判断机型
 */
+ (BOOL)wq_determinMyiPhone:(WQiPhone)myPhone;

/**
 * 获取当前网络 ip 地址
 */
+ (nullable NSString *)wq_getIpAddress;

/**
 * 获取当前网络子网掩码
 */
+ (nullable NSString *)wq_getSubnet;
@end
NS_ASSUME_NONNULL_END
