//
//  AuxEq.h
//  AuxdioControl
//
//  Created by iOS on 2018/5/16.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "AuxCommand.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class AuxEq
 *
 * @brief 音效
 * @superclass NSObject
 */
@interface AuxEq : NSObject
/** 音效 Id */
@property (nonatomic, assign, readonly) AuxSoundEffects eqId;
/** 音效名称 */
@property (nonatomic, copy, readonly) NSString *name;
@end
NS_ASSUME_NONNULL_END
