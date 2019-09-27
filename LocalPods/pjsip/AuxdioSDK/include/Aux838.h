//
//  Aux838.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxRoomUniset.h"
#import "AuxdioControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class Aux838
 *
 * @brief DM838 房间模型
 * @superclass AuxRoomUniset
 */
@interface Aux838 : AuxRoomUniset
/** 房间代理 */
@property (nonatomic, weak, nullable) id<AuxRoomDelegate> delegate;


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
