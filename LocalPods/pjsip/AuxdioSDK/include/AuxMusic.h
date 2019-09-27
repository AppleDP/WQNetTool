//
//  AuxMusic.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/14.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AuxMusicList;

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxMusic
 *
 * @brief 音乐基类
 * @superclass NSObject
 */
@interface AuxMusic : NSObject
/** 音乐名称 */
@property (nonatomic, copy, readonly, nullable) NSString *name;
/** 音乐所在列表 */
@property (nonatomic, weak, readonly) __kindof AuxMusicList *list;
@end
NS_ASSUME_NONNULL_END
