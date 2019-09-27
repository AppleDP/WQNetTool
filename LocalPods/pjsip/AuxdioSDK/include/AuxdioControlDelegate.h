//
//  AuxdioControlDelegate.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/10.
//  Copyright © 2018年 iOS. All rights reserved.
//

/**
 * 房间变化的属性
 */
typedef enum {
    /** 01 澳斯迪电台列表 */
    AuxNetRadioList = 0x01,
    /** 02 设备别名（设备属性） */
    AuxDeviceName,
    /** 03 房间列表 */
    AuxDeviceRoomList,
    /** 04 音源列表 */
    AuxDeviceSourceList,
    /** 05 本地播放列表 */
    AuxDevicePlayList,
    /** 06 网络模块列表 */
    AuxDeviceModuleList,
    /** 07 房间状态发生改变 */
    AuxRoomStatus,
    /** 08 房间名称 */
    AuxRoomName,
    /** 09 房间播放模式 */
    AuxRoomPlayMode,
    /** 10 房间播放状态 */
    AuxPlayStatus,
    /** 11 新房间 */
    AuxNewRoom,
    /** 12 房间节目名称改变 */
    AuxRoomProgramName,
    /** 13 设备版本 */
    AuxDeviceVersion,
    /** 14 分区与模块关联属性 */
    AuxModuleMode,
    /** 15 Usb 插入 */
    AuxUsbInsert,
    /** 16 Usb 拔出 */
    AuxUsbExtract,
    /** 17 SD 卡目录歌曲 */
    AuxSdCard,
    /** 18 电台添加/删除操作 */
    AuxNetRadioOperation,
    /** 19 对讲/设备变化 */
    AuxTBStatus,
    /** 20 接听对讲 */
    AuxTalkbackAccept,
    /** 21 拒绝对讲 */
    AuxTalkbackRefuse,
    /** 22 对讲/广播开始 */
    AuxTBStart,
    /** 23 对讲/广播结束 */
    AuxTBStop,
    /** 24 云雀之声当前播放列表 */
    AuxRoomLarkList,        
}AuxChanged;

#ifndef AuxdioControlDelegate_h
#define AuxdioControlDelegate_h
@class AuxRoom;
@class AuxDevice;

NS_ASSUME_NONNULL_BEGIN
#pragma mark -- 状态回调代理 --
/**
 *  @protocol AuxdioControlDelegate
 *
 *  @brief 设备、房间状态变化或发现SDK错误回调代理
 */
@protocol AuxdioControlDelegate <NSObject>
@optional
/**
 * 变化产生时回调
 *
 * @param device 变化设备
 * @param room 变化房间
 * @param change 变化类型
 * @param info 其它信息
 */
-(void)deviceStatusChanged:(nullable __kindof AuxDevice *)device
                      room:(nullable __kindof AuxRoom *)room
                   changed:(AuxChanged)change
                      info:(nullable NSDictionary<NSString *, id> *)info;
/**
 * 发现设备
 *
 * @param device 上线设备
 * @param info 其它信息
 */
- (void)didSearchDevice:(__kindof AuxDevice *)device
                   info:(nullable NSDictionary<NSString *, id> *)info;
/**
 * 设备下线
 *
 * @param device 下线设备
 * @param info 其它信息
 */
- (void)deviceOffline:(__kindof AuxDevice *)device
                 info:(nullable NSDictionary<NSString *, id> *)info;
/**
 * 捕获错误信息
 *
 * @param error 错误信息
 * @param device 发生错误设备
 * @param room 发生错误房间
 * @param info 其它信息
 */
- (void)catchError:(NSError *)error
            device:(nullable __kindof AuxDevice *)device
              room:(nullable __kindof AuxRoom *)room
              info:(nullable NSDictionary<NSString *, id> *)info;
@end


#pragma mark -- 房间代理 --
/**
 *  @protocol AuxRoomDelegate
 *
 *  @brief 房间变化回调代理
 */
@protocol AuxRoomDelegate <NSObject>
@optional
/**
 * 歌曲进度
 *
 * @param room 房间
 * @param position 当前时长
 * @param duration 总时长
 */
- (void)room:(__kindof AuxRoom *)room
    position:(ushort)position
    duration:(ushort)duration;
@end
NS_ASSUME_NONNULL_END
#endif /* AuxdioControlDelegate_h */
