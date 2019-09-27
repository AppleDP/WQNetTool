//
//  WQTcpToolVC.m
//  WQNetTool
//
//  Created by iOS on 2019/9/1.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import "WQTcpToolVC.h"
#import "WQTcpServerVC.h"
#import "WQTcpClientVC.h"

@interface WQTcpToolVC ()
@end

@implementation WQTcpToolVC
- (void)loadView {
    __weak typeof(self) wself = self;
    MyLinearLayout *rootLatout = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    rootLatout.backgroundColor = wq_colorWithHex(0xFFFFFF, 1.0);
    rootLatout.insetsPaddingFromSafeArea = UIRectEdgeAll;
    rootLatout.gravity = MyGravity_Horz_Fill | MyGravity_Vert_Center;
    rootLatout.padding = UIEdgeInsetsMake(0, 10, 0, 10);
    rootLatout.subviewVSpace = 20;
    self.view = rootLatout;
    
    // TCP 服务器
    UIButton *serverBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    serverBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [serverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [serverBtn setTitle:@"TCP 服务器" forState:UIControlStateNormal];
    [serverBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    serverBtn.heightSize.equalTo(serverBtn.heightSize).add(5);
    [serverBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [serverBtn bk_addEventHandler:^(id sender) {
        // 点击服务器
        __strong typeof(wself) sself = wself;
        UIButton *btn = sender;
        WQTcpServerVC *tcpVC = [[WQTcpServerVC alloc] init];
        tcpVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:tcpVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [rootLatout addSubview:serverBtn];
    
    // TCP 客户端
    UIButton *clientBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clientBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [clientBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clientBtn setTitle:@"TCP 客户端" forState:UIControlStateNormal];
    [clientBtn setBackgroundColor:wq_colorWithRGB(110, 208, 47, 255)];
    clientBtn.heightSize.equalTo(clientBtn.heightSize).add(5);
    [clientBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [clientBtn bk_addEventHandler:^(id sender) {
        // 点击客户端
        __strong typeof(wself) sself = wself;
        UIButton *btn = sender;
        WQTcpClientVC *tcpVC = [[WQTcpClientVC alloc] init];
        tcpVC.title = btn.titleLabel.text;
        [sself.navigationController pushViewController:tcpVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [rootLatout addSubview:clientBtn];
}
@end
