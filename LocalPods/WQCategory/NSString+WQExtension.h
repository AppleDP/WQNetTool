//
//  NSString+WQCategory.h
//  WQCategory
//
//  Created by iOS on 2018/3/19.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSString (WQExtension)
/**
 * 中文转拼音
 */
- (NSString *)wq_transformToPinyin;

/**
 * 32 位 MD5 加密
 */
- (NSString *)wq_md5_32;

/**
 * 16 位 MD5 加密
 */
- (NSString *)wq_md5_16;

/**
 * base64 编码
 */
- (NSString *)wq_base64Encode;

/**
 * base64 解码
 */
- (NSString *)wq_base64Decode;

/**
 * 抽取字符串中文字符
 */
- (NSString *)wq_chinese;

/**
 * 抽取字符串中非中文字符
 */
- (NSString *)wq_unchinese;

/**
 * 字符串不为空
 */
- (BOOL)wq_isNonnull;

/**
 * NSData 转 Hex 字符串
 *
 * @param data 十六进制数据
 *
 * @return data 转换的小写 Hex 字符串
 */
+ (instancetype)wq_hexStringWithData:(NSData *)data;
@end
NS_ASSUME_NONNULL_END
