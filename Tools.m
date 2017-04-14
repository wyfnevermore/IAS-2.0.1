//
//  Tools.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/29.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "Tools.h"

@implementation Tools

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



//激活工作流
+(void)activeWorkFlow:(NSString*)workFlowStr :(CBPeripheral*)mPeripheral : (CBCharacteristic*)characteristic{
    NSData *workFlowObject = [Tools dataWithHexstring:workFlowStr];
    NSLog(@"工作流改为%@",workFlowStr);
    [mPeripheral writeValue:workFlowObject forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"%@",workFlowObject);
}

//激活外部工作流
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

+ (NSString*)getRestData:(NSString*)projectIDstr : (NSString*)datastr{
    NSString* segueToResult;
    NSURL *url = [NSURL URLWithString:@"http://115.29.198.253:8088/WCF/Service/GetData"];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    //设置参数
    //设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //设置请求体
    NSDictionary *dicTest = @{@"Service" : @"SendSpectrumPakg",
                              @"DeviceCode" : @"11",
                              @"Data" : @{
                                      @"ProjectId" : projectIDstr,
                                      @"SpectrumData" : datastr
                                      }
                              };
    NSData *data2 = [NSJSONSerialization dataWithJSONObject:dicTest options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data2];
    //返回数据
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *receData = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receData);
    if ([receData containsString:@"异常"]) {
        segueToResult = @"数据异常";
    }else{
        switch ([projectIDstr intValue]) {
                //其它
            case 0:{
                NSArray *arrys01= [receData componentsSeparatedByString:@"@"];
                NSString* str01=(NSString *)arrys01[2];
                NSArray *arrys02= [str01 componentsSeparatedByString:@"\""];
                NSString* str02=(NSString *)arrys02[0];
                NSLog(@"%@",str02);
                segueToResult = str02;
                break;
            }
                //药品ok
            case 471:{
                NSArray *arrys471= [receData componentsSeparatedByString:@"\""];
                NSString* str471=(NSString *)arrys471[3];
                NSLog(@"%@",str471);
                segueToResult = str471;
                break;
            }
                //乳胶
            case 234:{
                NSArray *arrys234= [receData componentsSeparatedByString:@"\""];
                NSString* str234=(NSString *)arrys234[3];
                NSLog(@"%@",str234);
                segueToResult = str234;
                break;
            }
                //爬爬垫
            case 257:{
                NSArray *arrys257= [receData componentsSeparatedByString:@"\""];
                NSString* str257=(NSString *)arrys257[3];
                NSLog(@"%@",str257);
                segueToResult = str257;
                break;
            }
                //奶嘴
            case 265:{
                NSArray *arrys265= [receData componentsSeparatedByString:@"\""];
                NSString* str265=(NSString *)arrys265[3];
                NSLog(@"%@",str265);
                segueToResult = str265;
                break;
            }
                //珍珠粉
            case 252:{
                NSArray *arrys252= [receData componentsSeparatedByString:@"\""];
                NSString* str252=(NSString *)arrys252[3];
                NSLog(@"%@",str252);
                if ([str252 containsString:@"G"]) {
                    segueToResult = @"优质珍珠粉";
                }else if ([str252 containsString:@"L"]){
                    segueToResult = @"劣质珍珠粉";
                }
                break;
            }
                //保鲜膜
            case 301:{
                NSArray *arrys301= [receData componentsSeparatedByString:@"\""];
                NSString* str301=(NSString *)arrys301[3];
                NSLog(@"%@",str301);
                segueToResult = str301;
                break;
            }
            default:{
                NSArray *arrys1= [receData componentsSeparatedByString:@"\""];
                NSString* str1=(NSString *)arrys1[3];
                NSLog(@"%@",str1);
                segueToResult = str1;
                break;
            }
        }
    }
    return segueToResult;
}

//从模型中获取工作流
+ (void)getModelRestData:(NSString*)projectIDstr{
    //NSMutableArray* segueToResult;
    ///*
    NSString*result;
    NSString* urlStr = @"http://115.29.198.253:8088/WCF/Service/GetConfig/";
    urlStr = [urlStr stringByAppendingFormat:@"%@",projectIDstr];
    NSLog(@"%@",urlStr);
    
    //NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSLog(@"%@",data);
    result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",result);
    NSLog(@"继续执行");
}




@end
