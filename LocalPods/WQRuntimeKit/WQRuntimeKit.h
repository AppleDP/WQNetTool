//
//  WQRuntimeKit.h
//  WQRuntimeKit
//
//  Created by admin on 17/3/2.
//  Copyright © 2017年 jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WQRuntimeKit : NSObject
/**
 *  获取类名
 *
 *  @param class Class
 *
 *  @return 类名
 */
+ (NSString *)classNameWithClass:(Class)mClass;

/**
 *  获取该类 .m 文件中的所有方法名（包括分类 .m 文件中的方法）
 *
 *  @param class Class
 *
 *  @return 方法名数组
 */
+ (NSArray *)methodNamesWithClass:(Class)mClass;

/**
 *  获取类的变量名（分类变量除外），属性 + 实例变量
 *
 *  @param class Class
 *
 *  @return 变量名及类型数组
 */
+ (NSArray<NSDictionary <NSString *, NSString *> *> *)ivarNamesWithClass:(Class)mClass;

/**
 *  获取类的属性名（包括分类属性）
 *
 *  @param mClass Class
 *
 *  @return 变量名及特性
 */
+ (NSArray<NSDictionary <NSString *, NSString *> *> *)propertyNamesWithClass:(Class)mClass;

/**
 *  获取遵循的协议名称（包括分类遵循的协议）
 *
 *  @param mClass Class
 *
 *  @return 遵循的协议
 */
+ (NSArray<NSString *> *)protocolNamesWithClass:(Class)mClass;

/**
 *  向类动态添加实例方法，如果类实例调用 name 方法，则实际上是调用 implement 方法
 *
 *  @param mClass    Class
 *  @param name      方法名
 *  @param implement 方法具体实现
 */
+ (void)addInstanceMethodForClass:(Class)mClass
                       methodName:(SEL)name
                        implement:(SEL)implement;
/**
 *  向类动态添加类方法，如果类调用 name 方法，则实际上是调用 implement 方法
 *
 *  @param mClass    Class
 *  @param name      方法名
 *  @param implement 方法具体实现
 */
+ (void)addClassMethodForClass:(Class)mClass
                    methodName:(SEL)name
                     implement:(SEL)implement;
/**
 *  交换两个实例方法，原调用 method1 处在交换后将调用 method2。反之原调用 method2 处将调用 method1
 *
 *  @param mClass  Class
 *  @param method1 方法1
 *  @param method2 方法2
 */
+ (void)exchangeInstanceMethodForClass:(Class)mClass
                           methodFirst:(SEL)method1
                          methodSecond:(SEL)method2;
/**
 *  交换两个类方法，原调用 method1 处在交换后将调用 method2。反之原调用 method2 处将调用 method1
 *
 *  @param mClass  Class
 *  @param method1 方法1
 *  @param method2 方法2
 */
+ (void)exchangeClassMethodForClass:(Class)mClass
                        methodFirst:(SEL)method1
                       methodSecond:(SEL)method2;
/**
 * 将 method1 实例方法的具体实现替换为 method2 实例方法。在调用 method1 时实际上调用 method2，调用 method2 时还是调用 method2
 *
 *  @param mClass  Class
 *  @param method1 方法1
 *  @param method2 方法2
 */
+ (void)changeInstanceMethodForClass:(Class)mClass
                              method:(SEL)method1
                           implement:(SEL)method2;
/**
 * 将 method1 类方法的具体实现替换为 method2 类方法。在调用 method1 时实际上调用 method2，调用 method2 时还是调用 method2
 *
 *  @param mClass  Class
 *  @param method1 方法1
 *  @param method2 方法2
 */
+ (void)changeClassMethodForClass:(Class)mClass
                           method:(SEL)method1
                        implement:(SEL)method2;
/**
 * 获取所有注册的类
 *
 * @return 返回注册类
 */
+ (Class *)registClass;
@end
