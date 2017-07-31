//
//  AboutUI.h
//  Ble for IAS
//
//  Created by wyfnevermore on 2017/3/10.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUI : UIView

- (void)setExtraCellLineHidden: (UITableView *)tableView;


+ (void)showIng:(NSString*)title : (UIWebView*)mloadingWebView :(UIView*)backView :(UILabel*)ingLabel;

- (UIViewController *)getCurrentVC;

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC;

@end
