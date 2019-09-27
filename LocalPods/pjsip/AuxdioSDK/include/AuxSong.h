//
//  AuxSong.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/14.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxMusic.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxSong
 *
 * @brief 设备本地音乐歌曲
 * @superclass AuxMusic
 */
@interface AuxSong : AuxMusic
/** 歌曲文件路径 */
@property (nonatomic, copy, readonly, nullable) NSString *path;
@end
NS_ASSUME_NONNULL_END
