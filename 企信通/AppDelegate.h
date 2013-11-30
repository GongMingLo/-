//
//  AppDelegate.h
//  企信通
//
//  Created by apple on 13-11-30.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

typedef void(^CompletionBlock)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - XMPP属性及方法
/**
 *  全局的XMPPStream，只读属性
 */
@property (strong, nonatomic, readonly) XMPPStream *xmppStream;

/**
 *  是否注册用户标示
 */
@property (assign, nonatomic) BOOL isRegisterUser;

/**
 *  用户是否登录成功
 */
@property (assign, nonatomic) BOOL isUserLogon;

/**
 *  连接到服务器
 *
 *  注释：用户信息保存在系统偏好中
 *
 *  @param completion 连接正确的块代码
 *  @param faild      连接错误的块代码
 */
- (void)connectWithCompletion:(CompletionBlock)completion failed:(CompletionBlock)faild;

/**
 *  注销用户登录
 */
- (void)logout;

@end
