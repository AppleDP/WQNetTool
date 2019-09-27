//
//  UIView+WQCategory.m
//  WQCategory
//
//  Created by iOS on 2018/3/19.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "UIView+WQExtension.h"

@implementation UIView (WQExtension)
#pragma mark -- View Frame 
- (void)setWq_x:(CGFloat)wq_x {
    CGRect rect = self.frame;
    rect.origin.x = wq_x;
    self.frame = rect;
}
- (CGFloat)wq_x {
    return self.frame.origin.x;
}

- (void)setWq_maxX:(CGFloat)wq_maxX {
    CGRect rect = self.frame;
    rect.origin.x = wq_maxX - self.frame.size.width;
    self.frame = rect;
}
- (CGFloat)wq_maxX {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setWq_maxY:(CGFloat)wq_maxY {
    CGRect rect = self.frame;
    rect.origin.y = wq_maxY - self.frame.size.height;
    self.frame = rect;
}
- (CGFloat)wq_maxY {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setWq_y:(CGFloat)wq_y {
    CGRect rect = self.frame;
    rect.origin.y = wq_y;
    self.frame = rect;
}
-(CGFloat)wq_y {
    return self.frame.origin.y;
}

- (void)setWq_centerX:(CGFloat)wq_centerX {
    CGPoint center = self.center;
    center.x = wq_centerX;
    self.center = center;
}
- (CGFloat)wq_centerX {
    return self.center.x;
}

- (void)setWq_centerY:(CGFloat)wq_centerY {
    CGPoint center = self.center;
    center.y = wq_centerY;
    self.center = center;
}
- (CGFloat)wq_centerY {
    return self.center.y;
}

- (void)setWq_width:(CGFloat)wq_width {
    CGRect rect = self.frame;
    rect.size.width = wq_width;
    self.frame = rect;
}
- (CGFloat)wq_width {
    return self.frame.size.width;
}

- (void)setWq_height:(CGFloat)wq_height {
    CGRect rect = self.frame;
    rect.size.height = wq_height;
    self.frame = rect;
}
- (CGFloat)wq_height {
    return self.frame.size.height;
}

- (void)setWq_size:(CGSize)wq_size {
    CGRect rect = self.frame;
    rect.size.width = wq_size.width;
    rect.size.height = wq_size.height;
    self.frame = rect;
}
- (CGSize)wq_size {
    return self.frame.size;
}

- (UIImage *)wq_covertToImage {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
