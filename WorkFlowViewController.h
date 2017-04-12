//
//  WorkFlowViewController.h
//  IAS
//
//  Created by wyfnevermore on 2017/3/30.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "AboutUI.h"

//声明一个协议
@protocol WorkFlowChooseDelegate<NSObject>;

- (void)passValue:(NSInteger)WorkfNo;

@end

@interface WorkFlowViewController : UIViewController
@property (strong,nonatomic)NSIndexPath *lastpath;
@property (strong,nonatomic)NSIndexPath *oldpath;
@property (strong,nonatomic)NSMutableArray *configName;
@property (strong,nonatomic)NSMutableArray *configurationDetail;
@property (assign,nonatomic)NSInteger returnWorkFlow;
@property (assign,nonatomic)bool isClickWorkFlow;

@property (weak, nonatomic) IBOutlet UITableView *tableViewC;

//声明一个使用以上代理的 对象
@property (weak) id delegate;

@end
