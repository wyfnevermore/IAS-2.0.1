//
//  NetWork.m
//  IAS
//
//  Created by wyfnevermore on 2017/6/22.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "NetWork.h"
#import "ViewController.h"

@implementation NetWork


-(void)get
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.封装参数
    NSDictionary *dict = @{
                           @"username":@"Lion",
                           @"pwd":@"1314",
                           @"type":@"JSON"
                           };
    //3.发送GET请求
    /*
     第一个参数:请求路径(NSString)+ 不需要加参数
     第二个参数:发送给服务器的参数数据
     第三个参数:progress 进度回调
     第四个参数:success  成功之后的回调(此处的成功或者是失败指的是整个请求)
     task:请求任务
     responseObject:注意!!!响应体信息--->(json--->oc))
     task.response: 响应头信息
     第五个参数:failure 失败之后的回调
     */
    [manager GET:@"http://115.29.198.253:8088/WCF/Service/GetConfig/581" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@",[responseObject class],responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure--%@",error);
    }];
}

-(void)post{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.封装参数
    NSDictionary *dict = @{
                           @"username":@"Lion",
                           @"pwd":@"1314",
                           @"type":@"JSON"
                           };
    //3.发送post请求
    /*
     第一个参数:请求路径(NSString)+ 不需要加参数
     第二个参数:发送给服务器的参数数据
     第三个参数:progress 进度回调
     第四个参数:success  成功之后的回调(此处的成功或者是失败指的是整个请求)
     task:请求任务
     responseObject:注意!!!响应体信息--->(json--->oc))
     task.response: 响应头信息
     第五个参数:failure 失败之后的回调
     */
    [manager POST:@"需要请求的URL" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@",[responseObject class],responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"failure--%@",error);
    }];
}




-(void)download
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.确定请求路径
    NSURL *url = [NSURL URLWithString:@"http://115.29.198.253:8088/WCF/Service/GetConfig/"];
    
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //4.发送网络请求下载文件
    /*
     第一个参数:请求对象
     第二个参数:progress 进度回调
     downloadProgress
     @property int64_t totalUnitCount;
     @property int64_t completedUnitCount;
     第三个参数:destination 让我们告诉系统应该把文件存放到什么地方
     内部自动的完成剪切处理
     第四个参数: completionHandler 完成之后的回调
     response 响应头信息
     filePath  文件最终的存储路径
     error 错误信息
     */
    [[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //拼接文件的全路径
        NSString *fullpath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        
        NSLog(@"fullpath == %@",fullpath);
        return [NSURL fileURLWithPath:fullpath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSLog(@"%@",filePath);
    }] resume];
    
}

-(void)upload
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.发送请求上传文件
    /*
     第一个参数:请求路径(NSString)
     第二个参数:非文件参数
     第三个参数:constructingBodyWithBlock 拼接数据(告诉AFN要上传的数据是哪些)
     第四个参数:progress 进度回调
     第五个参数:success 成功回调
     responseObject:响应体
     第六个参数:failure 失败的回调
     */
    [manager POST:@"需要请求的URL" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *data = [NSData dataWithContentsOfFile:@"/Users/apple/Desktop/Snip20160409_148.png"];
        //拼接数据
        /*
         第一个参数:文件参数 (二进制数据)
         第二个参数:参数名~file
         第三个参数:该文件上传到服务器以什么名称来保存
         第四个参数:
         */
        [formData appendPartWithFileData:data name:@"file" fileName:@"123.png" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure -- %@",error);
    }];
}

-(void)networkStatusChangeAFN //网络状态监听
{
    //1.获得一个网络状态监听管理者
    AFNetworkReachabilityManager *manager =  [AFNetworkReachabilityManager sharedManager];
    
    //2.监听状态的改变(当网络状态改变的时候就会调用该block)
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        /*
         AFNetworkReachabilityStatusUnknown          = -1,  未知
         AFNetworkReachabilityStatusNotReachable     = 0,   没有网络
         AFNetworkReachabilityStatusReachableViaWWAN = 1,    3G|4G
         AFNetworkReachabilityStatusReachableViaWiFi = 2,   WIFI
         */
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G|4G");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
                
            default:
                break;
        }
    }];
    //3.手动开启 开始监听
    [manager startMonitoring];
}

- (NSMutableArray*)getModelRestData:(NSString*)projectIDstr :(uScanConfig)changedWorkFlow :(NSInteger)devicetype{//网络获取模型
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //http,得到了当前模型的工作流信息
    __block NSMutableArray *resultArr = [[NSMutableArray alloc]init];//__block代表允许这个变量在block中被操作
    NSString* urlStr = @"http://115.29.198.253:8088/WCF/Service/GetConfig/";
    urlStr = [urlStr stringByAppendingFormat:@"%@",projectIDstr];
    NSLog(@"%@",urlStr);
    //NSURL *url = [NSURL URLWithString:urlStr];
    
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@--模型方法",[responseObject class],responseObject);
        NSString* result;
        NSMutableArray *returnArr = [[NSMutableArray alloc]init];
        
        NSData * data = responseObject;
        result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
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
        
        NSString* numberone = @"009e000000";//其实是把开头2个00去掉，倒序变成0000、009e，009e转成10进制就是158个数据，1包20个数据
        
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
        resultArr = returnArr;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure--%@",error);
        NSMutableArray *returnArr = [[NSMutableArray alloc]init];
        
        ViewController* mainController = [[ViewController alloc]init];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"当前无网络连接！" message:@"请打开无线局域网或蜂窝移动网络" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"断开连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [mainController disconnect:mainController];
        }];
        [alertController addAction: okAction];
        [mainController presentViewController:alertController animated:YES completion:nil];
        resultArr = returnArr;
    }];
    return resultArr;
}

@end
