//
//  AuxRoom.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/15.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxSource.h"
#import "AuxCommand.h"
#import "AuxMusicList.h"
@class AuxDevice;

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 *  @class AuxRoom
 *
 *  @brief 房间基类
 *  @superclass NSObject
 */
@interface AuxRoom : NSObject
/** 节目名称 */
@property (nonatomic, copy, readonly, nullable) NSString *programName;
/** 房间 Id */
@property (nonatomic, assign, readonly) UInt8 roomId;
/** 设备 */
@property (nonatomic, weak, readonly) __kindof AuxDevice *device;
/** 房间歌曲列表 */
@property (nonatomic, copy, readonly) NSArray<__kindof AuxMusicList *> *playLists;
/** 音源列表 */
@property (nonatomic, copy, readonly) NSArray<AuxSource *> *sourceList;
/** 当前音源 */
@property (nonatomic, strong, nullable) AuxSource *source;
/** 房间名称 AuxRoomCenter: (0, 6] Bytes; Aux836/Aux838/Aux848: (0, 10] Bytes; Aux858: (0, 16] Bytes */
@property (nonatomic, copy, nullable) NSString *name;
/** 房间开关 */
@property (nonatomic, assign) BOOL power;
/** 静音状态 */
@property (nonatomic, assign) BOOL mute;
/** 播放状态 */
@property (nonatomic, assign) BOOL play;
/** 房间音量 [0, 100] */
@property (nonatomic, assign) UInt8 volume;
/** 播放模式 */
@property (nonatomic, assign) AuxPlayMode playMode;


/**
 * 播放音乐
 *
 * @param music AuxRadio/AuxSong/AuxLark
 */
- (void)playMusic:(__kindof AuxMusic *)music;
@end
NS_ASSUME_NONNULL_END
