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
#import "dlpdata.h"

@interface Tools : NSObject

+ (NSString*)hexadecimalString:(NSData *)data;

+ (NSData*)dataWithHexstring:(NSString *)hexstring;

+ (NSString*)setModelType:(NSString*)typeStr : (UIImageView*)typeImg :(NSInteger)deviceType;

+(void)activeWorkFlow:(NSString*)workFlowStr :(CBPeripheral*)mPeripheral : (CBCharacteristic*)characteristic;

+ (NSString*)getRestData : (NSString*)projectIDstr : (NSString*)datastr;//请求检测结果

+ (void)getHttp;

+ (NSMutableArray*)getModelRestDataEverytime:(NSString*)projectIDstr :(uScanConfig)changedWorkFlow :(NSInteger)devicetype;

+ (BOOL)isCbDataCurrent: (double*)cb : (int)workFlowPoints;

+ (BOOL)isIntentDataCurrent: (double*)intent : (int)workFlowPoints;

@end
