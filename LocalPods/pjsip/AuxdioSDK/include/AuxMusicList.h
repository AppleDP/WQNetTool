//
//  AuxList.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/15.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxMusic.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxMusicList
 *
 * @brief 音乐列表基类
 * @superclass NSObject
 */
@interface AuxMusicList : NSObject
/** 列表名称 */
@property (nonatomic, copy, readonly, nullable) NSString *name;
/** 音乐列表（AuxRadio/AuxSong/AuxLark） */
@property (nonatomic, copy, readonly) NSArray<__kindof AuxMusic *> *musicList;
@end
NS_ASSUME_NONNULL_END
