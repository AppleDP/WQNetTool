//
//  UIDevice+WQExtension.m
//  WQCategory
//
//  Created by iOS on 2019/1/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <netdb.h>
#import <net/if.h>
#include <ifaddrs.h>
#import <arpa/inet.h>
#import "UIDevice+WQExtension.h"

@implementation UIDevice (WQExtension)
+ (BOOL)wq_determinMyiPhone:(WQiPhone)myPhone {
    UIInterfaceOrientation ori = [UIApplication sharedApplication].statusBarOrientation;
    if (ori == UIInterfaceOrientationLandscapeLeft || ori == UIInterfaceOrientationLandscapeRight) {
        // 横屏
        if (myPhone & is_iPhone_4) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(480, 320));
        }else if (myPhone & is_iPhone_5SE) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(568, 320));
        }else if (myPhone & is_iPhone_678) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(667, 375));
        }else if (myPhone & is_iPhone_678P) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(736, 414));
        }else if (myPhone & is_iPhone_X) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375));
        }else if (myPhone & is_iPhone_Xr) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(1792, 828));
        }else if (myPhone & is_iPhone_Xs_Max) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(2688, 1242));
        }
    }else {
        // 竖屏
        if (myPhone & is_iPhone_4) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320, 480));
        }else if (myPhone & is_iPhone_5SE) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320, 568));
        }else if (myPhone & is_iPhone_678) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 667));
        }else if (myPhone & is_iPhone_678P) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 736));
        }else if (myPhone & is_iPhone_X) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812));
        }else if (myPhone & is_iPhone_Xr) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(828, 1792));
        }else if (myPhone & is_iPhone_Xs_Max) {
            return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(1242, 2688));
        }
    }
    return NO;
}

+ (nullable NSString *)wq_getIpAddress {
    NSString *address;
    BOOL useIPv6 = NO;
#if TARGET_OS_IPHONE
#if !TARGET_IPHONE_SIMULATOR && !TARGET_OS_TV
    const char* primaryInterface = "en0";
#endif
#else
    const char* primaryInterface = NULL;
    SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault, CFSTR("GCDWebServer"), NULL, NULL);
    if (store) {
        CFPropertyListRef info = SCDynamicStoreCopyValue(store, CFSTR("State:/Network/Global/IPv4"));
        if (info) {
            NSString* interface = [(__bridge NSDictionary*)info objectForKey:@"PrimaryInterface"];
            if (interface) {
                primaryInterface = [[NSString stringWithString:interface] UTF8String];
            }
            CFRelease(info);
        }
        CFRelease(store);
    }
    if (primaryInterface == NULL) {
        primaryInterface = "lo0";
    }
#endif
    struct ifaddrs* list;
    if (getifaddrs(&list) >= 0) {
        for (struct ifaddrs* ifap = list; ifap; ifap = ifap->ifa_next) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_TV
            if (strcmp(ifap->ifa_name, "en0") && strcmp(ifap->ifa_name, "en1"))
#else
                if (strcmp(ifap->ifa_name, primaryInterface))
#endif
                {
                    continue;
                }
            if ((ifap->ifa_flags & IFF_UP) && ((!useIPv6 && (ifap->ifa_addr->sa_family == AF_INET)) || (useIPv6 && (ifap->ifa_addr->sa_family == AF_INET6)))) {
                char hostBuffer[NI_MAXHOST];
                char serviceBuffer[NI_MAXSERV];
                const struct sockaddr* addr = ifap->ifa_addr;
                if (getnameinfo(addr, addr->sa_len, hostBuffer, sizeof(hostBuffer), serviceBuffer, sizeof(serviceBuffer), NI_NUMERICHOST | NI_NUMERICSERV | NI_NOFQDN) != 0) {
                    return address;
                }
                address = (NSString*)[NSString stringWithUTF8String:hostBuffer];
                break;
            }
        }
        freeifaddrs(list);
    }
    return address;
}

+ (nullable NSString *)wq_getSubnet {
    NSString *subnet;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    subnet = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return subnet;
}
@end
