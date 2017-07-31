//
//  NetWork.h
//  IAS
//
//  Created by wyfnevermore on 2017/6/22.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "dlpdata.h"

@interface NetWork : NSObject

-(void)get;

-(void)post;

-(void)download;

-(void)upload;

-(void)networkStatusChangeAFN; //网络状态监听

- (NSMutableArray*)getModelRestData:(NSString*)projectIDstr :(uScanConfig)changedWorkFlow :(NSInteger)devicetype;//得到网络数据

@end
