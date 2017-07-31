//
//  Tools.h
//  IAS
//
//  Created by wyfnevermore on 2017/3/29.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AFNetworking/AFNetworking.h>
#import "dlpdata.h"

@interface Tools : NSObject


+ (NSString*)hexadecimalString:(NSData *)data;//NSData转NSString

+ (NSData*)dataWithHexstring:(NSString *)hexstring;//NSString转NSData

+ (NSString*)setModelType:(NSString*)typeStr : (UIImageView*)typeImg :(NSInteger)deviceType;//选择模型后换图片，改projectID

<<<<<<< HEAD
+(void)activeWorkFlow:(NSString*)workFlowStr :(CBPeripheral*)mPeripheral : (CBCharacteristic*)characteristic;//激活工作流

+ (NSString*)getRestData : (NSString*)projectIDstr : (NSString*)datastr;//请求检测结果

+ (void)getHttp;//请求模型数据，试下网络

+ (NSMutableArray*)getModelRestDataEverytime:(NSString*)projectIDstr :(uScanConfig)changedWorkFlow :(NSInteger)devicetype;//请求模型数据

+ (BOOL)isCbDataCurrent: (double*)cb : (int)workFlowPoints;//判断采集到的参比数据是否正确

+ (BOOL)isIntentDataCurrent: (double*)intent : (int)workFlowPoints;//判断采集的样品数据是否正确

+ (double)getScanTime : (NSData*)scanTimeData;//得到第一包数据后的处理得到的扫描时间

=======
+ (NSString*)getRestData : (NSString*)projectIDstr : (NSString*)datastr;//请求检测结果

+ (void)getHttp;
>>>>>>> origin/master


+ (BOOL)isCbDataCurrent: (double*)cb : (int)workFlowPoints;

+ (BOOL)isIntentDataCurrent: (double*)intent : (int)workFlowPoints;

@end
