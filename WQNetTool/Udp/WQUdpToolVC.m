//
//  WQUdpToolVC.m
//  WQNetTool
//
//  Created by iOS on 2019/8/23.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import "WQUdpVC.h"
#import "WQUdpToolVC.h"

@interface WQUdpToolVC ()
@end

@implementation WQUdpToolVC
- (void)loadView {
    __weak typeof(self) wself = self;
    MyLinearLayout *rootLatout = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    rootLatout.backgroundColor = wq_colorWithHex(0xFFFFFF, 1.0);
    rootLatout.insetsPaddingFromSafeArea = UIRectEdgeAll;
    rootLatout.gravity = MyGravity_Horz_Fill | MyGravity_Vert_Center;
    rootLatout.padding = UIEdgeInsetsMake(0, 10, 0, 10);
    rootLatout.subviewVSpace = 20;
    self.view = rootLatout;
    
    // UDP 单播
    UIButton *unicastBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    unicastBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [unicastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [unicastBtn setTitle:@"UDP 单播/广播" forState:UIControlStateNormal];
    [unicastBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    unicastBtn.heightSize.equalTo(unicastBtn.heightSize).add(5);
    [unicastBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [unicastBtn bk_addEventHandler:^(id sender) {
        // 点击组播
        __strong typeof(wself) sself = wself;
        UIButton *btn = sender;
        WQUdpVC *toolVC = [[WQUdpVC alloc] initWithMulticast:NO];
        toolVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:toolVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [rootLatout addSubview:unicastBtn];
    
    // UDP 组播
    UIButton *multicastBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    multicastBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [multicastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [multicastBtn setTitle:@"UDP 组播" forState:UIControlStateNormal];
    [multicastBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    multicastBtn.heightSize.equalTo(multicastBtn.heightSize).add(5);
    [multicastBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [multicastBtn bk_addEventHandler:^(id sender) {
        // 点击组播
        __strong typeof(wself) sself = wself;
        UIButton *btn = sender;
        WQUdpVC *toolVC = [[WQUdpVC alloc] initWithMulticast:YES];
        toolVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:toolVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [rootLatout addSubview:multicastBtn];
}
@end
