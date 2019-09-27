//
//  AuxLark.h
//  AuxdioControl
//
//  Created by iOS on 2018/6/28.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxMusic.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxLark
 *
 * @brief 云雀之声当前列表歌曲
 * @superclass AuxMusic
 */
@interface AuxLark : AuxMusic
/** 歌手名 */
@property (nonatomic, copy, readonly, nullable) NSString *artist;
@end
NS_ASSUME_NONNULL_END
