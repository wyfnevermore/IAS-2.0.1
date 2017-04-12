//
//  Tools.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/29.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "Tools.h"

@implementation Tools

//将传入的NSData类型转换成NSString并返回
+ (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

//将传入的NSString类型转换成NSData并返回
+ (NSData*)dataWithHexstring:(NSString *)hexstring{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for(idx = 0; idx + 2 <= hexstring.length; idx += 2){
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//切换类型
+ (NSString*)setType:(NSString*)typeStr : (UIImageView*)typeImg{
    NSString *ProjectID;
    if ([typeStr containsString:@"乳胶"]) {
        [typeImg setImage:[UIImage imageNamed:@"rujiao"]];
        ProjectID = @"234";
    }
    if ([typeStr containsString:@"木材"]) {
        [typeImg setImage:[UIImage imageNamed:@"mucai"]];
        ProjectID = @"167";
    }
    if ([typeStr containsString:@"爬爬垫"]) {
        [typeImg setImage:[UIImage imageNamed:@"papadian"]];
        ProjectID = @"257";
    }
    if ([typeStr containsString:@"奶嘴"]) {
        [typeImg setImage:[UIImage imageNamed:@"naizui"]];
        ProjectID = @"265";
    }
    if ([typeStr containsString:@"珍珠粉"]) {
        [typeImg setImage:[UIImage imageNamed:@"zhenzhufen"]];
        ProjectID = @"252";
    }
    if ([typeStr containsString:@"保鲜膜"]) {
        [typeImg setImage:[UIImage imageNamed:@"baoxianmo"]];
        ProjectID = @"301";
    }
    if ([typeStr containsString:@"药品"]) {
        [typeImg setImage:[UIImage imageNamed:@"yaopin"]];
        ProjectID = @"471";
    }
    if ([typeStr containsString:@"奶粉"]) {
        [typeImg setImage:[UIImage imageNamed:@"naifen"]];
        ProjectID = @"87";
    }

    return ProjectID;
}

+(void)activeWorkFlow:(NSString*)workFlowStr :(CBPeripheral*)mPeripheral : (CBCharacteristic*)characteristic{
    NSData *workFlowObject = [Tools dataWithHexstring:workFlowStr];
    NSLog(@"工作流改为%@",workFlowStr);
    [mPeripheral writeValue:workFlowObject forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"%@",workFlowObject);
}


+(BOOL)activeOutside:(NSMutableArray*)outsideArray : (NSInteger)number :(CBPeripheral*)mPeripheral : (CBCharacteristic*)dianjicharacteristic :(CBCharacteristic*)ladengcharacteristic{
    NSString* liquidorsolid;
    NSString* outsidelight;
    NSString* dianji;
    NSData* liquidorsolidData;
    NSData* outsidelightData;
    NSData* dianjiData;
    if (outsideArray.count == 0) {
        NSLog(@"未受到外置数据");
        return NO;
    }else{
        liquidorsolid = [outsideArray[number] substringWithRange:NSMakeRange(2, 2)];
        outsidelight = [outsideArray[number] substringWithRange:NSMakeRange(4, 2)];
        dianji = [outsideArray[number] substringWithRange:NSMakeRange(6, 2)];
        liquidorsolidData = [Tools dataWithHexstring:liquidorsolid];
        outsidelightData = [Tools dataWithHexstring:outsidelight];
        dianjiData = [Tools dataWithHexstring:dianji];
        //外置灯
        if ([outsidelight intValue] == 1) {
            [mPeripheral writeValue:outsidelightData forCharacteristic:ladengcharacteristic type:CBCharacteristicWriteWithResponse];
            return NO;
        }else if ([outsidelight intValue] == 2){
            NSString* obj = @"00";
            [mPeripheral writeValue:[Tools dataWithHexstring:obj] forCharacteristic:ladengcharacteristic type:CBCharacteristicWriteWithResponse];
            return YES;
        }else{
            [mPeripheral writeValue:outsidelightData forCharacteristic:ladengcharacteristic type:CBCharacteristicWriteWithResponse];
            return NO;
        }
    }
}

@end
