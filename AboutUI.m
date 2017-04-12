//
//  AboutUI.m
//  Ble for IAS
//
//  Created by wyfnevermore on 2017/3/10.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

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


@end
