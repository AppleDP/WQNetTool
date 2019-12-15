//
//  WQUdpVC.m
//  WQNetTool
//
//  Created by iOS on 2019/8/23.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import "WQUdpVC.h"

@interface WQUdpFilterDelegateObject : NSObject
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, weak) WQUdpVC *vc;
@end

@interface WQUdpFilterCell : UITableViewCell
@property (nonatomic, weak, readonly) UILabel *titleLab;
@property (nonatomic, strong, readonly) MyLinearLayout *rootLayout;
@end

@interface WQUdpReceiveDelegateObject : NSObject
<
    UITextViewDelegate
>
@property (nonatomic, weak) WQUdpVC *vc;
@end

@interface WQUdpVC ()
<
    GCDAsyncUdpSocketDelegate
>
/** socket */
@property (nonatomic, strong, nullable) GCDAsyncUdpSocket *socket;
/** 发送数据数组 */
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSNumber *, NSData *> *sendDic;
/** 当前是否是组播 */
@property (nonatomic, assign) BOOL isMulticast;
/** 目标地址 */
@property (nonatomic, weak) UITextField *targetIpTF;
/** 本地端口号 */
@property (nonatomic, weak) UITextField *localPortTF;
/** 目标端口号 */
@property (nonatomic, weak) UITextField *targetPortTF;
/** 接收框 */
@property (nonatomic, weak) IQTextView *receiveTV;
/** 接收框 TextView 代理 */
@property (nonatomic, strong) WQUdpReceiveDelegateObject *receiveTVDelegate;
/** 显示时间 */
@property (nonatomic, weak) UIButton *showTimeBtn;
/** 显示 remote ip */
@property (nonatomic, weak) UIButton *showIpBtn;
/** 显示 remote port */
@property (nonatomic, weak) UIButton *showPortBtn;
/** 显示最新信息 */
@property (nonatomic, weak) UIButton *showNewBtn;
/** 发送数据类型 */
@property (nonatomic, assign) WQNetToolEncoding sendEncoding;
/** 显示类型 */
@property (nonatomic, assign) WQNetToolEncoding receiveEncoding;
/** 过滤数组 */
@property (nonatomic, strong) NSMutableArray<NSString *> *filterArr;
/** 过滤列表 TableView 代理 */
@property (nonatomic, strong) WQUdpFilterDelegateObject *filterTableDelegate;
/** 过滤布局 */
@property (nonatomic, weak) MyLinearLayout *filterLayout;
@end

@implementation WQUdpVC
- (instancetype)initWithMulticast:(BOOL)isMulticast {
    self = [super init];
    if (self) {
        self.isMulticast = isMulticast;
    }
    return self;
}

- (GCDAsyncUdpSocket *)socket {
    if (_socket == nil) {
        dispatch_queue_t delegateQ = dispatch_queue_create("NetTool Delegate Queue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t socketQ = dispatch_queue_create("NetTool Socket Queue", DISPATCH_QUEUE_SERIAL);
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:delegateQ socketQueue:socketQ];
    }
    return _socket;
}

- (NSMutableDictionary *)sendDic {
    if (_sendDic == nil) {
        _sendDic = [[NSMutableDictionary alloc] init];
    }
    return _sendDic;
}

- (NSMutableArray<NSString *> *)filterArr {
    if (_filterArr == nil) {
        _filterArr = [[NSMutableArray alloc] init];
    }
    return _filterArr;
}

- (void)loadView {
    __weak typeof(self) wself = self;
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view = scrollView;
    
    MyLinearLayout *rootLatout = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    rootLatout.backgroundColor = wq_colorWithHex(0xFFFFFF, 1.0);
    rootLatout.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    rootLatout.subviewVSpace = 10;
    rootLatout.myHorzMargin = 0;
    rootLatout.heightSize.lBound(scrollView.heightSize, 0, 1);
    [scrollView addSubview:rootLatout];
    
    // Socket 信息
    MyLinearLayout *layout0 = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Horz];
    layout0.wrapContentHeight = YES;
    layout0.widthSize.equalTo(rootLatout.widthSize);
    layout0.gravity = MyGravity_Vert_Center;
    layout0.subviewHSpace = 5;
    [rootLatout addSubview:layout0];
    
    MyLinearLayout *layout00 = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    layout00.wrapContentHeight = YES;
    layout00.weight = 2;
    layout00.subviewVSpace = 5;
    layout00.gravity = MyGravity_Horz_Fill;
    [layout0 addSubview:layout00];
    
    MyLinearLayout *layout01 = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    layout01.heightSize.equalTo(layout00.heightSize);
    layout01.weight = 1;
    layout01.gravity = MyGravity_Fill;
    [layout0 addSubview:layout01];
    
    UITextField *targetIpTF = [[UITextField alloc] init];
    targetIpTF.placeholder = self.isMulticast ? @"请输入组播地址" : @"请输入目标地址";
    targetIpTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    targetIpTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    targetIpTF.font = [UIFont systemFontOfSize:15];
    targetIpTF.textColor = wq_colorWithHex(0x333333, 1.0);
    targetIpTF.layer.borderWidth = 1.0;
    targetIpTF.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    targetIpTF.layer.cornerRadius = 3.0;
    targetIpTF.leftViewMode = UITextFieldViewModeAlways;
    targetIpTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    targetIpTF.heightSize.equalTo(targetIpTF.heightSize).add(10);
    [layout00 addSubview:targetIpTF];
    self.targetIpTF = targetIpTF;
    
    UITextField *localPortTF = [[UITextField alloc] init];
    localPortTF.placeholder = @"本地端口号";
    localPortTF.keyboardType = UIKeyboardTypeNumberPad;
    localPortTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    localPortTF.font = [UIFont systemFontOfSize:15];
    localPortTF.textColor = wq_colorWithHex(0x333333, 1.0);
    localPortTF.layer.borderWidth = 1.0;
    localPortTF.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    localPortTF.layer.cornerRadius = 3.0;
    localPortTF.leftViewMode = UITextFieldViewModeAlways;
    localPortTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    localPortTF.heightSize.equalTo(targetIpTF.heightSize);
    [layout00 addSubview:localPortTF];
    self.localPortTF = localPortTF;
    
    UITextField *targetPortTF = [[UITextField alloc] init];
    targetPortTF.placeholder = @"目标端口号";
    targetPortTF.keyboardType = UIKeyboardTypeNumberPad;
    targetPortTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    targetPortTF.font = [UIFont systemFontOfSize:15];
    targetPortTF.textColor = wq_colorWithHex(0x333333, 1.0);
    targetPortTF.layer.borderWidth = 1.0;
    targetPortTF.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    targetPortTF.layer.cornerRadius = 3.0;
    targetPortTF.leftViewMode = UITextFieldViewModeAlways;
    targetPortTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    targetPortTF.heightSize.equalTo(targetIpTF.heightSize);
    [layout00 addSubview:targetPortTF];
    self.targetPortTF = targetPortTF;
    
    UIButton *socketOperBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    socketOperBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [socketOperBtn setTitle:@"创建 Socket" forState:UIControlStateNormal];
    [socketOperBtn setTitle:@"关闭 Socket" forState:UIControlStateSelected];
    [socketOperBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [socketOperBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [socketOperBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [socketOperBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(240, 135, 23, 255) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [socketOperBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [socketOperBtn bk_addEventHandler:^(id sender) {
        __strong typeof(wself) sself = wself;
        NSString *ipReg = @"^((25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))$";
        NSPredicate *ipPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ipReg];
        if ([ipPredicate evaluateWithObject:targetIpTF.text] && targetPortTF.text.length > 0 && localPortTF.text.length > 0) {
            UIButton *btn = (UIButton *)sender;
            if (btn.selected) {
                // 关闭 Socket
                if (sself.isMulticast) {
                    // 移除组播
                    NSError *err;
                    BOOL result = [sself.socket leaveMulticastGroup:targetIpTF.text error:&err];
                    if (!result || err) {
                        // 移除组播失败
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"移除组播失败:\n %@",err.localizedDescription]];
                        return;
                    }
                }
                [sself.socket pauseReceiving];
                [sself.socket closeAfterSending];
            }else {
                // 创建 Socket
                NSError *err;
                int localPort = localPortTF.text.intValue;
                BOOL result = [sself.socket enableReusePort:YES error:&err];
                if (!result || err) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"重用端口设置失败: %@",err.localizedDescription]];
                    return;
                }
                result = [sself.socket bindToPort:localPort error:&err];
                if (!result || err) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"本地端口绑定失败: %@",err.localizedDescription]];
                    return;
                }
                if (sself.isMulticast) {
                    // 加入组播
                    result = [sself.socket joinMulticastGroup:targetIpTF.text error:&err];
                    if (!result || err) {
                        // 加入组播失败
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"加入组播失败:\n %@",err.localizedDescription]];
                        return;
                    }
                }else {
                    // 开启广播
                    [sself.socket enableBroadcast:YES error:&err];
                    if (!result || err) {
                        // 打开广播失败
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"打开广播失败:\n %@",err.localizedDescription]];
                        return;
                    }
                }
                err = nil;
                result = [sself.socket beginReceiving:&err];
                if (!result || err) {
                    // 数据监听失败
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"打开数据接收失败:\n %@",err.localizedDescription]];
                    return;
                }
                [SVProgressHUD showSuccessWithStatus:sself.isMulticast ? @"组播 Socket 创建成功" : @"单播 Socket 创建成功"];
            }
            targetIpTF.userInteractionEnabled = btn.selected;
            targetIpTF.textColor = btn.selected ? wq_colorWithHex(0x333333, 1.0) : wq_colorWithHex(0xcccccc, 1.0);
            targetIpTF.layer.borderColor = btn.selected ? wq_colorWithHex(0x333333, 1.0).CGColor : wq_colorWithHex(0xcccccc, 1.0).CGColor;
            localPortTF.userInteractionEnabled = btn.selected;
            localPortTF.textColor = btn.selected ? wq_colorWithHex(0x333333, 1.0) : wq_colorWithHex(0xcccccc, 1.0);
            localPortTF.layer.borderColor = btn.selected ? wq_colorWithHex(0x333333, 1.0).CGColor : wq_colorWithHex(0xcccccc, 1.0).CGColor;
            targetPortTF.userInteractionEnabled = btn.selected;
            targetPortTF.textColor = btn.selected ? wq_colorWithHex(0x333333, 1.0) : wq_colorWithHex(0xcccccc, 1.0);
            targetPortTF.layer.borderColor = btn.selected ? wq_colorWithHex(0x333333, 1.0).CGColor : wq_colorWithHex(0xcccccc, 1.0).CGColor;
            btn.selected = !btn.selected;
        }else {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的 ip 和端口号"];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [layout01 addSubview:socketOperBtn];
    
    // 发送区
    UILabel *inputLab = [[UILabel alloc] init];
    UIButton *showSendStringBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    IQTextView *inputTV = [[IQTextView alloc] init];
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    MyLinearLayout *layoutInputHeader = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Horz];
    layoutInputHeader.widthSize.equalTo(rootLatout.widthSize);
    layoutInputHeader.wrapContentHeight = YES;
    layoutInputHeader.gravity = MyGravity_Vert_Center;
    [rootLatout addSubview:layoutInputHeader];
    
    MyLinearLayout *layoutInputLab = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Horz];
    layoutInputLab.weight = 1.0;
    layoutInputLab.wrapContentHeight = YES;
    [layoutInputHeader addSubview:layoutInputLab];
    
    MyLinearLayout *layoutInputBtn = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Horz];
    layoutInputBtn.wrapContentSize = YES;
    [layoutInputHeader addSubview:layoutInputBtn];
    
    inputLab.font = [UIFont systemFontOfSize:18];
    inputLab.textColor = wq_colorWithHex(0x333333, 1.0);
    inputLab.text = @"发送区:";
    inputLab.wrapContentHeight = YES;
    inputLab.widthSize.equalTo(layoutInputLab.widthSize);
    [layoutInputLab addSubview:inputLab];
    
    [showSendStringBtn setTitle:@"16 进制发送" forState:UIControlStateNormal];
    [showSendStringBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showSendStringBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showSendStringBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [showSendStringBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(240, 135, 23, 255) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [showSendStringBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [showSendStringBtn bk_addEventHandler:^(id sender) {
        // 点击发送格式
        UIButton *btn = sender;
        __strong typeof(wself) sself = wself;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择数据发送类型" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *binaryAction = [UIAlertAction actionWithTitle:@"16 进制发送" style:sself.sendEncoding == kBinarySystem ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 发送 Hex 字符串
            inputTV.placeholder = @"请输入 Hex 字符串: 0102...0D0F";
            inputTV.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [btn setTitle:@"16 进制发送" forState:UIControlStateNormal];
            sself.sendEncoding = kBinarySystem;
            [layoutInputBtn setNeedsLayout];
        }];
        UIAlertAction *utf8Action = [UIAlertAction actionWithTitle:@"UTF-8 编码发送" style:sself.sendEncoding == kEncodingUTF_8 ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 发送 UTF-8 字符串
            inputTV.placeholder = @"请输入字符串";
            inputTV.keyboardType = UIKeyboardTypeDefault;
            [btn setTitle:@"UTF-8 编码发送" forState:UIControlStateNormal];
            sself.sendEncoding = kEncodingUTF_8;
            [layoutInputBtn setNeedsLayout];
        }];
        UIAlertAction *gb2312Action = [UIAlertAction actionWithTitle:@"GB2312 编码发送" style:sself.sendEncoding == kEncodingGB2312 ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 发送 GB2312 字符串
            inputTV.placeholder = @"请输入字符串";
            inputTV.keyboardType = UIKeyboardTypeDefault;
            [btn setTitle:@"GB2312 编码发送" forState:UIControlStateNormal];
            sself.sendEncoding = kEncodingGB2312;
            [layoutInputBtn setNeedsLayout];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:binaryAction];
        [alert addAction:utf8Action];
        [alert addAction:gb2312Action];
        [alert addAction:cancelAction];
        [sself.navigationController presentViewController:alert animated:YES completion:^{
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    showSendStringBtn.widthSize.equalTo(showSendStringBtn.widthSize).add(30);
    showSendStringBtn.heightSize.equalTo(showSendStringBtn.heightSize).add(20);
    [layoutInputBtn addSubview:showSendStringBtn];
    
    MyLinearLayout *layout1 = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    layout1.wrapContentHeight = YES;
    layout1.widthSize.equalTo(rootLatout.widthSize);
    layout1.gravity = MyGravity_Horz_Fill;
    layout1.subviewVSpace = 5;
    [rootLatout addSubview:layout1];
    
    inputTV.textColor = wq_colorWithHex(0x333333, 1.0);
    inputTV.font = [UIFont systemFontOfSize:15];
    inputTV.layer.borderWidth = 1.0;
    inputTV.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    inputTV.layer.cornerRadius = 3.0;
    inputTV.placeholder = @"请输入 Hex 字符串: 0102...0D0F";
    inputTV.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [sendBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    __block NSInteger tag = 0;
    [sendBtn bk_addEventHandler:^(id sender) {
        __strong typeof(wself) sself = wself;
        if (inputTV.text.length > 0) {
            // 发送数据
            NSData *data;
            switch (sself.sendEncoding) {
                case kBinarySystem: {
                    // Hex 字符串转码
                    data = [NSData wq_dataWithHexString:inputTV.text];
                }break;
                case kEncodingUTF_8: {
                    // UTF-8 字符串编码
                    data = [inputTV.text dataUsingEncoding:NSUTF8StringEncoding];
                }break;
                case kEncodingGB2312: {
                    // GB2312 字符串编码
                    data = [inputTV.text dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
                }break;
                    
                default: {
                    data = [NSData wq_dataWithHexString:inputTV.text];
                }break;
            }
            @synchronized (sself.sendDic) {
                sself.sendDic[[NSNumber numberWithInteger:++tag]] = data;
            }
            [sself.socket sendData:data toHost:targetIpTF.text port:targetPortTF.text.intValue withTimeout:-1 tag:tag];
        }else {
            // 发送数据为空
            [SVProgressHUD showErrorWithStatus:@"发送数据不能为空"];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    inputTV.heightSize.equalTo(sendBtn.heightSize).multiply(2.0);
    sendBtn.heightSize.equalTo(sendBtn.heightSize).add(20.0);
    [layout1 addSubview:inputTV];
    [layout1 addSubview:sendBtn];
    
    // 过滤区
    MyLinearLayout *filterLayout = [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Vert];
    filterLayout.wrapContentHeight = YES;
    filterLayout.subviewHSpace = 10;
    filterLayout.subviewVSpace = 10;
    filterLayout.visibility = MyVisibility_Gone;
    filterLayout.widthSize.equalTo(rootLatout.widthSize);
    [rootLatout addSubview:filterLayout];
    self.filterLayout = filterLayout;
    
    UILabel *filterLab = [UILabel new];
    filterLab.wrapContentSize = YES;
    filterLab.font = [UIFont systemFontOfSize:18];
    filterLab.text = @"过滤条件:";
    [filterLayout addSubview:filterLab];
    
    WQUdpFilterDelegateObject *filterTableDelegate = [[WQUdpFilterDelegateObject alloc] init];
    filterTableDelegate.vc = self;
    self.filterTableDelegate = filterTableDelegate;
    UITableView *filterTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    filterTable.delegate = filterTableDelegate;
    filterTable.dataSource = filterTableDelegate;
    filterTable.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    filterTable.layer.borderWidth = 1.0;
    filterTable.delaysContentTouches = NO;
    filterTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [filterTable registerClass:[WQUdpFilterCell class] forCellReuseIdentifier:NSStringFromClass([WQUdpFilterCell class])];
    filterTable.widthSize.equalTo(filterLayout.widthSize);
    filterTable.heightSize.equalTo(@80);
    [filterTable setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [filterLayout addSubview:filterTable];
    
    // 接收区
    UILabel *receiveLab = [[UILabel alloc] init];
    receiveLab.wrapContentSize = YES;
    receiveLab.font = [UIFont systemFontOfSize:18];
    receiveLab.text = @"接收区:";
    [rootLatout addSubview:receiveLab];
    
    MyFloatLayout *layout2 = [MyFloatLayout floatLayoutWithOrientation:MyOrientation_Vert];
    layout2.wrapContentHeight = YES;
    layout2.subviewHSpace = 10;
    layout2.subviewVSpace = 10;
    layout2.widthSize.equalTo(rootLatout.widthSize);
    [rootLatout addSubview:layout2];
    
    WQUdpReceiveDelegateObject *receiveTVDelegate = [[WQUdpReceiveDelegateObject alloc] init];
    receiveTVDelegate.vc = self;
    self.receiveTVDelegate = receiveTVDelegate;
    IQTextView *receiveTV = [[IQTextView alloc] init];
    receiveTV.font = [UIFont systemFontOfSize:15];
    receiveTV.delegate = receiveTVDelegate;
    receiveTV.layer.borderWidth = 1.0;
    receiveTV.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    receiveTV.layer.cornerRadius = 3.0;
    receiveTV.placeholder = @"接收数据显示";
    receiveTV.weight = 1.0;
    receiveTV.widthSize.equalTo(rootLatout.widthSize);
    receiveTV.heightSize.min(100);
    receiveTV.editable = NO;
    [rootLatout addSubview:receiveTV];
    self.receiveTV = receiveTV;
    
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearBtn setTitle:@"清除" forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [clearBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [clearBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [clearBtn bk_addEventHandler:^(id sender) {
        // 点击清除
        receiveTV.text = @"";
    } forControlEvents:UIControlEventTouchUpInside];
    clearBtn.widthSize.equalTo(clearBtn.widthSize).add(30);
    clearBtn.heightSize.equalTo(clearBtn.heightSize).add(20);
    [layout2 addSubview:clearBtn];
    
    UIButton *showTimeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showTimeBtn setTitle:@"时间" forState:UIControlStateNormal];
    [showTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showTimeBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [showTimeBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(240, 135, 23, 255) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [showTimeBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [showTimeBtn bk_addEventHandler:^(id sender) {
        // 点击显示时间
        UIButton *btn = sender;
        btn.selected = !btn.selected;
    } forControlEvents:UIControlEventTouchUpInside];
    showTimeBtn.widthSize.equalTo(showTimeBtn.widthSize).add(30);
    showTimeBtn.heightSize.equalTo(showTimeBtn.heightSize).add(20);
    [layout2 addSubview:showTimeBtn];
    self.showTimeBtn = showTimeBtn;
    
    UIButton *showIpBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showIpBtn setTitle:@"地址" forState:UIControlStateNormal];
    [showIpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showIpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showIpBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [showIpBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(240, 135, 23, 255) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [showIpBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [showIpBtn bk_addEventHandler:^(id sender) {
        // 点击显示 ip
        UIButton *btn = sender;
        btn.selected = !btn.selected;
    } forControlEvents:UIControlEventTouchUpInside];
    showIpBtn.widthSize.equalTo(showIpBtn.widthSize).add(30);
    showIpBtn.heightSize.equalTo(showIpBtn.heightSize).add(20);
    [layout2 addSubview:showIpBtn];
    self.showIpBtn = showIpBtn;
    
    UIButton *showPortBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showPortBtn setTitle:@"端口" forState:UIControlStateNormal];
    [showPortBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showPortBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showPortBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [showPortBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(240, 135, 23, 255) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [showPortBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [showPortBtn bk_addEventHandler:^(id sender) {
        // 点击显示端口
        UIButton *btn = sender;
        btn.selected = !btn.selected;
    } forControlEvents:UIControlEventTouchUpInside];
    showPortBtn.widthSize.equalTo(showPortBtn.widthSize).add(30);
    showPortBtn.heightSize.equalTo(showPortBtn.heightSize).add(20);
    [layout2 addSubview:showPortBtn];
    self.showPortBtn = showPortBtn;
    
    UIButton *showNewBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showNewBtn setTitle:@"最新" forState:UIControlStateNormal];
    showNewBtn.selected = YES;
    [showNewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showNewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showNewBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [showNewBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(240, 135, 23, 255) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [showNewBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [showNewBtn bk_addEventHandler:^(id sender) {
        // 点击显示最新信息
        UIButton *btn = sender;
        btn.selected = !btn.selected;
        if (btn.selected) {
            [receiveTV scrollRangeToVisible:NSMakeRange(receiveTV.text.length, 1)];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    showNewBtn.widthSize.equalTo(showNewBtn.widthSize).add(30);
    showNewBtn.heightSize.equalTo(showNewBtn.heightSize).add(20);
    [layout2 addSubview:showNewBtn];
    self.showNewBtn = showNewBtn;
    
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [recordBtn setTitle:@"记录" forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [recordBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [recordBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [recordBtn bk_addEventHandler:^(id sender) {
        // 点击记录日志
        __strong typeof(wself) sself = wself;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入日志文件名称" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 取消
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 确定
            UITextField *logFileNameTF = alert.textFields.firstObject;
            if (logFileNameTF.text.length == 0) {
                // 文件名称输入错误
                [SVProgressHUD showErrorWithStatus:@"请输入日志文件名称"];
                return;
            }
            NSString *dirName = sself.isMulticast ? @"Log/Udp/Multicast" : @"Log/Udp/Unicast";
            NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:dirName];
            NSFileManager *fm = [NSFileManager defaultManager];
            BOOL isDir;
            BOOL dirExit = [fm fileExistsAtPath:dirPath isDirectory:&isDir];
            if (!dirExit) {
                // 文件夹不存在，创建文件路径
                NSError *err;
                BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&err];
                if (!result || err) {
                    // 文件夹创建失败
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"创建日志文件失败: \n%@",err.localizedDescription]];
                    return;
                }
            }
            NSString *path = [dirPath stringByAppendingFormat:@"/NetTool_%@.log",logFileNameTF.text];
            NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:path append:NO];
            [stream open];
            NSMutableString *log = [NSMutableString string];
            [log appendString:sself.isMulticast ? @"UDP 组播 Socket 信息: \n" : @"UDP 单播/广播 Socket 信息: \n"];
            [log appendFormat:@"目标地址: %@\n",targetIpTF.text];
            [log appendFormat:@"本地端口: %d\n",sself.socket.localPort];
            [log appendFormat:@"目标端口: %@\n\n",targetIpTF.text];
            [log appendString:sself.receiveTV.text];
            NSData *logD = [log dataUsingEncoding:NSUTF8StringEncoding];
            [stream write:logD.bytes maxLength:logD.length];
            [SVProgressHUD showSuccessWithStatus:@"日志保存成功"];
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入日志文件名称";
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            textField.text = dateString;
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [sself.navigationController presentViewController:alert animated:YES completion:^{
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    recordBtn.widthSize.equalTo(recordBtn.widthSize).add(30);
    recordBtn.heightSize.equalTo(recordBtn.heightSize).add(20);
    [layout2 addSubview:recordBtn];
    
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterBtn setTitle:@"过滤" forState:UIControlStateNormal];
    [filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [filterBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [filterBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [filterBtn bk_addEventHandler:^(id sender) {
        // 点击过滤
        __strong typeof(wself) sself = wself;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"添加过滤条件" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:sself.receiveEncoding == kBinarySystem ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 添加过滤条件
            UITextField *filterTF = [[alert textFields] firstObject];
            NSString *ipReg = @"^((25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))$";
            NSPredicate *ipPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ipReg];
            if (filterTF.text.length > 0 && [ipPredicate evaluateWithObject:filterTF.text]) {
                [sself.filterArr addObject:filterTF.text];
                filterLayout.visibility = MyVisibility_Visible;
                [filterTable reloadData];
            }else {
                [SVProgressHUD showErrorWithStatus:@"请输入正确的 ip"];
            }
        }];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:sself.receiveEncoding == kEncodingUTF_8 ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 取消
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入过滤 ip";
        }];
        [alert addAction:okAction];
        [alert addAction:cancleAction];
        [sself.navigationController presentViewController:alert animated:YES completion:^{
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    filterBtn.widthSize.equalTo(filterBtn.widthSize).add(30);
    filterBtn.heightSize.equalTo(filterBtn.heightSize).add(20);
    [layout2 addSubview:filterBtn];
    
    UIButton *showReceiveStringBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showReceiveStringBtn setTitle:@"16 进制显示" forState:UIControlStateNormal];
    [showReceiveStringBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showReceiveStringBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showReceiveStringBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(110, 208, 47, 255) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [showReceiveStringBtn setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
        v.layer.masksToBounds = YES;
    }];
    [showReceiveStringBtn bk_addEventHandler:^(id sender) {
        // 点击显示格式
        __strong typeof(wself) sself = wself;
        UIButton *btn = sender;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择接收数据显示类型" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *binaryAction = [UIAlertAction actionWithTitle:@"16 进制显示" style:sself.receiveEncoding == kBinarySystem ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 显示 Hex 字符串
            sself.receiveEncoding = kBinarySystem;
            [btn setTitle:@"16 进制显示" forState:UIControlStateNormal];
            [layout2 setNeedsLayout];
        }];
        UIAlertAction *utf8Action = [UIAlertAction actionWithTitle:@"UTF-8 解码显示" style:sself.receiveEncoding == kEncodingUTF_8 ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 显示 UTF-8 字符串
            sself.receiveEncoding = kEncodingUTF_8;
            [btn setTitle:@"UTF-8 解码显示" forState:UIControlStateNormal];
            [layout2 setNeedsLayout];
        }];
        UIAlertAction *gb2312Action = [UIAlertAction actionWithTitle:@"GB2312 解码显示" style:sself.receiveEncoding == kEncodingGB2312 ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 显示 GB2312 字符串
            sself.receiveEncoding = kEncodingGB2312;
            [btn setTitle:@"GB2312 解码显示" forState:UIControlStateNormal];
            [layout2 setNeedsLayout];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:binaryAction];
        [alert addAction:utf8Action];
        [alert addAction:gb2312Action];
        [alert addAction:cancelAction];
        [sself.navigationController presentViewController:alert animated:YES completion:^{
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    showReceiveStringBtn.widthSize.equalTo(showReceiveStringBtn.widthSize).add(30);
    showReceiveStringBtn.heightSize.equalTo(showReceiveStringBtn.heightSize).add(20);
    [layout2 addSubview:showReceiveStringBtn];
    
    [rootLatout bk_whenTapped:^{
        __strong typeof(wself) sself = wself;
        [sself.navigationController.view endEditing:YES];
    }];
}

- (void)dealloc {
    NSLog(@"%@ -- dealloc",self.class);
    [_socket pauseReceiving];
    [_socket closeAfterSending];
}

- (void)showMessage:(NSString *)string {
    wq_excuteOnMain(^{
        NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:string];
        [messageAttrString addAttribute:NSForegroundColorAttributeName value:wq_colorWithHex(0x333333, 1.0) range:NSMakeRange(0, string.length)];
        [self showAttributeMessage:messageAttrString];
    });
}

- (void)showAttributeMessage:(NSAttributedString *)attributeString {
    wq_excuteOnMain(^{
        NSMutableAttributedString *msg = [[NSMutableAttributedString alloc] init];
        [msg appendAttributedString:[self.receiveTV.attributedText copy]];
        [msg appendAttributedString:attributeString];
        self.receiveTV.attributedText = [msg copy];
        if (self.showNewBtn.selected) {
            [self.receiveTV scrollRangeToVisible:NSMakeRange(self.receiveTV.text.length, 1)];
        }
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
didSendDataWithTag:(long)tag {
    wq_excuteOnMain(^{
        NSNumber *tagNum = [NSNumber numberWithInteger:tag];
        NSData *sendData;
        @synchronized (self.sendDic) {
            sendData = self.sendDic[tagNum];
        }
        if (sendData != nil) {
            NSMutableString *message = [[NSMutableString alloc] init];
            if (self.showTimeBtn.selected) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
                NSString *dateString = [formatter stringFromDate:[NSDate date]];
                [message appendString:dateString];
                [message appendString:@" "];
            }
            if (self.showIpBtn.selected) {
                [message appendString:self.targetIpTF.text];
                [message appendString:@" "];
            }
            if (self.showPortBtn.selected) {
                [message appendFormat:@": %@",self.targetPortTF.text];
                [message appendString:@" "];
            }
            switch (self.sendEncoding) {
                case kBinarySystem: {
                    // Hex 字符串转码
                    [message appendString:[NSString stringWithFormat:@"发送成功: %@\n\n",sendData]];
                }break;
                case kEncodingUTF_8: {
                    // UTF-8 编码
                    [message appendString:[NSString stringWithFormat:@"发送成功: %@\n\n",[[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding]]];
                }break;
                case kEncodingGB2312: {
                    // GB2312 编码
                    [message appendString:[NSString stringWithFormat:@"发送成功: %@\n\n",[[NSString alloc] initWithData:sendData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]]];
                }break;
                    
                default: {
                    [message appendString:[NSString stringWithFormat:@"发送成功: %@\n\n",sendData]];
                }break;
            }
            NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:message];
            [messageAttrString addAttribute:NSForegroundColorAttributeName value:wq_colorWithRGB(110, 208, 47, 255) range:NSMakeRange(0, message.length)];
            [self showAttributeMessage:messageAttrString];
        }
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
       dueToError:(NSError *)error {
    wq_excuteOnMain(^{
        NSNumber *tagNum = [NSNumber numberWithInteger:tag];
        NSData *sendData;
        @synchronized (self.sendDic) {
            sendData = self.sendDic[tagNum];
        }
        if (sendData != nil) {
            NSMutableString *message = [[NSMutableString alloc] init];
            if (self.showTimeBtn.selected) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
                NSString *dateString = [formatter stringFromDate:[NSDate date]];
                [message appendString:dateString];
                [message appendString:@" "];
            }
            if (self.showIpBtn.selected) {
                [message appendString:self.targetIpTF.text];
                [message appendString:@" "];
            }
            if (self.showPortBtn.selected) {
                [message appendFormat:@": %@",self.targetPortTF.text];
                [message appendString:@" "];
            }
            switch (self.sendEncoding) {
                case kBinarySystem: {
                    // Hex 字符串转码
                    [message appendString:[NSString stringWithFormat:@"发送失败: %@\n\n",sendData]];
                }break;
                case kEncodingUTF_8: {
                    // UTF-8 编码
                    [message appendString:[NSString stringWithFormat:@"发送失败: %@\n\n",[[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding]]];
                }break;
                case kEncodingGB2312: {
                    // GB2312 编码
                    [message appendString:[NSString stringWithFormat:@"发送失败: %@\n\n",[[NSString alloc] initWithData:sendData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]]];
                }break;
                    
                default: {
                    [message appendString:[NSString stringWithFormat:@"发送失败: %@\n\n",sendData]];
                }break;
            }
            NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:message];
            [messageAttrString addAttribute:NSForegroundColorAttributeName value:wq_colorWithRGB(163, 21, 39, 255) range:NSMakeRange(0, message.length)];
            [self showAttributeMessage:messageAttrString];
        }
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    wq_excuteOnMain(^{
        NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
        if (self.filterArr.count == 0 || [self.filterArr containsObject:host]) {
            NSMutableString *message = [[NSMutableString alloc] init];
            if (self.showTimeBtn.selected) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
                NSString *dateString = [formatter stringFromDate:[NSDate date]];
                [message appendString:dateString];
                [message appendString:@" "];
            }
            if (self.showIpBtn.selected) {
                [message appendString:host];
                [message appendString:@" "];
            }
            if (self.showPortBtn.selected) {
                int port = [GCDAsyncUdpSocket portFromAddress:address];
                [message appendFormat:@": %d",port];
                [message appendString:@" "];
            }
            switch (self.receiveEncoding) {
                case kBinarySystem: {
                    // Hex 字符串转码
                    [message appendString:[NSString stringWithFormat:@"%@\n\n",data]];
                }break;
                case kEncodingUTF_8: {
                    // UTF-8 编码
                    [message appendString:[NSString stringWithFormat:@"%@\n\n",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
                }break;
                case kEncodingGB2312: {
                    // GB2312 编码
                    [message appendString:[NSString stringWithFormat:@"%@\n\n",[[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]]];
                }break;
                    
                default: {
                    [message appendString:[NSString stringWithFormat:@"%@\n\n",data]];
                }break;
            }
            [self showMessage:message];
        }
    });
}
@end


@implementation WQUdpReceiveDelegateObject
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    CGPoint offset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    if (offset.y >= contentSize.height - CGRectGetHeight(self.vc.receiveTV.frame) + 3) {
        self.vc.showNewBtn.selected = YES;
    }else {
        self.vc.showNewBtn.selected = NO;
    }
}
@end


@implementation WQUdpFilterDelegateObject
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.vc.filterArr.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WQUdpFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WQUdpFilterCell class]) forIndexPath:indexPath];
    NSString *filter;
    @synchronized (self.vc.filterArr) {
        filter = self.vc.filterArr[indexPath.row];
    }
    cell.titleLab.text = filter;
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // 删除数组中的对应数据,注意cityList 要是可变的集合才能够进行删除或新增操作
        @synchronized (self.vc.filterArr) {
            [self.vc.filterArr removeObjectAtIndex:indexPath.row];
            
            if (self.vc.filterArr.count == 0) {
                self.vc.filterLayout.visibility = MyVisibility_Gone;
            }
        }
        //tableView刷新方式   设置tableView带动画效果 删除数据
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //取消编辑状态
        [tableView setEditing:NO animated:YES];
    }];
    return @[deleteAction];
}
@end


@implementation WQUdpFilterCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _rootLayout= [MyLinearLayout linearLayoutWithOrientation:MyOrientation_Horz];
        _rootLayout.leftPadding = 15;
        _rootLayout.topPadding = 5;
        _rootLayout.bottomPadding = 5;
        _rootLayout.cacheEstimatedRect = YES;
        _rootLayout.wrapContentHeight = YES;
        _rootLayout.widthSize.equalTo(self.contentView.widthSize);
        MyBorderline *bottomLine = [[MyBorderline alloc] init];
        bottomLine.color = wq_colorWithHex(0x666666, 1.0);
        _rootLayout.bottomBorderline = bottomLine;
        [self.contentView addSubview:_rootLayout];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.textColor = wq_colorWithHex(0x333333, 1.0);
        titleLab.font = [UIFont systemFontOfSize:12];
        titleLab.heightSize.equalTo(titleLab.heightSize).add(10);
        titleLab.widthSize.equalTo(_rootLayout.widthSize);
        [_rootLayout addSubview:titleLab];
        _titleLab = titleLab;
    }
    return self;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    if (@available(iOS 11.0, *)) {
        return [self.rootLayout sizeThatFits:CGSizeMake(targetSize.width - self.safeAreaInsets.left - self.safeAreaInsets.right, targetSize.height)];
    } else {
        return [self.rootLayout sizeThatFits:targetSize];
    }
}
@end
