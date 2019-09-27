//
//  UILabel+WQCategory.h
//  WQCategory
//
//  Created by iOS on 2018/3/19.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UILabel (WQExtension)
/**
 * 文字顶部对齐
 */
- (void)wq_alignTop;

/**
 * 文字底部对齐
 */
- (void)wq_alignBottom;
@end
NS_ASSUME_NONNULL_END
