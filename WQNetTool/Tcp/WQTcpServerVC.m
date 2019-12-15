//
//  WQTcpServerVC.m
//  WQNetTool
//
//  Created by iOS on 2019/9/1.
//  Copyright © 2019 shenbao. All rights reserved.
//

#import <objc/runtime.h>
#import "WQTcpServerVC.h"

@interface GCDAsyncSocket (WQTcpServer)
/** 客户端是否被选中 */
@property (nonatomic, assign) BOOL selected;
/** 客户端 ip */
@property (nonatomic, copy, nullable) NSString *clientHost;
/** 客户端 port */
@property (nonatomic, assign) int clientPort;
@end

@interface WQClientDelegateObject : NSObject
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, weak) WQTcpServerVC *vc;
@end

@interface WQTcpServerFilterDelegateObject : NSObject
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, weak) WQTcpServerVC *vc;
@end

@interface WQTcpServerReceiveDelegateObject : NSObject
<
    UITextViewDelegate
>
@property (nonatomic, weak) WQTcpServerVC *vc;
@end

@interface WQClientCell : UITableViewCell
@property (nonatomic, weak, readonly) UILabel *titleLab;
@property (nonatomic, strong, readonly) MyLinearLayout *rootLayout;
@end

@interface WQTcpServerFilterCell : UITableViewCell
@property (nonatomic, weak, readonly) UILabel *titleLab;
@property (nonatomic, strong, readonly) MyLinearLayout *rootLayout;
@end

@interface WQTcpServerVC ()
<
    GCDAsyncSocketDelegate
>
/** TCP Socket */
@property (nonatomic, strong) GCDAsyncSocket *socket;
/** 已连接客户端 Socket */
@property (nonatomic, strong) NSMutableArray<GCDAsyncSocket *> *clients;
/** 发送数据数组 */
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSNumber *, NSData *> *sendDic;
/** 服务器端口输入框 */
@property (nonatomic, weak) UITextField *serverPortTF;
/** 客户端列表 TableView 代理 */
@property (nonatomic, strong) WQClientDelegateObject *clientTableDelegate;
/** 客户端列表 */
@property (nonatomic, weak) UITableView *clientTable;
/** Socket 连接按钮 */
@property (nonatomic, weak) UIButton *socketOperBtn;
/** 接收框 */
@property (nonatomic, weak) IQTextView *receiveTV;
/** 接收框 TextView 代理 */
@property (nonatomic, strong) WQTcpServerReceiveDelegateObject *receiveTVDelegate;
/** 清除数据 */
@property (nonatomic, weak) UIButton *clearBtn;
/** 显示时间 */
@property (nonatomic, weak) UIButton *showTimeBtn;
/** 显示 remote ip */
@property (nonatomic, weak) UIButton *showIpBtn;
/** 显示 remote port */
@property (nonatomic, weak) UIButton *showPortBtn;
/** 显示最新信息 */
@property (nonatomic, weak) UIButton *showNewBtn;
/** 保存日志 */
@property (nonatomic, weak) UIButton *recordBtn;
/** 发送数据类型 */
@property (nonatomic, assign) WQNetToolEncoding sendEncoding;
/** 显示类型 */
@property (nonatomic, assign) WQNetToolEncoding receiveEncoding;
/** 过滤数组 */
@property (nonatomic, strong) NSMutableArray<NSString *> *filterArr;
/** 过滤列表 TableView 代理 */
@property (nonatomic, strong) WQTcpServerFilterDelegateObject *filterTableDelegate;
/** 过滤布局 */
@property (nonatomic, weak) MyLinearLayout *filterLayout;
@end

@implementation WQTcpServerVC
- (GCDAsyncSocket *)socket {
    if (_socket == nil) {
        dispatch_queue_t delegateQ = dispatch_queue_create("NetTool Delegate Queue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t socketQ = dispatch_queue_create("NetTool Socket Queue", DISPATCH_QUEUE_SERIAL);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:delegateQ socketQueue:socketQ];
    }
    return _socket;
}

- (NSMutableDictionary *)sendDic {
    if (_sendDic == nil) {
        _sendDic = [[NSMutableDictionary alloc] init];
    }
    return _sendDic;
}

- (NSMutableArray<GCDAsyncSocket *> *)clients {
    if (_clients == nil) {
        _clients = [[NSMutableArray alloc] init];
    }
    return _clients;
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
    
    // 服务器信息
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
    
    UITextField *serverPortTF = [[UITextField alloc] init];
    serverPortTF.placeholder = @"请输入服务器端口号";
    serverPortTF.keyboardType = UIKeyboardTypeNumberPad;
    serverPortTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    serverPortTF.font = [UIFont systemFontOfSize:15];
    serverPortTF.textColor = wq_colorWithHex(0x333333, 1.0);
    serverPortTF.layer.borderWidth = 1.0;
    serverPortTF.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    serverPortTF.layer.cornerRadius = 3.0;
    serverPortTF.leftViewMode = UITextFieldViewModeAlways;
    serverPortTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    serverPortTF.heightSize.equalTo(serverPortTF.heightSize).add(10);
    [layout00 addSubview:serverPortTF];
    self.serverPortTF = serverPortTF;
    
    UIButton *socketOperBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    socketOperBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [socketOperBtn setTitle:@"创建服务器" forState:UIControlStateNormal];
    [socketOperBtn setTitle:@"关闭服务器" forState:UIControlStateSelected];
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
        UIButton *btn = (UIButton *)sender;
        if (serverPortTF.text.length > 0) {
            if (btn.selected) {
                // 关闭
                @synchronized (sself.clients) {
                    for (GCDAsyncSocket *client in sself.clients) {
                        [client disconnect];
                    }
                }
                [sself.socket disconnect];
                sself.socket = nil;
                btn.selected = !btn.selected;
            }else {
                // 创建
                NSError *err;
                BOOL result = [sself.socket acceptOnPort:serverPortTF.text.intValue error:&err];
                NSMutableString *message = [[NSMutableString alloc] init];
                UIColor *color;
                if (sself.showTimeBtn.selected) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
                    NSString *dateString = [formatter stringFromDate:[NSDate date]];
                    [message appendString:dateString];
                    [message appendString:@" "];
                }
                if (!result || err) {
                    // 创建失败
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"创建服务器失败: %@",err.localizedDescription]];
                    [message appendFormat:@"创建服务器失败 %@ -- error: %@\n\n",serverPortTF.text,err.localizedDescription];
                    color = wq_colorWithRGB(163, 21, 39, 255);
                }else {
                    // 创建成功
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"服务器创建成功\n绑定端口: %@",serverPortTF.text]];
                    [message appendFormat:@"创建服务器成功: %@:%d\n\n",[UIDevice wq_getIpAddress],sself.socket.localPort];
                    color = wq_colorWithRGB(27, 109, 236, 255);
                    btn.selected = !btn.selected;
                }
                NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:message];
                [messageAttrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, message.length)];
                [sself showAttributeMessage:messageAttrString];
            }
            serverPortTF.userInteractionEnabled = !btn.selected;
            serverPortTF.textColor = btn.selected ? wq_colorWithHex(0xcccccc, 1.0) : wq_colorWithHex(0x333333, 1.0);
            serverPortTF.layer.borderColor = btn.selected ? wq_colorWithHex(0xcccccc, 1.0).CGColor : wq_colorWithHex(0x333333, 1.0).CGColor;
        }else {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的端口号"];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [layout01 addSubview:socketOperBtn];
    self.socketOperBtn = socketOperBtn;
    
    // 客户端列表
    UILabel *clientLab = [[UILabel alloc] init];
    clientLab.wrapContentSize = YES;
    NSMutableAttributedString *clientTitle = [[NSMutableAttributedString alloc] initWithString:@"客户端:"];
    [clientTitle addAttribute:NSForegroundColorAttributeName value:wq_colorWithHex(0x333333, 1.0) range:NSMakeRange(0, clientTitle.length)];
    [clientTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, clientTitle.length)];
    NSMutableAttributedString *clientSubTitle = [[NSMutableAttributedString alloc] initWithString:@" (选中客户端后可将数据发送到相应的客户端)"];
    [clientSubTitle addAttribute:NSForegroundColorAttributeName value:wq_colorWithHex(0xcccccc, 1.0) range:NSMakeRange(0, clientSubTitle.length)];
    [clientSubTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, clientSubTitle.length)];
    NSMutableAttributedString *clientText = [[NSMutableAttributedString alloc] init];
    [clientText appendAttributedString:clientTitle];
    [clientText appendAttributedString:clientSubTitle];
    clientLab.attributedText = clientText;
    [rootLatout addSubview:clientLab];
    
    WQClientDelegateObject *clientTableDelegate = [[WQClientDelegateObject alloc] init];
    clientTableDelegate.vc = self;
    self.clientTableDelegate = clientTableDelegate;
    UITableView *clientTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    clientTable.delegate = clientTableDelegate;
    clientTable.dataSource = clientTableDelegate;
    clientTable.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    clientTable.layer.borderWidth = 1.0;
    clientTable.delaysContentTouches = NO;
    clientTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [clientTable registerClass:[WQClientCell class] forCellReuseIdentifier:NSStringFromClass([WQClientCell class])];
    clientTable.widthSize.equalTo(rootLatout.widthSize);
    clientTable.heightSize.equalTo(@80);
    [clientTable setViewLayoutCompleteBlock:^(MyBaseLayout *layout, UIView *v) {
        v.layer.cornerRadius = 3.0;
    }];
    [rootLatout addSubview:clientTable];
    self.clientTable = clientTable;
    
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
            // 发送二进制数据
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
            @synchronized (sself.clients) {
                [sself.clients bk_each:^(id obj) {
                    GCDAsyncSocket *client = obj;
                    if (client.selected) {
                        @synchronized (sself.sendDic) {
                            sself.sendDic[[NSNumber numberWithInteger:++tag]] = data;
                        }
                        [client writeData:data withTimeout:5 tag:tag];
                    }
                }];
            }
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
    
    WQTcpServerFilterDelegateObject *filterTableDelegate = [[WQTcpServerFilterDelegateObject alloc] init];
    filterTableDelegate.vc = self;
    self.filterTableDelegate = filterTableDelegate;
    UITableView *filterTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    filterTable.delegate = filterTableDelegate;
    filterTable.dataSource = filterTableDelegate;
    filterTable.layer.borderColor = wq_colorWithHex(0x333333, 1.0).CGColor;
    filterTable.layer.borderWidth = 1.0;
    filterTable.delaysContentTouches = NO;
    filterTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [filterTable registerClass:[WQTcpServerFilterCell class] forCellReuseIdentifier:NSStringFromClass([WQTcpServerFilterCell class])];
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
    
    WQTcpServerReceiveDelegateObject *receiveTVDelegate = [[WQTcpServerReceiveDelegateObject alloc] init];
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
    self.clearBtn = clearBtn;
    
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
            NSString *dirName = @"Log/Tcp/Server";
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
            [log appendString:@"TCP 服务端 Socket 信息: \n"];
            [log appendFormat:@"服务器端口: %d\n\n",sself.socket.localPort];
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
    [showReceiveStringBtn setBackgroundImage:[UIImage wq_imageWithColor:wq_colorWithRGB(240, 135, 23, 255) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
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
    self.recordBtn = recordBtn;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [self.navigationController.view endEditing:YES];
}

- (void)dealloc {
    NSLog(@"%@ -- dealloc",self.class);
    @synchronized (self.clients) {
        for (GCDAsyncSocket *client in self.clients) {
            [client disconnect];
        }
    }
    [_socket disconnect];
}

- (void)showMessage:(NSString *)string {
    wq_excuteOnMain(^{
        NSMutableAttributedString *sendAttrString = [[NSMutableAttributedString alloc] initWithString:string];
        [sendAttrString addAttribute:NSForegroundColorAttributeName value:wq_colorWithHex(0x333333, 1.0) range:NSMakeRange(0, string.length)];
        [self showAttributeMessage:sendAttrString];
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

- (void)socket:(GCDAsyncSocket *)sock
didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    wq_excuteOnMain(^{
        newSocket.clientPort = newSocket.connectedPort;
        newSocket.clientHost = newSocket.connectedHost;
        NSMutableString *message = [[NSMutableString alloc] init];
        if (self.showTimeBtn.selected) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            [message appendString:dateString];
            [message appendString:@" "];
        }
        [message appendString:[NSString stringWithFormat:@"客户端连接成功: %@:%d\n\n",newSocket.connectedHost,newSocket.connectedPort]];
        NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:message];
        [messageAttrString addAttribute:NSForegroundColorAttributeName value:wq_colorWithRGB(27, 109, 236, 255) range:NSMakeRange(0, message.length)];
        [self showAttributeMessage:messageAttrString];
        @synchronized (self.clients) {
            [self.clients addObject:newSocket];
        }
        [self.clientTable beginUpdates];
        [self.clientTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.clients.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.clientTable endUpdates];
    });
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock
didWriteDataWithTag:(long)tag {
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
                [message appendString:sock.connectedHost];
                [message appendString:@" "];
            }
            if (self.showPortBtn.selected) {
                [message appendFormat:@": %d",sock.connectedPort];
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

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)err {
    wq_excuteOnMain(^{
        NSMutableString *message = [[NSMutableString alloc] init];
        UIColor *color;
        if (self.showTimeBtn.selected) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            [message appendString:dateString];
            [message appendString:@" "];
        }
        NSInteger idx = [self.clients indexOfObject:sock];
        NSString *disconnectedSocketName = @"";
        NSString *clientAddress = @"";
        if (idx != NSNotFound) {
            @synchronized (self.clients) {
                [self.clients removeObject:sock];
            }
            [self.clientTable beginUpdates];
            [self.clientTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [self.clientTable endUpdates];
            disconnectedSocketName = @"客户端";
            clientAddress = [NSString stringWithFormat:@" %@:%d",sock.clientHost,sock.clientPort];
        }else {
            // 服务器关闭
            disconnectedSocketName = @"服务器";
        }
        if (err) {
            [message appendFormat:@"%@异常断开%@ -- error: %@\n\n",disconnectedSocketName,clientAddress,err.localizedDescription];
            color = wq_colorWithRGB(163, 21, 39, 255);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@异常断开\n%@",disconnectedSocketName,err.localizedDescription]];
        }else {
            [message appendFormat:@"%@断开连接%@\n\n",disconnectedSocketName,clientAddress];
            color = wq_colorWithRGB(27, 109, 236, 255);
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@断开连接%@",disconnectedSocketName,clientAddress]];
        }
        NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:message];
        [messageAttrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, message.length)];
        [self showAttributeMessage:messageAttrString];
    });
}

- (void)socket:(GCDAsyncSocket *)sock
   didReadData:(NSData *)data
       withTag:(long)tag {
    wq_excuteOnMain(^{
        NSString *host = sock.connectedHost;
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
                [message appendFormat:@": %d",sock.connectedPort];
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
            [self showMessage:[message copy]];
        }
    });
    [sock readDataWithTimeout:-1 tag:0];
}
@end


@implementation GCDAsyncSocket (WQTcpServer)
static const void *selectedKey = &selectedKey;
static const void *clientHostKey = &clientHostKey;
static const void *clientPortKey = &clientPortKey;

- (void)setSelected:(BOOL)selected {
    objc_setAssociatedObject(self, selectedKey, [NSNumber numberWithBool:selected], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)selected {
    NSNumber *num = objc_getAssociatedObject(self, selectedKey);
    return [num boolValue];
}

- (void)setClientHost:(NSString *)clientHost {
    objc_setAssociatedObject(self, clientHostKey, clientHost, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)clientHost {
    return objc_getAssociatedObject(self, clientHostKey);
}

- (void)setClientPort:(int)clientPort {
    objc_setAssociatedObject(self, clientPortKey, [NSNumber numberWithInt:clientPort], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)clientPort {
    NSNumber *num = objc_getAssociatedObject(self, clientPortKey);
    return [num intValue];
}
@end


@implementation WQTcpServerFilterDelegateObject
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.vc.filterArr.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WQTcpServerFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WQTcpServerFilterCell class]) forIndexPath:indexPath];
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


@implementation WQClientDelegateObject
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.vc.clients.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WQClientCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WQClientCell class]) forIndexPath:indexPath];
    GCDAsyncSocket *socket;
    @synchronized (self.vc.clients) {
        socket = self.vc.clients[indexPath.row];
    }
    cell.titleLab.text = [NSString stringWithFormat:@"%@:%d",socket.connectedHost,socket.connectedPort];
    if (socket.selected) {
        cell.rootLayout.backgroundColor = wq_colorWithRGB(240, 135, 23, 255);
    }else {
        cell.rootLayout.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GCDAsyncSocket *socket = self.vc.clients[indexPath.row];
    socket.selected = !socket.selected;
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"断开" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        GCDAsyncSocket *socket;
        @synchronized (self.vc.clients) {
            socket = self.vc.clients[indexPath.row];
        }
        [socket disconnect];
    }];
    return @[deleteAction];
}
@end


@implementation WQTcpServerReceiveDelegateObject
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


@implementation WQClientCell
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


@implementation WQTcpServerFilterCell
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
