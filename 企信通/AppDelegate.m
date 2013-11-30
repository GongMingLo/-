//
//  AppDelegate.m
//  企信通
//
//  Created by apple on 13-11-30.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginUser.h"
#import "NSString+Helper.h"

#define kNotificationUserLogonState @"NotificationUserLogon"

@interface AppDelegate()
{
    CompletionBlock     _completionBlock;   // 成功的块代码
    CompletionBlock     _faildBlock;        // 失败的块代码
    
    // XMPP重新连接XMPPStream
    XMPPReconnect   *_xmppReconnect;
}

// 设置XMPPStream
- (void)setupStream;
// 销毁XMPPStream并注销已注册的扩展模块
- (void)teardownStream;
// 通知服务器器用户上线
- (void)goOnline;
// 通知服务器器用户下线
- (void)goOffline;
// 连接到服务器
- (void)connect;
// 与服务器断开连接
- (void)disconnect;

@end

@implementation AppDelegate

#pragma mark 根据用户登录状态加载对应的Storyboard显示
- (void)showStoryboardWithLogonState:(BOOL)isUserLogon
{
    UIStoryboard *storyboard = nil;
    
    if (isUserLogon) {
        // 显示Main.storyboard
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    } else {
        // 显示Login.sotryboard
        storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    }
    
    // 在主线程队列负责切换Storyboard，而不影响后台代理的数据处理
    dispatch_async(dispatch_get_main_queue(), ^{
        // 如果在项目属性中，没有指定主界面（启动的Storyboard，self.window不会被实例化）
        // 把Storyboard的初始视图控制器设置为window的rootViewController
        [self.window setRootViewController:storyboard.instantiateInitialViewController];
        
        if (!self.window.isKeyWindow) {
            [self.window makeKeyAndVisible];
        }
    });
}

#pragma mark - AppDelegate方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 1. 实例化window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 2. 设置XMPPStream
    [self setupStream];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [self disconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 应用程序被激活后，直接连接，使用系统偏好中的保存的用户记录登录
    // 从而实现自动登录的效果！
    [self connect];
}

- (void)dealloc
{
    // 释放XMPP相关对象及扩展模块
    [self teardownStream];
}

#pragma mark - XMPP相关方法
// 设置XMPPStream
- (void)setupStream
{
    // 0. 方法被调用时，要求_xmppStream必须为nil，否则通过断言提示程序员，并终止程序运行！
    NSAssert(_xmppStream == nil, @"XMPPStream被多次实例化！");
    
    // 1. 实例化XMPPSteam
    _xmppStream = [[XMPPStream alloc] init];
    
    // 2. 添加代理
    // 由于所有网络请求都是做基于网络的数据处理，这些数据处理工作与界面UI无关。
    // 因此可以让代理方法在其他线城中运行，从而提高程序的运行性能，避免出现应用程序阻塞的情况
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // 3. 扩展模块
    // 3.1 重新连接模块
    _xmppReconnect = [[XMPPReconnect alloc] init];
    
    // 3.2 将重新连接模块添加到XMPPStream
    [_xmppReconnect activate:_xmppStream];
}

// 销毁XMPPStream并注销已注册的扩展模块
- (void)teardownStream
{
    // 1. 断开XMPPStream的连接
    [_xmppStream disconnect];
    
    // 2. 取消激活在setupStream方法中激活的扩展模块
    [_xmppReconnect deactivate];
    
    // 3. 内存清理
    _xmppStream = nil;
    _xmppReconnect = nil;
}

// 通知服务器器用户上线
- (void)goOnline
{
    // 1. 实例化一个”展现“，上线的报告，默认类型为：available
    XMPPPresence *presence = [XMPPPresence presence];
    // 2. 发送Presence给服务器
    // 服务器知道“我”上线后，只需要通知我的好友，而无需通知我，因此，此方法没有回调
    [_xmppStream sendElement:presence];
}

// 通知服务器器用户下线
- (void)goOffline
{
    // 1. 实例化一个”展现“，下线的报告
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    // 2. 发送Presence给服务器，通知服务器客户端下线
    [_xmppStream sendElement:presence];
}

// 连接到服务器
- (void)connect
{
    // 1. 如果XMPPStream当前已经连接，直接返回
    if ([_xmppStream isConnected]) {
        return;
    }
//    在C语言中if判断真假：非零即真，如果_xmppStream==nil下面这段代码，与上面的代码结果不同。
//    if (![_xmppStream isDisconnected]) {
//        return;
//    }
    
    // 2. 指定用户名、主机（服务器），连接时不需要password
    NSString *hostName = [[LoginUser sharedLoginUser] hostName];
    NSString *userName = [[LoginUser sharedLoginUser] myJIDName];
    
    // 如果没有主机名或用户名（通常第一次运行时会出现），直接显示登录窗口
    if ([hostName isEmptyString] || [userName isEmptyString]) {
        [self showStoryboardWithLogonState:NO];
        
        return;
    }
    
    // 3. 设置XMPPStream的JID和主机
    [_xmppStream setMyJID:[XMPPJID jidWithString:userName]];
    [_xmppStream setHostName:hostName];
    
    // 4. 开始连接
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
    // 提示：如果没有指定JID和hostName，才会出错，其他都不出错。
    if (error) {
        NSLog(@"连接请求发送出错 - %@", error.localizedDescription);
    } else {
        NSLog(@"连接请求发送成功！");
    }
}

#pragma mark 连接到服务器
- (void)connectWithCompletion:(CompletionBlock)completion failed:(CompletionBlock)faild
{
    // 1. 记录块代码
    _completionBlock = completion;
    _faildBlock = faild;
    
    // 2. 如果已经存在连接，先断开连接，然后再次连接
    if ([_xmppStream isConnected]) {
        [_xmppStream disconnect];
    }
    
    // 3. 连接到服务器
    [self connect];
}

// 与服务器断开连接
- (void)disconnect
{
    // 1. 通知服务器下线
    [self goOffline];
    // 2. XMPPStream断开连接
    [_xmppStream disconnect];
}

- (void)logout
{
    // 1. 通知服务器下线，并断开连接
    [self disconnect];
    
    // 2. 显示用户登录Storyboard
    [self showStoryboardWithLogonState:NO];
}

#pragma mark - 代理方法
#pragma mark 连接完成（如果服务器地址不对，就不会调用此方法）
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    // 从系统偏好读取用户密码
    NSString *password = [[LoginUser sharedLoginUser] password];
    
    if (_isRegisterUser) {
        // 用户注册，发送注册请求
        [_xmppStream registerWithPassword:password error:nil];
    } else {
        // 用户登录，发送身份验证请求
        [_xmppStream authenticateWithPassword:password error:nil];
    }
}

#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    _isRegisterUser = NO;
    
    // 注册成功，直接发送验证身份请求，从而触发后续的操作
    [_xmppStream authenticateWithPassword:[LoginUser sharedLoginUser].password error:nil];
}

#pragma mark 注册失败(用户名已经存在)
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    _isRegisterUser = NO;
    if (_faildBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _faildBlock();
        });
    }
}

#pragma mark 身份验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    if (_completionBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _completionBlock();
        });
    }
    
    // 通知服务器用户上线
    [self goOnline];
    
    // 显示主Storyboard
    [self showStoryboardWithLogonState:YES];
}

#pragma mark 密码错误，身份验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    if (_faildBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _faildBlock();
        });
    }
    
    // 显示用户登录Storyboard
    [self showStoryboardWithLogonState:NO];
}

@end
