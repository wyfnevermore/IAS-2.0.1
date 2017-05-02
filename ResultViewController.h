//
//  ResultViewController.h
//  IAS
//
//  Created by wyfnevermore on 2017/3/30.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkFlowViewController.h"

@interface ResultViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *type;


@property (strong, nonatomic)NSMutableString* name;
@property (strong, nonatomic)NSString* pic;
@property (strong, nonatomic)NSMutableArray* dataXGDArray;
@property (strong, nonatomic)NSMutableArray* dataBCArray;

@end
