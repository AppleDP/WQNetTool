//
//  AuxDeviceCenter.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/15.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxDevice.h"
#import "AuxModule.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxDeviceCenter
 *
 * @brief 多房间控制设备基类
 * @superclass AuxDevice
 */
@interface AuxDeviceCenter : AuxDevice
/** 模块列表 */
@property (nonatomic, copy, readonly) NSArray<AuxModule *> *moduleList;
/** 模块关联模式 */
@property (nonatomic, assign) AuxAssociatedModule moduleMode;


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
