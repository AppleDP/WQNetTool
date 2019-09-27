//
//  AuxDM836.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxDeviceUniset.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxDM836
 *
 * @brief DM836 设备模型
 * @superclass AuxDeviceUniset
 */
@interface AuxDM836 : AuxDeviceUniset
/**
 * 添加电台
 *
 * @param name 电台名称
 * @param url 电台网址
 */
- (void)addRadioradioName:(NSString *)name
                 radioUrl:(NSString *)url;
/**
 * 删除电台
 *
 * @param name 电台名称
 * @param url 电台网址
 */
- (void)deleteRadioradioName:(NSString *)name
                    radioUrl:(NSString *)url;
@end
NS_ASSUME_NONNULL_END
