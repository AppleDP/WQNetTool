//
//  Aux858.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxEq.h"
#import "AuxLarkList.h"
#import "AuxRoomUniset.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class Aux858
 *
 * @brief DM858 房间模型
 * @superclass AuxRoomUniset
 */
@interface Aux858 : AuxRoomUniset
/** 云雀之声当前播放列表 */
@property (nonatomic, strong, readonly) AuxLarkList *larkList;
/** 对讲/广播状态 */
@property (nonatomic, assign, readonly) AuxAudioStatus tbStatus;
/** 对讲/广播音频通道打开状态 */
@property (nonatomic, assign, readonly) BOOL isAudioTrackOpen;
/** 音效 */
@property (nonatomic, strong, nullable) AuxEq *eq;
/** 音效列表 */
@property (nonatomic, copy, readonly) NSArray<AuxEq *> *eqList;
/** 左声道名称 (0, 6] Bytes */
@property (nonatomic, copy, nullable) NSString *lName;
/** 右声道名称 (0, 6] Bytes */
@property (nonatomic, copy, nullable) NSString *rName;
/** 左声道音量 [0, 100] */
@property (nonatomic, assign) UInt8 lVolume;
/** 右声道音量 [0, 100] */
@property (nonatomic, assign) UInt8 rVolume;
/** 左声道静音 */
@property (nonatomic, assign) BOOL lMute;
/** 右声道静音 */
@property (nonatomic, assign) BOOL rMute;


/**
 * 开始对讲
 *
 * @warning 暂未对外开放
 */
- (void)startTalk;

/**
 * 结束对讲
 *
 * @warning 暂未对外开放
 */
- (void)finishTalk;

/**
 * 加入广播
 *
 * @warning 暂未对外开放
 */
- (void)joinInBroadcast;

/**
 * 退出广播
 *
 * @warning 暂未对外开放
 */
- (void)removeBroadcast;
@end
NS_ASSUME_NONNULL_END
