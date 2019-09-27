//
//  NSNotificationCenter+WQExtension.h
//  WQCategory
//
//  Created by iOS on 2019/3/12.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 添加通知监听
 *
 * @pragma observer 监听者
 * @pragma sel 监听方法
 * @pragma key 监听 key
 * @pragma anObject 其它对象
 */
NS_INLINE void wq_notiObserver(id observer, SEL sel, NSString * _Nullable key, id _Nullable anObject) {
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:sel
                                                 name:key
                                               object:anObject];
}
/**
 * 发送通知
 *
 * @pragma key 通知 key
 * @pragma anObject 其它对象
 * @pragma aUserInfo 用户其它信息
 */
NS_INLINE void wq_notiPost(NSString *key, id _Nullable anObject, NSDictionary * _Nullable aUserInfo) {
    [[NSNotificationCenter defaultCenter] postNotificationName:key
                                                        object:anObject
                                                      userInfo:aUserInfo];
}
/**
 * 删除通知
 *
 * @pragma observer 监听者
 * @pragma key 通知 Key
 * @pragma anObject 其它对象
 */
NS_INLINE void wq_notiRemove(id observer, NSString * _Nullable key, id _Nullable anObject) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:key
                                                  object:anObject];
}

@interface NSNotificationCenter (WQExtension)
@end
NS_ASSUME_NONNULL_END
