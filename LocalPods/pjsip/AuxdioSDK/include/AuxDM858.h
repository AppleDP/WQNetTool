//
//  AuxDM858.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxDeviceUniset.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxDM858
 *
 * @brief DM858 设备模型
 * @superclass AuxDeviceUniset
 */
@interface AuxDM858 : AuxDeviceUniset
/** 设备语言版本 */
@property (nonatomic, assign, readonly) AuxDeviceLangue langue;
@end
NS_ASSUME_NONNULL_END
