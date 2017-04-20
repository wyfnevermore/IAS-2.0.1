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
+ (NSString*)setModelType:(NSString*)typeStr : (UIImageView*)typeImg :(NSInteger)deviceType{
    NSString *ProjectID;
    if (deviceType == 0) {
        if ([typeStr containsString:@"片"]) {
            [typeImg setImage:[UIImage imageNamed:@"yaopian"]];
            ProjectID = @"581";
        }
        if ([typeStr containsString:@"胶"]) {
            [typeImg setImage:[UIImage imageNamed:@"jiaonang"]];
            ProjectID = @"616";
        }
    }else if (deviceType == 1){
        [typeImg setImage:[UIImage imageNamed:@"yaopian"]];
        ProjectID = @"581";
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
        NSArray *arrys1= [receData componentsSeparatedByString:@"\""];
        NSString* str1=(NSString *)arrys1[3];
        NSLog(@"%@",str1);
        segueToResult = str1;
    }
    return segueToResult;
}

//从模型中获取工作流
+ (void)getModelRestData:(NSString*)projectIDstr{
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
    if (result != nil) {
        NSLog(@"%@",result);
        NSLog(@"继续");
    }
}

//从模型中获取工作流
+ (NSMutableArray*)getModelRestDataEverytime:(NSString*)projectIDstr :(uScanConfig)changedWorkFlow :(NSInteger)devicetype{
    //http,得到了当前模型的工作流信息
    NSString* result;
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
    
    //处理得到的工作流数据
    NSArray *arrysall= [result componentsSeparatedByString:@","];
    NSString* strGatherAverage = arrysall[1];
    NSString* strGatherLength = arrysall[2];
    NSString* strGatherStyle = arrysall[3];
    NSString* strLampMode = arrysall[4];
    NSString* strMotorMode = arrysall[5];
    NSString* strSampleMode = arrysall[6];
    NSString* strWaveEnd = arrysall[7];
    NSString* strWaveStart = arrysall[8];
    NSString* strWaveWidth = arrysall[9];
    NSString* strProductType = arrysall[10];
    
    NSArray *arrGatherAverage = [strGatherAverage componentsSeparatedByString:@":"];
    NSString* gatherAverage = arrGatherAverage[1];//平均次数
    NSLog(@"平均次数:%@",gatherAverage);
    
    NSArray *arrGatherLength = [strGatherLength componentsSeparatedByString:@":"];
    NSString* gatherLength = arrGatherLength[1];//点数
    NSLog(@"点数:%@",gatherLength);
    
    NSArray *arrGatherStyle = [strGatherStyle componentsSeparatedByString:@":"];
    NSString* gatherStyle = arrGatherStyle[1];//扫描类型
    NSLog(@"扫描类型:%@",gatherStyle);
    
    NSArray *arrWaveEnd = [strWaveEnd componentsSeparatedByString:@":"];
    NSString* waveEnd = arrWaveEnd[1];//波尾
    NSLog(@"波尾:%@",waveEnd);
    
    NSArray *arrWaveStart = [strWaveStart componentsSeparatedByString:@":"];
    NSString* waveStart = arrWaveStart[1];//波头
    NSLog(@"波头:%@",waveStart);
    
    NSArray *arrWaveWidth = [strWaveWidth componentsSeparatedByString:@":"];
    NSString* waveWidth = arrWaveWidth[1];//频率宽度
    NSLog(@"频率宽度:%@",waveWidth);
    
    NSArray *arrProductType = [strProductType componentsSeparatedByString:@":"];
    NSString* productType = arrProductType[1];
    productType = [productType substringWithRange:NSMakeRange(0, 1)];
    NSLog(@"%@,设备名称，0为手持，1为小罐子，2为土星",productType);
    
    //外部工作流参数
    NSArray *arrSampleMode = [strSampleMode componentsSeparatedByString:@":"];
    NSString* sampleMode = arrSampleMode[1];
    NSLog(@"固态液态:%@",sampleMode);
    NSArray *arrLampMode = [strLampMode componentsSeparatedByString:@":"];
    NSString* lampMode = arrLampMode[1];
    NSLog(@"外置灯:%@",lampMode);
    NSArray *arrMotorMode = [strMotorMode componentsSeparatedByString:@":"];
    NSString* motorMode = arrMotorMode[1];
    NSLog(@"转机:%@",motorMode);
    
    //拼接数据
    WorkFlowExt outsideWorkFlow;
    NSMutableArray *returnArr = [[NSMutableArray alloc]init];
    char returnWorkFlowData[212];
    char returnWorkFlowDataExt[212];
    //模型中已经获取到工作流
    uScanConfig transConfig;
    transConfig = changedWorkFlow;
    //和http数据拼接
    transConfig.slewScanCfg.section[0].num_patterns = 420;//点数当前都是420，后面差分成801
    transConfig.slewScanCfg.section[0].width_px = [waveWidth intValue];
    transConfig.slewScanCfg.section[0].section_scan_type = [gatherStyle intValue];
    transConfig.slewScanCfg.head.num_repeats = [gatherAverage intValue];
    transConfig.slewScanCfg.section[0].wavelength_start_nm = [waveStart intValue];
    transConfig.slewScanCfg.section[0].wavelength_end_nm = [waveEnd intValue];
    outsideWorkFlow.sampleobj = [sampleMode intValue];
    outsideWorkFlow.lampmode = [lampMode intValue];
    outsideWorkFlow.motormode = [motorMode intValue];
    
    //得到要写给蓝牙的数据块
    bool getdata = getScanConfigBuf(transConfig, outsideWorkFlow, returnWorkFlowData, returnWorkFlowDataExt);//得到数据块
    NSLog(@"res:%d",getdata);
    
    //处理得到的数据块，把获取的char数组赋给byte数组再转成NSdata，转成nsstring
    //转换原来的工作流数据
    NSUInteger len = 155;
    Byte *byteData = (Byte*)malloc(len);
    for (int i = 0; i < 155; i++) {
        byteData[i] = returnWorkFlowData[i];
    }
    NSData *adata = [[NSData alloc] initWithBytes:byteData length:155];
    NSLog(@"%@",adata);
    NSString* cutStr = [Tools hexadecimalString:adata];
    NSLog(@"%@",cutStr);
    
    //转换外部额外工作流的数据
    Byte *byteDataExt = (Byte*)malloc(3);
    for (int i = 0; i < 3; i++) {
        byteDataExt[i] = returnWorkFlowDataExt[i];
    }
    NSData *adataExt = [[NSData alloc] initWithBytes:byteDataExt length:3];
    NSLog(@"%@",adataExt);
    NSString* cutStrExt;
    if (devicetype == 0) {
        cutStrExt = @"000000";
    }else if (devicetype == 1){
        cutStrExt = [Tools hexadecimalString:adataExt];
    }
    NSLog(@"额外工作流：%@",cutStrExt);
    
    NSString* numberone = @"009e000000";
    
    [returnArr addObject:numberone];
    for (int i = 0; i < 9; i++) {
        NSString *number = @"0";
        NSString *nooo = [NSString stringWithFormat:@"%d",i+1];
        number = [number stringByAppendingString:nooo];
        NSLog(@"%@",number);
        if (i != 8) {
            NSString * data = [cutStr substringWithRange:NSMakeRange(i*38,38)];//一截19*2
            number = [number stringByAppendingString:data];
        }else{
            NSString * data = [cutStr substringWithRange:NSMakeRange(i*38,6)];
            number = [number stringByAppendingString:data];
            number = [number stringByAppendingString:cutStrExt];
        }
        [returnArr addObject:number];
    }
    return returnArr;
}



@end
