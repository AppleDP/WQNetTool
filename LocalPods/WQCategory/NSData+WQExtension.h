//
//  NSData+WQCategory.h
//  WQCategory
//
//  Created by iOS on 2018/4/10.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSData (WQExtension)
/**
 * CRC32 校验
 */
- (NSData *)wq_crc32;

/**
 * CRC16 校验
 */
- (ushort)wq_crc16;

/**
 * Hex 字符串转 NSData
 *
 * @param string Hex 字符串
 *
 * @return Hex 字符串转换后的 NSData
 */
+ (instancetype)wq_dataWithHexString:(NSString *)string;
@end
NS_ASSUME_NONNULL_END
