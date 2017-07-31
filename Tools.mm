//
//  Tools.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/29.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "Tools.h"
#import "ViewController.h"

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
+ (NSString*)setModelType:(NSString*)typeStr : (UIImageView*)typeImg :(NSInteger)deviceType{
    NSString *ProjectID;
    if (deviceType == 0) {
        if ([typeStr containsString:@"片剂"]) {
            [typeImg setImage:[UIImage imageNamed:@"yaopian"]];
            ProjectID = @"691";
        }
        if ([typeStr containsString:@"胶囊"]) {
            [typeImg setImage:[UIImage imageNamed:@"jiaonang"]];
            ProjectID = @"616";
        }
        if ([typeStr containsString:@"乳胶"]) {
            [typeImg setImage:[UIImage imageNamed:@"rujiao"]];
            ProjectID = @"554";
        }
        if ([typeStr containsString:@"面粉"]) {
            [typeImg setImage:[UIImage imageNamed:@"mianfen"]];
            ProjectID = @"590";
        }
        if ([typeStr containsString:@"珍珠粉"]) {
            [typeImg setImage:[UIImage imageNamed:@"zhenzhufen"]];
            ProjectID = @"553";
        }
        if ([typeStr containsString:@"爽身粉"]) {
            [typeImg setImage:[UIImage imageNamed:@"shuangshenfen"]];
            ProjectID = @"585";
        }
        if ([typeStr containsString:@"保鲜膜"]) {
            [typeImg setImage:[UIImage imageNamed:@"baoxianmo"]];
            ProjectID = @"685";
        }
        if ([typeStr containsString:@"爬行垫"]) {
            [typeImg setImage:[UIImage imageNamed:@"papadian"]];
            ProjectID = @"601";
        }
        if ([typeStr containsString:@"奶嘴"]) {
            [typeImg setImage:[UIImage imageNamed:@"naizui"]];
            ProjectID = @"826";
        }
        if ([typeStr containsString:@"奶粉"]) {
            [typeImg setImage:[UIImage imageNamed:@"naifen"]];
            ProjectID = @"552";
        }
        if ([typeStr containsString:@"饼干"]) {
            [typeImg setImage:[UIImage imageNamed:@"binggan"]];
            ProjectID = @"715";
        }
        if ([typeStr containsString:@"减肥药"]) {
            [typeImg setImage:[UIImage imageNamed:@"zuoxuanroujian"]];
            ProjectID = @"690";
        }
        if ([typeStr containsString:@"玛卡"]) {
            [typeImg setImage:[UIImage imageNamed:@"maka"]];
            ProjectID = @"684";
        }
        if ([typeStr containsString:@"纸尿裤"]) {
            [typeImg setImage:[UIImage imageNamed:@"zhiniaoku"]];
            ProjectID = @"606";
        }
        if ([typeStr containsString:@"辣椒粉"]) {
            [typeImg setImage:[UIImage imageNamed:@"lajiaofen"]];
            ProjectID = @"650";
        }
        if ([typeStr containsString:@"木材"]) {
            [typeImg setImage:[UIImage imageNamed:@"mucai"]];
            ProjectID = @"665";
        }
        if ([typeStr containsString:@"阿胶"]) {
            [typeImg setImage:[UIImage imageNamed:@"ajiao"]];
            ProjectID = @"556";
        }
        if ([typeStr containsString:@"巧克力"]) {
            [typeImg setImage:[UIImage imageNamed:@"qiaokeli"]];
            ProjectID = @"696";
        }
        if ([typeStr containsString:@"檀木"]) {
            [typeImg setImage:[UIImage imageNamed:@"tanmu"]];
            ProjectID = @"830";
        }
        if ([typeStr containsString:@"苹果"]) {
            [typeImg setImage:[UIImage imageNamed:@"pingguo"]];
            ProjectID = @"814";
        }
        if ([typeStr containsString:@"体脂"]) {
            [typeImg setImage:[UIImage imageNamed:@"tizhilv"]];
            ProjectID = @"831";
        }
        
    }else if (deviceType == 1){
        if ([typeStr containsString:@"片剂"]) {
            [typeImg setImage:[UIImage imageNamed:@"yaopian"]];
            ProjectID = @"581";
        }
        if ([typeStr containsString:@"茶叶"]) {
            [typeImg setImage:[UIImage imageNamed:@"chaye"]];
            ProjectID = @"801";
        }
        if ([typeStr containsString:@"枸杞"]) {
            [typeImg setImage:[UIImage imageNamed:@"gouqi"]];
            ProjectID = @"804";
        }
        if ([typeStr containsString: @"大米"]) {
            [typeImg setImage:[UIImage imageNamed:@"dami"]];
            ProjectID = @"795";
        }
        if ([typeStr containsString:@"狗粮"]) {
            [typeImg setImage:[UIImage imageNamed:@"gouliang"]];
            ProjectID = @"796";
        }
        if ([typeStr containsString:@"奶粉"]) {
            [typeImg setImage:[UIImage imageNamed:@"naifen"]];
            ProjectID = @"792";
        }
        if ([typeStr containsString:@"婴儿奶粉"]) {
            [typeImg setImage:[UIImage imageNamed:@"zhiniaoku"]];
            
        }
    }
    return ProjectID;
}




//激活工作流
+(void)activeWorkFlow:(NSString*)workFlowStr :(CBPeripheral*)mPeripheral : (CBCharacteristic*)characteristic{
    NSData *workFlowObject = [Tools dataWithHexstring:workFlowStr];
    NSLog(@"工作流改为%@",workFlowStr);
    [mPeripheral writeValue:workFlowObject forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"%@",workFlowObject);
}


+ (NSString*)getRestData:(NSString*)projectIDstr : (NSString*)datastr{
    NSString* segueToResult;
    NSURL *url = [NSURL URLWithString:@"http://115.29.198.253:8088/WCF/Service/GetData"];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    //[request setTimeoutInterval:3];
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
    NSLog(@"收到的数据：%@",receData);
    if ([receData containsString:@"异常"]) {
        segueToResult = @"执行异常";
    }
    else if ([receData containsString:@"韵颜"]){
        segueToResult = @"劣质阿胶";
    }
    else if ([receData containsString:@"太极"]){
        segueToResult = @"优质阿胶";
    }
    else if ([receData containsString:@"粉滑"]){
        segueToResult = @"面粉（滑石粉）";
    }
    else if ([receData containsString:@"五常"]){
        segueToResult = @"非陈粮";
    }
    else if ([receData containsString:@"陈化"]){
        segueToResult = @"陈粮";
    }
    else if ([receData containsString:@"昊红"]){
        segueToResult = @"非熏蒸枸杞";
    }
    else if ([receData containsString:@"塞翁福"]){
        segueToResult = @"熏蒸枸杞";
    }
    else if ([receData containsString:@"龙井特级"]){
        segueToResult = @"龙井特级";
    }
    else if ([receData containsString:@"一级龙井"]){
        segueToResult = @"一级龙井";
    }
    else if ([receData containsString:@"二级龙井"]){
        segueToResult = @"二级龙井";
    }
    else if ([receData containsString:@"飞鹤超级飞帆2"]){
        segueToResult = @"飞鹤超级飞帆奶粉";
    }
    else if ([receData containsString:@"荷兰乳牛中老年"]){
        segueToResult = @"荷兰乳牛中老年奶粉";
    }
    else if ([receData containsString:@"贝因美中老年"]){
        segueToResult = @"贝因美中老年多维奶粉";
    }
    else if ([receData containsString:@"三元全家"]){
        segueToResult = @"三元全家甜奶粉";
    }
    else if ([receData containsString:@"九州通罗"]){
        segueToResult = @"九州通罗红霉素片";
    }
    else if ([receData containsString:@"布洛伪麻"]){ 
        segueToResult = @"扑风清布洛伪麻片";
    }
    else if ([receData containsString:@"维生素"]){
        segueToResult = @"白敬宇维生素C片";
    }
    else if ([receData containsString:@"茶苯海明"]){
        segueToResult = @"白敬宇茶苯海明片";
    }
    else if ([receData containsString:@"多潘立酮"]){
        segueToResult = @"三精多潘立酮片";
    }
    else if ([receData containsString:@"糖:"]){
        NSArray *arrys= [receData componentsSeparatedByString:@":"];
        
        segueToResult = arrys[2];
        segueToResult = [segueToResult substringToIndex:segueToResult.length-11];
        segueToResult = [NSString stringWithFormat:@"%@° Brix",segueToResult];
    }
    else{
        NSArray *arrys1= [receData componentsSeparatedByString:@"\""];
        NSLog(@"收到的数组数据：%lu，原始数据：%@",(unsigned long)arrys1.count,receData);
        if (arrys1.count == 0) {
            NSLog(@"当前无网络连接！");
        }else if(arrys1.count  == 1){
            segueToResult = @"当前网络环境差，请检查网络环境后继续测试！";
            NSLog(@"当前无网络连接！");
        }else{
            NSString* str1=(NSString *)arrys1[3];
            NSLog(@"%@",str1);
            segueToResult = str1;
        }
    }
    return segueToResult;
}

//从模
+ (void)getHttp{
    ///*
    NSString* result;
    NSString* urlStr = @"http://115.29.198.253:8088/WCF/Service/GetConfig/";
    urlStr = [urlStr stringByAppendingFormat:@"581"];
    NSLog(@"%@",urlStr);
    
    //NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
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
    result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",result);
    
    NSMutableArray *returnArr = [[NSMutableArray alloc]init];
    if ([result  containsString:@"GatherAverage"]) {
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
    }else{
        ViewController* mainController = [[ViewController alloc]init];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"当前无网络连接！" message:@"请打开无线局域网或蜂窝移动网络" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"断开连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [mainController disconnect:mainController];
        }];
        [alertController addAction: okAction];
        [mainController presentViewController:alertController animated:YES completion:nil];
        return returnArr;
    }
}

+ (BOOL)isCbDataCurrent: (double*)cb : (int)workFlowPoints{
    NSMutableArray *_isCurrentDataArray = [[NSMutableArray alloc]initWithCapacity:workFlowPoints];
    for (int i = 0; i < workFlowPoints; i++) {
        [_isCurrentDataArray addObject:@(cb[i])];
    }
    double dataMax = [[_isCurrentDataArray valueForKeyPath:@"@max.floatValue"]doubleValue];
    return dataMax > 600 ? YES : NO;
}

+ (BOOL)isIntentDataCurrent: (double*)intent : (int)workFlowPoints{
    NSMutableArray *_isCurrentDataArray = [[NSMutableArray alloc]initWithCapacity:workFlowPoints];
    for (int i = 0; i < workFlowPoints; i++) {
        [_isCurrentDataArray addObject:@(intent[i])];
    }
    double dataMax = [[_isCurrentDataArray valueForKeyPath:@"@max.floatValue"]doubleValue];
    if (dataMax > 100) {
        return YES;
    }else{
        return NO;
    }
}

+ (double)getScanTime : (NSData*)scanTimeData{//规则，例：收到的时间包NSData为<0149110000>,去掉01开始处理，倒序为00001149的NSString，再转10进制，再／1000就是我们要的时间
    double scanTime = 1;
    NSString* orgTimeStr = [Tools hexadecimalString:scanTimeData];
    NSLog(@"orgTimeStr:%@",orgTimeStr);
    NSLog(@"orgTimeStrlength:%lu",(unsigned long)orgTimeStr.length);
    NSMutableArray* timeArr = [[NSMutableArray alloc]init];
    NSInteger orgTimeStrlength = orgTimeStr.length;
    for (NSInteger i = (orgTimeStrlength - 2); i > 1; i -= 2) {//反向截取
        NSString* str = [orgTimeStr substringWithRange:NSMakeRange(i,2)];
        [timeArr addObject:str];
    }
    NSLog(@"timeArr:%@",timeArr);
    NSString *currentTimeStr = [[NSString alloc]init];
    for (int i = 0; i < timeArr.count; i++) {
        currentTimeStr = [currentTimeStr stringByAppendingString:timeArr[i]];
    }
    NSLog(@"currentTimeStr:%@",currentTimeStr);
    //十六进制转十进制
    NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([currentTimeStr UTF8String],0,16)];
    NSLog(@"扫描时间 10进制 %@",temp10);
    //转成数字
    double cycleNumber = [temp10 doubleValue];
    NSLog(@"扫描时间 ：%f",cycleNumber);
    
    scanTime = cycleNumber/1000;
    NSLog(@"返回的扫描时间 ：%f",cycleNumber);
    return scanTime;
}



@end
