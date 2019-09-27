//
//  AuxDevice.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/10.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "Aux836.h"
#import "Aux838.h"
#import "Aux848.h"
#import "Aux858.h"
#import "Aux8318.h"
#import "Aux8328.h"
#import "AuxLocalList.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 *  @class AuxDevice
 *
 *  @brief 设备基类
 *  @superclass NSObject
 */
@interface AuxDevice : NSObject
/** 设备名称 */
@property (nonatomic, copy, readonly, nullable) NSString *name;
/** 设备固件版本号 */
@property (nonatomic, copy, readonly, nullable) NSString *version;
/** 设备 ip */
@property (nonatomic, copy, readonly, nullable) NSString *ip;
/** 设备迭代标识 */
@property (nonatomic, assign, readonly) UInt8 identifier;
/** 设备类型 */
@property (nonatomic, assign, readonly) AuxDeviceMode model;
/** 房间列表 */
@property (nonatomic, copy, readonly) NSArray<__kindof AuxRoom *> *roomList;
/** 本地音乐列表 */
@property (nonatomic, copy, readonly) NSArray<AuxLocalList *> *localLists;
/** 音源列表 */
@property (nonatomic, copy, readonly) NSArray<AuxSource *> *sourceList;
/** 设备 mac */
@property (nonatomic, copy, readonly) NSString *mac;
@end
NS_ASSUME_NONNULL_END
