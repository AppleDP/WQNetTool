//
//  AuxEnum.h
//  AuxdioControl
//
//  Created by iOS on 2018/6/12.
//  Copyright © 2018年 iOS. All rights reserved.


#import <Foundation/Foundation.h>

/** 音效 */
typedef char AuxSoundEffects;
/** 设备型号 */
typedef UInt8 AuxDeviceMode;
/** 播放模式 */
typedef char AuxPlayMode;
/** 网络模块工作模式 */
typedef short AuxNetWorkModuleMode;
/** 分区模块关联模式 */
typedef char AuxAssociatedModule;
/** 对讲/广播忙碌状态 */
typedef UInt8 AuxAudioStatus;
/** 设备语言版本 */
typedef UInt8 AuxDeviceLangue;
/** 音频输出模式 */
typedef UInt8 AuxAudioOutputMode;

/**
 * @class AuxCommand
 *
 * @brief 设备/房间状态
 * @superclass NSObject
 */
NS_ASSUME_NONNULL_BEGIN
@interface AuxCommand : NSObject
#pragma mark -- AuxSoundEffects 音效 --
/** 标准 */
extern AuxSoundEffects const kEqNormal;
/** 流行 */
extern AuxSoundEffects const kEqPop;
/** 古典 */
extern AuxSoundEffects const kEqClassical;
/** 爵士 */
extern AuxSoundEffects const kEqJazz;
/** 摇滚 */
extern AuxSoundEffects const kEqRock;
/** 人声 */
extern AuxSoundEffects const kEqVocal;
/** 金属 */
extern AuxSoundEffects const kEqMetal;
/** 伤感 */
extern AuxSoundEffects const kEqSentimental;
/** 舞曲 */
extern AuxSoundEffects const kEqDance;
/** 自定义 */
extern AuxSoundEffects const kEqCustom;


#pragma mark -- AuxDeviceMode 设备型号 --
/** DM836 */
extern AuxDeviceMode const kDM836;
/** DM838 */
extern AuxDeviceMode const kDM838;
/** DM848 */
extern AuxDeviceMode const kDM848;
/** DM858 */
extern AuxDeviceMode const kDM858;
/** AM8328 */
extern AuxDeviceMode const kAM8328;
/** AM8318 */
extern AuxDeviceMode const kAM8318;


#pragma mark -- AuxPlayMode 播放模式 --
/** 单曲播放 */
extern AuxPlayMode const kSinglePlay;
/** 单曲循环 */
extern AuxPlayMode const kSingleLoop;
/** 列表播放 */
extern AuxPlayMode const kListPlay;
/** 列表循环 */
extern AuxPlayMode const kListLoop;
/** 随机播放 */
extern AuxPlayMode const kShufflePlay;


#pragma mark -- AuxNetWorkModuleMode 网络模块工作模式 --
/** DLNA */
extern AuxNetWorkModuleMode const kModeDLNA;
/** 电台 */
extern AuxNetWorkModuleMode const kModeNetRadio;
/** 网络音乐 */
extern AuxNetWorkModuleMode const kModeNetMusic;


#pragma mark -- AuxAssociatedModule 分区模块关联模式 --
/** 默认 */
extern AuxAssociatedModule const kDefaultMode;
/** 同步 */
extern AuxAssociatedModule const kSynchronization;
/** 自定义 */
extern AuxAssociatedModule const kCustomMode;


#pragma mark -- AuxAudioStatus 对讲/广播忙碌状态 --
/** 空闲 */
extern AuxAudioStatus const kAudioFree;
/** 等待 */
extern AuxAudioStatus const kAudioWait;
/** 接听 */
extern AuxAudioStatus const kAudioBusy;


#pragma mark -- AuxDeviceLangue 设备语言版本 --
/** 中文版 */
extern AuxDeviceLangue const kAuxChinese;
/** 英文版 */
extern AuxDeviceLangue const kAuxEnglish;


#pragma mark -- AuxAudioOutputMode 音频输出模式 --
/** 扬声器 */
extern AuxAudioOutputMode const kAuxSpeaker;
/** 听筒 */
extern AuxAudioOutputMode const kAuxEarphone;
@end
NS_ASSUME_NONNULL_END
