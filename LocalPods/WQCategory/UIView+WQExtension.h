//
//  UIView+WQCategory.h
//  WQCategory
//
//  Created by iOS on 2018/3/19.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (WQExtension)
/**
 * View Frame
 */
@property (nonatomic, assign) CGFloat wq_x;
@property (nonatomic, assign) CGFloat wq_y;
@property (nonatomic, assign) CGFloat wq_maxX;
@property (nonatomic, assign) CGFloat wq_maxY;
@property (nonatomic, assign) CGFloat wq_centerX;
@property (nonatomic, assign) CGFloat wq_centerY;
@property (nonatomic, assign) CGFloat wq_width;
@property (nonatomic, assign) CGFloat wq_height;
@property (nonatomic, assign) CGSize wq_size;

/**
 * 将 View 转成 image
 */
- (UIImage *)wq_covertToImage;
@end
NS_ASSUME_NONNULL_END
