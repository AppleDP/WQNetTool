//
//  WQUdpVC.h
//  WQNetTool
//
//  Created by iOS on 2019/8/23.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface WQUdpVC : UIViewController
/**
 * 初始化
 * @param isMulticast YES: 组播，NO: 单播/广播
 */
- (instancetype)initWithMulticast:(BOOL)isMulticast;
@end
NS_ASSUME_NONNULL_END
