//
//  WQRuntimeKit.m
//  WQRuntimeKit
//
//  Created by admin on 17/3/2.
//  Copyright © 2017年 jolimark. All rights reserved.
//

#import "WQRuntimeKit.h"
#import <objc/runtime.h>

@implementation WQRuntimeKit
+ (NSString *)classNameWithClass:(Class)mClass {
    NSString *name;
    const char *cName = class_getName(mClass);
    name = [NSString stringWithUTF8String:cName];
    return name;
}

+ (NSArray *)methodNamesWithClass:(Class)mClass {
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(mClass, &count);
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:count];
    for (unsigned int index = 0; index < count; index ++) {
        Method method = methodList[index];
        SEL methodSel = method_getName(method);
        [names addObject:NSStringFromSelector(methodSel)];
    }
    return names;
}

+ (NSArray<NSDictionary <NSString *, NSString *> *> *)ivarNamesWithClass:(Class)mClass {
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(mClass, &count);
    NSMutableArray *message = [[NSMutableArray alloc] initWithCapacity:count];
    for (unsigned int index = 0; index < count; index ++) {
        NSMutableDictionary *ivarDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        Ivar ivar = ivarList[index];
        const char *cName = ivar_getName(ivar);
        const char *cType = ivar_getTypeEncoding(ivar);
        NSString *name = [NSString stringWithUTF8String:cName];
        NSString *type = [NSString stringWithUTF8String:cType];
        ivarDic[@"name"] = name;
        ivarDic[@"type"] = type;
        [message addObject:ivarDic];
    }
    free(ivarList);
    return message;
}

+ (NSArray<NSDictionary <NSString *, NSString *> *> *)propertyNamesWithClass:(Class)mClass {
    unsigned int count = 0;
    objc_property_t *propertys = class_copyPropertyList(mClass, &count);
    NSMutableArray *message = [[NSMutableArray alloc] initWithCapacity:count];
    for (unsigned index = 0; index < count; index ++) {
        NSMutableDictionary *propertyDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        const char *cName = property_getName(propertys[index]);
        const char *cAttribute = property_getAttributes(propertys[index]);
        NSString *name = [NSString stringWithUTF8String:cName];
        NSString *attribute = [NSString stringWithUTF8String:cAttribute];
        propertyDic[@"name"] = name;
        propertyDic[@"attribute"] = attribute;
        [message addObject:propertyDic];
    }
    free(propertys);
    return message;
}

+ (NSArray<NSString *> *)protocolNamesWithClass:(Class)mClass {
    unsigned int count = 0;
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList(mClass, &count);
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:count];
    for (unsigned int index = 0; index < count; index ++) {
        Protocol *protocol = protocolList[index];
        const char *cName = protocol_getName(protocol);
        [names addObject:[NSString stringWithUTF8String:cName]];
    }
    free(protocolList);
    return names;
}

+ (void)addInstanceMethodForClass:(Class)mClass
                       methodName:(SEL)name
                        implement:(SEL)implement {
    Method method = class_getInstanceMethod(mClass, implement);
    IMP methodIMP = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    class_addMethod(mClass, name, methodIMP, types);
}

+ (void)addClassMethodForClass:(Class)mClass
                    methodName:(SEL)name
                     implement:(SEL)implement {
    Method method = class_getClassMethod(mClass, implement);
    IMP methodIMP = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    class_addMethod(mClass, name, methodIMP, types);
}

+ (void)exchangeInstanceMethodForClass:(Class)mClass
                           methodFirst:(SEL)method1
                          methodSecond:(SEL)method2 {
    Method m1 = class_getInstanceMethod(mClass, method1);
    Method m2 = class_getInstanceMethod(mClass, method2);
    method_exchangeImplementations(m1, m2);
}

+ (void)exchangeClassMethodForClass:(Class)mClass
                        methodFirst:(SEL)method1
                       methodSecond:(SEL)method2 {
    Method m1 = class_getClassMethod(mClass, method1);
    Method m2 = class_getClassMethod(mClass, method2);
    method_exchangeImplementations(m1, m2);
}

+ (void)changeInstanceMethodForClass:(Class)mClass
                              method:(SEL)method1
                           implement:(SEL)method2 {
    Method m1 = class_getInstanceMethod(mClass, method1);
    Method m2 = class_getInstanceMethod(mClass, method2);
    IMP m2IMP = method_getImplementation(m2);
    method_setImplementation(m1, m2IMP);
}

+ (void)changeClassMethodForClass:(Class)mClass
                           method:(SEL)method1
                        implement:(SEL)method2 {
    Method m1 = class_getClassMethod(mClass, method1);
    Method m2 = class_getClassMethod(mClass, method2);
    IMP m2IMP = method_getImplementation(m2);
    method_setImplementation(m1, m2IMP);
}

+ (Class *)registClass {
    uint32_t count;
    Class *classes = objc_copyClassList(&count);
    return classes;
}
@end
