//
//  AuxControlSDK.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/10.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxDM836.h"
#import "AuxDM838.h"
#import "AuxDM848.h"
#import "AuxDM858.h"
#import "AuxAM8318.h"
#import "AuxAM8328.h"
#import "AuxRadioList.h"
#import "GCDAsyncUdpSocket.h"
#import <AVFoundation/AVFoundation.h>


#ifdef AuxCtrlManager
#undef AuxCtrlManager
#endif
#define AuxCtrlManager [AuxControlSDK shareInstance]


NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 *  @class AuxControlSDK
 *
 *  @brief SDK 控制类
 *  @superclass NSObject
 */
@interface AuxControlSDK : NSObject
/** 录音状态 */
@property (nonatomic, assign, readonly) BOOL isRecording;
/** 设备列表 */
@property (nonatomic, copy, readonly) NSArray<__kindof AuxDevice *> *deviceList;
/** 电台列表 */
@property (nonatomic, copy, readonly) NSArray<AuxRadioList *> *radioLists;
/** 控制回调 */
@property (nonatomic, weak, nullable) id<AuxdioControlDelegate> delegate;
/** 日志输出 */
@property (nonatomic, assign) BOOL log;


/**
 * 控制单例
 */
+ (instancetype)shareInstance;

/**
 * 开启 SDK 工作
 */
- (void)startWorking;

/**
 * 关闭 SDK 工作
 */
- (void)stopWorking;

/**
 * 单/多房间 上一曲
 *
 * @param rooms 房间组合
 */
- (void)prev:(NSArray<__kindof AuxRoom *> *)rooms;

/**
 * 单/多房间 播放歌曲
 *
 * @param play 设置状态
 * @param rooms 房间组合
 */
- (void)play:(BOOL)play
       rooms:(NSArray<__kindof AuxRoom *> *)rooms;
/**
 * 单/多房间 下一曲
 *
 * @param rooms 房间组合
 */
- (void)next:(NSArray<__kindof AuxRoom *> *)rooms;

/**
 * 打开音频采集
 *
 * @warning 暂未对外开放
 */
- (void)startRecord;

/**
 * 关闭音频采集
 *
 * @warning 暂未对外开放
 */
- (void)stopRecord;

/**
 * 音频输出模式
 *
 * @param mode 输出模式
 *
 * @warning 暂未对外开放
 */
- (void)audioOutputMode:(AuxAudioOutputMode)mode;
@end
NS_ASSUME_NONNULL_END
