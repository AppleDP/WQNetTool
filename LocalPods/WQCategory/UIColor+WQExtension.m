//
//  UIColor+WQExtension.m
//  WQCategory
//
//  Created by iOS on 2019/1/10.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "UIColor+WQExtension.h"

@implementation UIColor (WQExtension)
- (void)wq_analysisColorWithRed:(CGFloat *)r
                          green:(CGFloat *)g
                           blue:(CGFloat *)b
                          alpha:(CGFloat *)a {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    *r = components[0];
    *g = components[1];
    *b = components[2];
    *a = components[3];
}
@end
