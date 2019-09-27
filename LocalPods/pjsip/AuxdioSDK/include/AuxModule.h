//
//  AuxModule.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxCommand.h"
@class AuxDevice;

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxModule
 *
 * @brief 房间模块
 * @superclass NSObject
 */
@interface AuxModule : NSObject
/** Id */
@property (nonatomic, assign, readonly) UInt8 moduleId;
/** 所属设备 */
@property (nonatomic, weak, readonly) __kindof AuxDevice *device;
/** ip */
@property (nonatomic, copy, readonly) NSString *ip;
/** 名称 (0, 8] bytes */
@property (nonatomic, copy, nullable) NSString *name;
/** 工作模式 */
@property (nonatomic, assign) AuxNetWorkModuleMode mode;
/** 播放模式 */
@property (nonatomic, assign) AuxPlayMode playMode;
@end
NS_ASSUME_NONNULL_END
