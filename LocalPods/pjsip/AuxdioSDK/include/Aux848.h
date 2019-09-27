//
//  Aux848.h
//  AuxdioControl
//
//  Created by iOS on 2018/6/13.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "Aux838.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9.0)
/**
 * @class Aux848
 *
 * @brief DM848 房间模型
 * @superclass Aux838
 */
@interface Aux848 : Aux838
/** 音效列表 */
@property (nonatomic, copy, readonly) NSArray<AuxEq *> *eqList;
/** 音效 */
@property (nonatomic, strong, nullable) AuxEq *eq;
@end
NS_ASSUME_NONNULL_END
