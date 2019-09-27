//
//  UILabel+WQCategory.m
//  WQCategory
//
//  Created by iOS on 2018/3/19.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "UILabel+WQExtension.h"

@implementation UILabel (WQExtension)
- (void)wq_alignTop {
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName : self.font}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;
    CGSize theStringSize = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName : self.font}
                                                   context:nil].size;
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

- (void)wq_alignBottom {
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName : self.font}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;
    CGSize theStringSize = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName : self.font}
                                                   context:nil].size;
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}
@end
