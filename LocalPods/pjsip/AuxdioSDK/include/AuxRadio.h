//
//  AuxRadio.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/14.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxMusic.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxRadio
 *
 * @brief 澳斯迪电台
 * @superclass AuxMusic
 */
@interface AuxRadio : AuxMusic
/** 电台 URL */
@property (nonatomic, copy, readonly, nullable) NSString *path;
@end
NS_ASSUME_NONNULL_END
