//
//  UIColor+WQExtension.h
//  WQCategory
//
//  Created by iOS on 2019/1/10.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * hex 颜色
 *
 * @pragma hex RGB Hex 值
 * @pragma alpha 颜色透明度
 */
NS_INLINE UIColor* wq_colorWithHex(NSInteger hex, CGFloat alpha) {
    return [UIColor colorWithRed:(((hex>>16)&0xFF)/255.0f)
                           green:(((hex>>8)&0xFF)/255.0f)
                            blue:(((hex)&0xFF)/255.0f)
                           alpha:alpha];
}
/**
 *  rgb 颜色
 *
 * @pragma r 红 [0, 255]
 * @pragma g 绿 [0, 255]
 * @pragma b 蓝 [0, 255]
 * @pragma a 透明度 [0, 255]
 */
NS_INLINE UIColor* wq_colorWithRGB(int r, int g, int b, int a) {
    return [UIColor colorWithRed:r/255.0f
                           green:g/255.0f
                            blue:b/255.0f
                           alpha:a/255.0f];
}
/**
 * Hsb 颜色
 *
 * @pragma h 红 [0, 360]
 * @pragma s 绿 [0, 100]
 * @pragma b 蓝 [0, 100]
 * @pragma a 透明度 [0, 255]
 */
NS_INLINE UIColor* wq_colorWithHsb(int h, int s, int b, int a) {
    return [UIColor colorWithHue:h/360.0f
                      saturation:s/100.0f
                      brightness:b/100.0f
                           alpha:a/255.0f];
}

@interface UIColor (WQExtension)
/**
 * 解析颜色 color
 *
 * @pragma r 解析后 red
 * @pragma g 解析后 green
 * @pragma b 解析后 blue
 * @pragma a 解析后 alpha
 */
- (void)wq_analysisColorWithRed:(CGFloat *)r
                          green:(CGFloat *)g
                           blue:(CGFloat *)b
                          alpha:(CGFloat *)a;
@end
NS_ASSUME_NONNULL_END
