//
//  WQBleToolVC.m
//  WQNetTool
//
//  Created by iOS on 2019/9/5.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import "WQBleToolVC.h"
#import "WQBleCentralVC.h"
#import "WQBlePeripheralVC.h"

@interface WQBleToolVC ()
@end

@implementation WQBleToolVC
- (void)loadView {
    __weak typeof(self) wself = self;
    MyLinearLayout *rootLatout = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    rootLatout.backgroundColor = wq_colorWithHex(0xFFFFFF, 1.0);
    rootLatout.insetsPaddingFromSafeArea = UIRectEdgeAll;
    rootLatout.gravity = MyGravity_Horz_Fill | MyGravity_Vert_Center;
    rootLatout.padding = UIEdgeInsetsMake(0, 10, 0, 10);
    rootLatout.subviewVSpace = 20;
    self.view = rootLatout;
    
    // 中心设备
    UIButton *centralBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    centralBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [centralBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [centralBtn setTitle:@"蓝牙中心设备" forState:UIControlStateNormal];
    [centralBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    centralBtn.heightSize.equalTo(centralBtn.heightSize).add(5);
    [centralBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [centralBtn bk_addEventHandler:^(id sender) {
        // 点击中心设备
        __strong typeof(wself) sself = wself;
        UIButton *btn = sender;
        WQBleCentralVC *toolVC = [[WQBleCentralVC alloc] init];
        toolVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:toolVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [rootLatout addSubview:centralBtn];
    
    // 边缘设备
    UIButton *peripheralBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    peripheralBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [peripheralBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [peripheralBtn setTitle:@"蓝牙边缘设备" forState:UIControlStateNormal];
    [peripheralBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    peripheralBtn.heightSize.equalTo(peripheralBtn.heightSize).add(5);
    [peripheralBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [peripheralBtn bk_addEventHandler:^(id sender) {
        // 点击边缘设备
        __strong typeof(wself) sself = wself;
        UIButton *btn = sender;
        WQBlePeripheralVC *toolVC = [[WQBlePeripheralVC alloc] init];
        toolVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:toolVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [rootLatout addSubview:peripheralBtn];
}
@end
