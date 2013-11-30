//
//  VCardViewController.m
//  企信通
//
//  Created by apple on 13-11-30.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "VCardViewController.h"
#import "AppDelegate.h"

@interface VCardViewController ()

@end

@implementation VCardViewController

#pragma mark - AppDelegate 的助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - 注销用户登录
- (IBAction)logout:(id)sender
{
    [[self appDelegate] logout];
}

@end
