//
//  AuxRoomCenter.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxRoom.h"
#import "AuxModule.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxRoomCenter
 *
 * @brief 多房间设备的房间基类
 * @superclass AuxRoom
 */
@interface AuxRoomCenter : AuxRoom
/** 模块 */
@property (nonatomic, strong, nullable) AuxModule *module;
/** 高音，取值范围 [-10, 10] */
@property (nonatomic, assign) char high;
/** 低音，取值范围 [-10, 10] */
@property (nonatomic, assign) char bass;


/**
 * 播放电台
 *
 * @param name 电台名称
 * @param url 电台网址
 */
- (void)playNetRadio:(NSString *)name
                 url:(NSString *)url;
@end
NS_ASSUME_NONNULL_END
