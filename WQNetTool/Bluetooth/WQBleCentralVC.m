//
//  WQBleCentralVC.m
//  WQNetTool
//
//  Created by iOS on 2019/9/5.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import "WQBleCentralVC.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface WQBleCentralVC ()
<
    CBPeripheralDelegate,
    CBCentralManagerDelegate
>
@end

@implementation WQBleCentralVC
- (void)loadView {
    __weak typeof(self) wself = self;
    MyLinearLayout *rootLatout = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    rootLatout.backgroundColor = wq_colorWithHex(0xFFFFFF, 1.0);
    rootLatout.insetsPaddingFromSafeArea = UIRectEdgeAll;
    rootLatout.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    rootLatout.subviewVSpace = 10;
    self.view = rootLatout;
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
}
@end
