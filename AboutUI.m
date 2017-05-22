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

+ (void)showIng:(NSString*)title :(UIActivityIndicatorView*)mActivityInView :(UIView*)backView :(UILabel*)ingLabel{
    //1. 取出window
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //2. 创建背景视图
    backView.frame = window.bounds;
    //3. 背景颜色可以用多种方法
    backView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.9];
    //backView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.85];
    [window addSubview:backView];
    //4. 把需要展示的控件添加上去
    ingLabel.frame = CGRectMake(SCREENWIDTH*0.16, SCREENHEIGHT*0.56, SCREENWIDTH*0.7, SCREENHEIGHT*0.068);
    ingLabel.text = title;
    ingLabel.textColor = [UIColor whiteColor];
    ingLabel.textAlignment = NSTextAlignmentCenter;
    ingLabel.font = [UIFont systemFontOfSize:25];
    [window addSubview:ingLabel];
    
    //mActivityInView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    mActivityInView.center = CGPointMake(SCREENWIDTH*0.5f, SCREENHEIGHT*0.45f);//只能设置中心，不能设置大小
    mActivityInView.color = [UIColor whiteColor]; // 改变圈圈的颜色
    CGAffineTransform transformInit = CGAffineTransformMakeScale(0.1f, 0.1f);
    mActivityInView.transform = transformInit;
    [mActivityInView startAnimating]; // 开始旋转
    [window addSubview:mActivityInView];
    
    //5. 出现动画简单
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform transformNormal = CGAffineTransformMakeScale(3.0f, 3.0f);
        mActivityInView.transform = transformNormal;
    }];
}

@end
