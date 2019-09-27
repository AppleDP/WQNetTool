//
//  AuxSource.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxSource
 *
 * @brief 音源
 * @superclass NSObject
 */
@interface AuxSource : NSObject
/** 音源 Id */
@property (nonatomic, assign, readonly) UInt8 sourceId;
/** 音源名称 (0, 8] Bytes */
@property (nonatomic, copy, nullable) NSString *name;
@end
NS_ASSUME_NONNULL_END
