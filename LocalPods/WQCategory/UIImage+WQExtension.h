//
//  UIImage+WQCategory.h
//  WQCategory
//
//  Created by iOS on 2018/4/10.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    WQBarCode,     // 条形码
    WQQRCode,      // 二维码
}WQCodeType;

NS_ASSUME_NONNULL_BEGIN
@interface UIImage (WQExtension)
/**
 * 生成一张 color 色的 image
 */
+ (UIImage *)wq_imageWithColor:(UIColor *)color
                          size:(CGSize)size;
/**
 * 生成二维码或条形码
 *
 *  @param codeType  生成类型
 *  @param str       二维码、条形码内容
 *  @param size      二维码、条形码大小
 *  @param color     二维码、条形码颜色
 *  @param watermark 二维码、条形码水印图
 *  @param rect      水印图在二维码、条形码中的位置（在 watermark ！= nil 时可有效）
 *
 *  @return 二维码、条形码图片
 */
+ (UIImage *)wq_codeCreateWithType:(WQCodeType)codeType
                            String:(NSString *)str
                              size:(CGSize)size
                             color:(nullable UIColor *)color
                         watermark:(nullable UIImage *)watermark
                          position:(CGRect)rect;
/**
 * 无损压缩图片
 *
 * @param expectSize 期望压缩值
 */
- (NSData *)wq_losslessCompressionWithExpectSize:(NSUInteger)expectSize;

/**
 * 修改图片颜色
 */
- (UIImage *)wq_imageWithTintColor:(UIColor *)tintColor;
- (UIImage *)wq_imageWithGradientTintColor:(UIColor *)tintColor;

/**
 * 修改图片大小
 */
- (UIImage *)wq_scaleToSize:(CGSize)size;

/**
 * 高度等比修改图片大小
 *
 * @param width 修改后宽
 */
- (UIImage *)wq_ratioHeightWithWidth:(CGFloat)width;

/**
 * 宽度等比修改图片大小
 *
 * @param height 修改后高
 */
- (UIImage *)wq_ratioWidthWithHeight:(CGFloat)height;

/**
 * 在图片上添加图片
 *
 * @param image 上层图片
 * @param rect 上层图片位置
 */
- (UIImage *)wq_insertImage:(UIImage *)image
                       rect:(CGRect)rect;
@end
NS_ASSUME_NONNULL_END
