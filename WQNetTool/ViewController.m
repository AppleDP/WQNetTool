//
//  ViewController.m
//  WQNetTool
//
//  Created by iOS on 2019/8/23.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import "WQUdpToolVC.h"
#import "WQTcpToolVC.h"
#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
- (void)loadView {
    __weak typeof(self) wself = self;
    MyLinearLayout *rootLatout = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    rootLatout.backgroundColor = wq_colorWithHex(0xFFFFFF, 1.0);
    rootLatout.insetsPaddingFromSafeArea = UIRectEdgeAll;
    rootLatout.subviewVSpace = 20;
    rootLatout.gravity = MyGravity_Horz_Fill | MyGravity_Vert_Center;
    rootLatout.padding = UIEdgeInsetsMake(0, 10, 0, 10);
    self.view = rootLatout;
    
    // udp 测试工具
    UIButton *udpBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    udpBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [udpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [udpBtn setTitle:@"UDP 调试工具" forState:UIControlStateNormal];
    [udpBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    udpBtn.heightSize.equalTo(udpBtn.heightSize).add(5);
    [udpBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [udpBtn bk_addEventHandler:^(id sender) {
        // 点击 UDP
        UIButton *btn = sender;
        __strong typeof(wself) sself = wself;
        WQUdpToolVC *toolVC = [[WQUdpToolVC alloc] init];
        toolVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:toolVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [rootLatout addSubview:udpBtn];
    
    // tcp 测试工具
    UIButton *tcpBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tcpBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [tcpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tcpBtn setTitle:@"TCP 调试工具" forState:UIControlStateNormal];
    [tcpBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    tcpBtn.heightSize.equalTo(tcpBtn.heightSize).add(5);
    [tcpBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [tcpBtn bk_addEventHandler:^(id sender) {
        // 点击 TCP
        UIButton *btn = sender;
        __strong typeof(wself) sself = wself;
        WQTcpToolVC *toolVC = [[WQTcpToolVC alloc] init];
        toolVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:toolVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    tcpBtn.wrapContentHeight = YES;
    [rootLatout addSubview:tcpBtn];
    
    self.title = @"无线调试工具";
}
@end
