//
//  Aux836.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxEq.h"
#import "AuxRoomUniset.h"
#import "AuxdioControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class Aux836
 *
 * @brief DM836 房间模型
 * @superclass AuxRoomUniset
 */
@interface Aux836 : AuxRoomUniset
/** 音效列表 */
@property (nonatomic, copy, readonly) NSArray<AuxEq *> *eqList;
/** 音效 */
@property (nonatomic, strong, nullable) AuxEq *eq;
/** 房间代理 */
@property (nonatomic, weak, nullable) id<AuxRoomDelegate> delegate;


/**
 * 播放电台
 *
 * @param name 电台名称
 * @param url 电台网址
 */
- (void)playNetRadio:(NSString *)name
                 url:(NSString *)url;
/**
 * 查询歌曲进度
 */
- (void)getTransportState;

/**
 * 设置歌曲进度
 *
 * @param position 歌曲进度
 */
- (void)setTransportState:(ushort)position;
@end
NS_ASSUME_NONNULL_END
