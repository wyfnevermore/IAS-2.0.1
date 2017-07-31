//
//  AboutUI.m
//  Ble for IAS
//
//  Created by wyfnevermore on 2017/3/10.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT  [UIScreen mainScreen].bounds.size.height
#import "AboutUI.h"

@implementation AboutUI


//隐藏tableview下多余的横线，其实就用视图覆盖一下
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [view reloadInputViews];
}

+ (void)showIng:(NSString*)title : (UIWebView*)mloadingWebView :(UIView*)backView :(UILabel*)ingLabel{
    //1. 取出window
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //2. 创建背景视图
    backView.frame = window.bounds;
    //3. 背景颜色可以用多种方法
    if ([title containsString:@"连接设备"]) {
        backView.backgroundColor = [UIColor colorWithRed:28.0/255 green:33.0/255 blue:38.0/255 alpha:1];
        ingLabel.textColor = [UIColor whiteColor];
    }else if([title containsString:@"采集参比"]){
        backView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:1.0];
        ingLabel.textColor = [UIColor whiteColor];
    }else{
        backView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:1.0];
        ingLabel.textColor = [UIColor blackColor];
    }
    //backView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.85];
    [window addSubview:backView];
    
    //4. 把需要展示的控件添加上去
    mloadingWebView.hidden = NO;
    
    ingLabel.frame = CGRectMake(SCREENWIDTH*0.16, SCREENHEIGHT*0.58, SCREENWIDTH*0.7, SCREENHEIGHT*0.068);
    ingLabel.text = title;
    ingLabel.textAlignment = NSTextAlignmentCenter;
    ingLabel.font = [UIFont systemFontOfSize:25];
    
    
    //5. 出现动画简单
    [UIView animateWithDuration:0.1 animations:^{
        if ([title containsString:@"采集样品"]) {
            mloadingWebView.frame = CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.36, SCREENWIDTH*0.3,SCREENWIDTH*0.3);
        }else if([title containsString:@"采集参比"]){
            mloadingWebView.frame = CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.34, SCREENWIDTH*0.4,SCREENWIDTH*0.4);
        }else{
            mloadingWebView.frame = CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.33, SCREENWIDTH*0.8,SCREENWIDTH*0.6);
        }
    }];
    
    [window addSubview:mloadingWebView];
    [window addSubview:ingLabel];
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

@end
