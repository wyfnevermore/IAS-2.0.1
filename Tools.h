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

+(BOOL)activeOutside:(NSMutableArray*)outsideArray : (NSInteger)number :(CBPeripheral*)mPeripheral : (CBCharacteristic*)dianjicharacteristic :(CBCharacteristic*)ladengcharacteristic;

+ (NSString*)getRestData : (NSString*)projectIDstr : (NSString*)datastr;

+ (void)getModelRestData:(NSString*)projectIDstr;

+ (NSMutableArray*)getModelRestDataEverytime:(NSString*)projectIDstr:(uScanConfig)changedWorkFlow;

@end
