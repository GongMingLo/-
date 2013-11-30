//
//  LoginViewController.m
//  02.用户登录&注册
//
//  Created by apple on 13-11-28.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "LoginViewController.h"
#import "NSString+Helper.h"
#import "AppDelegate.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *hostNameText;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

#pragma mark - AppDelegate 的助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 拉伸按钮背景图片
    // 1) 登录按钮
    UIImage *loginImage = [UIImage imageNamed:@"LoginGreenBigBtn"];
    loginImage = [loginImage stretchableImageWithLeftCapWidth:loginImage.size.width * 0.5 topCapHeight:loginImage.size.height * 0.5];
    [_loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
    
    // 2) 注册按钮
    UIImage *registerImage = [UIImage imageNamed:@"LoginwhiteBtn"];
    registerImage = [registerImage stretchableImageWithLeftCapWidth:registerImage.size.width * 0.5 topCapHeight:registerImage.size.height * 0.5];
    [_registerButton setBackgroundImage:registerImage forState:UIControlStateNormal];
    
//    _userNameText.text = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPUserNameKey];
//    _hostNameText.text = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPHostNameKey];

}

#pragma mark UITextField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameText) {
        [_passwordText becomeFirstResponder];
    } else if (textField == _passwordText) {
        [_hostNameText becomeFirstResponder];
    } else {
        [self userLoginAndRegister:nil];
    }
    
    return YES;
}

#pragma mark - Actions
#pragma mark 用户登录
- (IBAction)userLoginAndRegister:(UIButton *)button
{
    // 1. 检查用户输入是否完整，在商业软件中，处理用户输入时
    // 通常会截断字符串前后的空格（密码除外），从而可以最大程度地降低用户输入错误
    NSString *userName = [_userNameText.text trimString];
    // 用些用户会使用空格做密码，因此密码不能去除空白字符
    NSString *password = _passwordText.text;
    NSString *hostName = [_hostNameText.text trimString];
    
    if ([userName isEmptyString] ||
        [password isEmptyString] ||
        [hostName isEmptyString]) {
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录信息不完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alter show];
        
        return;
    }
    
    // 2. 将用户登录信息写入系统偏好
//    [userName saveToNSDefaultsWithKey:kXMPPUserNameKey];
//    [password saveToNSDefaultsWithKey:kXMPPPasswordKey];
//    [hostName saveToNSDefaultsWithKey:kXMPPHostNameKey];
    
    // 3. 让AppDelegate开始连接
    // 告诉AppDelegate，当前是注册用户
    NSString *actionName = nil;
    
//    if (button.tag == 1) {
//        [self appDelegate].isRegisterUser = YES;
//        actionName = @"注册用户";
//    } else {
//        actionName = @"用户登录";
//    }
//    
//    [[self appDelegate] connectWithCompletion:^{
//        NSLog(@"%@成功！", actionName);
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLogonState object:nil];
//        
//    } failed:^{
//        NSLog(@"%@失败！", actionName);
//    }];
}

@end
