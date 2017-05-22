//
//  ViewController.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/28.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT  [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "WorkFlowViewController.h"

@interface ViewController ()<WorkFlowChooseDelegate>
@property (strong,nonatomic)NSMutableArray *workFlowForNow;
@property (strong,nonatomic)UIActivityIndicatorView* mActivityIndicatorView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    isReconnected = NO;
    isdanliang = NO;
    projectIDStr = @"581";
    [Tools getHttp];//测试网络环境
    formerType = @"562";
    workFlowPoints = 801;//点数，在此修改
    workFlowPointsType = 2;//2即为把420点差分成801
    _deviceTableView.delegate = self;
    _deviceTableView.dataSource = self;
    _typePickView.delegate = self;
    _typePickView.dataSource = self;
    
    //初始化
    workFlowArr = [[NSMutableArray alloc]init];
    workFlowName = [[NSMutableArray alloc]init];
    workFlowDetail = [[NSMutableArray alloc]init];
    outsideArr = [[NSMutableArray alloc]init];
    _myPeripherals = [NSMutableArray array];
    _workFlowForNow = [[NSMutableArray alloc]init];
    _isCurrentDataArray = [[NSMutableArray alloc]initWithCapacity:workFlowPoints];
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@"NO"};
    self.myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
    
    //设置label点击事件
    _typeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [_typeLabel addGestureRecognizer:labelTapGestureRecognizer];
    
    //load控件初始化
    _mActivityIndicatorView = [[UIActivityIndicatorView alloc]init];
    _ingBgView = [[UIView alloc]init];
    _deviceTypeChooseTitle = [[UILabel alloc]init];
    
    //设置背景点击事件
    _lowestView.userInteractionEnabled = YES;
    [self tapGestureRecognizer];
    
    //选择设备型号
    _deviceType = 100;//因为默认为0，所以随便设一个，不然默认就是手持,也用来判断是不是第一次选择
    [self showDeviceType];//一定放最后
}

//1.开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [_uplabel setText:@"蓝牙打开, 请搜索设备!"];
            NSLog(@"蓝牙已打开, 请扫描外设!");
            [_uplabel setTextColor:[UIColor blackColor]];
            break;
        case CBManagerStateUnknown :
            [_uplabel setText:@"当前蓝牙状态未知，请重试"];
            break;
        case CBManagerStateUnsupported:
            [_uplabel setText:@"当前设备不支持蓝牙设备连接"];
            break;
        case CBManagerStateUnauthorized:
            [_uplabel setText:@"请前往设置开启蓝牙授权并重试"];
            break;
        case CBManagerStateResetting:
            
            break;
        case CBManagerStatePoweredOff:{
            _deviceTableView.hidden = YES;
            //通知框
            NSString *title = @"请打开蓝牙!";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            [_uplabel setText:title];
            [_uplabel setTextColor:[UIColor redColor]];
            break;
        }
        default:
            break;
    }
}

//2.设备搜索
- (void)scanClick{
    NSLog(@"正在扫描外设...");
    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
    if(_myPeripheral != nil){
        [_myCentralManager cancelPeripheralConnection:_myPeripheral];
    }
    double delayInSeconds = 1.0;  //这段时间内执行3
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.myCentralManager stopScan];
        switch (mCount) {
            case 0:
                [_uplabel setText:@"未搜索到光谱设备！"];
                break;
            case 1:
                _deviceTableView.hidden = YES;
                _myPeripheral = [_myPeripherals objectAtIndex:0];
                [self connectClick];
                break;
            default:
                _deviceTableView.hidden = NO;
                [_deviceTableView reloadData];
                self.title = @"设备列表";
                NSLog(@"2个及以上设备");
                break;
        }
        NSLog(@"扫描超时,停止扫描!");
    });
}

//3.查到外设后的方法,peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([peripheral.name containsString:@"NIR"]) {
        NSLog(@"%@",peripheral.name);
        for (int i = 0; i < _myPeripherals.count; i++) {
            if (peripheral == _myPeripherals[i]) {
                isRepeat = 1;
            }
        }
        if (isRepeat == 0) {
            [_myPeripherals addObject:peripheral];
        }else if(isRepeat == 1){
            isRepeat = 0;
            NSLog(@"发现重复!");
        }
        mCount = _myPeripherals.count;
        NSLog(@"my periphearls count : %ld\n", (long)mCount);
        [_deviceTableView reloadData];
    }
}

//4.设备连接
- (void)connectClick{
    [self.myCentralManager connectPeripheral:_myPeripheral options:nil];
    [_uplabel setText:@"正在连接设备..."];
    [_uplabel setTextColor:[UIColor blackColor]];
    isScanningTitle = @"正在连接设备...";
    [AboutUI showIng:isScanningTitle :_mActivityIndicatorView :_ingBgView :_deviceTypeChooseTitle];
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self.myPeripheral setDelegate:self];
    [self.myPeripheral discoverServices:nil];
    NSLog(@"扫描服务...");
}

//已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"发现服务!");
    int i = 0;
    for(CBService* s in peripheral.services){
        [self.nServices addObject:s];
    }
    for(CBService* s in peripheral.services){
        NSLog(@"%d :服务 UUID: %@(%@)", i, s.UUID.data, s.UUID);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
        NSLog(@"扫描Characteristics...");
    }
}

//已发现characteristcs,遍历特征UUID
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for(CBCharacteristic* c in service.characteristics){
        NSLog(@"特征 UUID: %@ (%@)", c.UUID.data, c.UUID);
        //扫描，分2步，先从第一个特征值取出值
        if([c.UUID.UUIDString containsString:@"411D"]&&c.properties == 0x8){
            self.startscanCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"411D"]&&c.properties == 0x10){
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            NSLog(@"找到NOTIFY : %@", c);
        }
        //再写入到第二个特征值中
        if([c.UUID.UUIDString containsString:@"4127"]){
            self.requestdataCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"4128"]){
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            NSLog(@"找到NOTIFY : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"4129"]){
            _ladengCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"412A"]){
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            NSLog(@"找到NOTIFY : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"412B"]){
            _duojiCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"412C"]){
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            NSLog(@"找到NOTIFY : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"412D"]){//读取外置数据，需不需要灯亮，需不需要电机转
            _outsidesettingCharacteristic = c;
            NSLog(@"找到WRITE : %@,(读取外置数据)", c);
        }
        if([c.UUID.UUIDString containsString:@"412E"]){
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            NSLog(@"找到NOTIFY : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"412F"]){
            self.workFlowForNowCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
        //工作流配置列表和具体参数的查找和选择
        if ([c.UUID.UUIDString containsString:@"4113"]) {//读取工作流数量
            [self.myPeripheral readValueForCharacteristic:c];
        }
        if([c.UUID.UUIDString containsString:@"4114"]){//请求工作流配置列表
            _requestStoredConfigurationCharacteristicList = c;
            NSLog(@"找到WRITE : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"4115"]){//从监听获取返回的工作流配置列表
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            NSLog(@"找到NOTIFY : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"4116"]){  //请求工作流配置详细参数
            self.requestScanConfigurationDataCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
        if([c.UUID.UUIDString containsString:@"4117"]){//从监听获取返回的工作流配置详细参数
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            NSLog(@"找到NOTIFY : %@", c);
        }
        //向此特征值写入数据可激活工作流
        if([c.UUID.UUIDString containsString:@"4118"]){
            self.activeConfigurationCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
    }
}

//获取外设发来的数据,不论是read和notify，http请求当前模型的建模参数，合成云端工作流结构体，用蓝牙设置为当前工作流。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral readRSSI];
    if ([characteristic.UUID.UUIDString containsString:@"4113"]) {//获取本机工作流数量
        NSData* data = characteristic.value;
        NSString *Number = [Tools hexadecimalString:data];
        Number = [Number substringToIndex:2];
        workFlowNumber = [Number intValue];
        NSLog(@"工作流数量：%d",workFlowNumber);
        NSString *tdata = @"01";
        NSData* value = [Tools dataWithHexstring:tdata];
        NSLog(@"入口");
        if (isReconnected == NO) {
            [_myPeripheral writeValue:value forCharacteristic:_requestStoredConfigurationCharacteristicList type:CBCharacteristicWriteWithResponse];
        }else{
            [self setAllReady];//连接完成！
        }
    }
    //获取工作流配置列表
    if([characteristic.UUID.UUIDString containsString:@"4115"]){
        if (isReconnected == NO) {
            NSData* data = characteristic.value;
            NSString* list = [Tools hexadecimalString:data];
            NSLog(@"配置包：%@",list);
            if ([[list substringWithRange:NSMakeRange(0, 2)]containsString:@"1"] && workFlowArr.count == 0) {
                workFlowData = [Tools hexadecimalString:data];
                NSLog(@"配置列表：%@",workFlowData);
                [workFlowArr addObject:[workFlowData substringWithRange:NSMakeRange(2, 4)]];
                testbigstring = workFlowArr[0];
                dispatch_time_t partTime = dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC);//这里加延时是因为上一个到这个写入间隔太快，不加会出错
                dispatch_after(partTime, dispatch_get_main_queue(), ^{
                    [self requestWorkFlowData];
                    NSLog(@"工作流：%@",workFlowArr);
                });
            }
        }
    }
    //获取工作流配置参数
    if([characteristic.UUID.UUIDString containsString:@"4117"]){
        packageWorkFlowNo++;
        NSData* data = characteristic.value;
        
        NSString *workFlowReturnData = [Tools hexadecimalString:data];
        NSLog(@"%d",packageWorkFlowNo);
        NSLog(@"返回的配置参数数据：%@",workFlowReturnData);
        if (packageWorkFlowNo == 1) {
            workFlowReturnData = [workFlowReturnData substringWithRange:NSMakeRange(2,1)];
            packageNumber = [workFlowReturnData intValue];
            NSLog(@"截取到的包个数：%d",packageNumber);
        }
        NSUInteger len = [data length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [data bytes], len);
        //NSLog(@"byte数据：%s",byteData);
        if (packageWorkFlowNo > 1) {
            for (int c = 0; c<len-1; c++) {
                returnWorkFlowData[returnByteWorkFlowNo] = byteData[c+1];
                if (returnByteWorkFlowNo == (packageNumber-1)*19) {
                    bool isGetScanConfig = getScanCofig(returnWorkFlowData,&(scanConfigWorkFlow));
                    NSLog(@"有无数据：%d,扫描类型：%s,%hhu(0为column，1为hardma)，点数：%hu，波长：%hu到%hu,平均次数:%hu。",isGetScanConfig,scanConfigWorkFlow.slewScanCfg.head.config_name,scanConfigWorkFlow.slewScanCfg.section[0].section_scan_type,scanConfigWorkFlow.slewScanCfg.section[0].num_patterns,scanConfigWorkFlow.slewScanCfg.section[0].wavelength_start_nm,scanConfigWorkFlow.slewScanCfg.section[0].wavelength_end_nm,scanConfigWorkFlow.slewScanCfg.head.num_repeats);
                    changedScanConfigWorkFlow = scanConfigWorkFlow;//获得工作流模版
                    NSString *configName;
                    NSString *configDetail;
                    configName = [[NSString alloc] initWithFormat:@"%s",scanConfigWorkFlow.slewScanCfg.head.config_name];
                    configDetail =  [[NSString alloc] initWithFormat:@"点数：%hu",scanConfigWorkFlow.slewScanCfg.section[0].num_patterns];
                    configDetail = [configDetail stringByAppendingFormat:@"，平均次数：%hu次",scanConfigWorkFlow.slewScanCfg.head.num_repeats];
                    [workFlowName addObject:configName];
                    [workFlowDetail addObject:configDetail];
                    NSLog(@"%@,%@",workFlowName,workFlowDetail);
                    
                    [self setAllReady];
                }
                returnByteWorkFlowNo++;
                if (returnByteWorkFlowNo > 500) {
                    break;
                }
            }
        }
        NSLog(@"计数：%d，%d",packageWorkFlowNo,returnByteWorkFlowNo);
    }
    
    if([characteristic.UUID.UUIDString containsString:@"412E"]){
        outsidedatapackageNumber++;
        NSData* data = characteristic.value;
        NSString *outsideData = [Tools hexadecimalString:data];
        NSLog(@"哇啦啦啦%@，计数:%d",outsideData,outsidedatapackageNumber);
        if (outsidedatapackageNumber == 2) {
            if (outsideData != nil) {
                [outsideArr addObject:outsideData];
                NSLog(@"%@收到的外部数据",outsideArr);
            }
        }
    }
    
    //扫描，获取第一次写入时返回的数据，需再次写入，再次写入获得的才是光谱数据
    if([characteristic.UUID.UUIDString containsString:@"411D"]&&characteristic.properties == 0x10){
        NSData* data = characteristic.value;
        NSString* value = [Tools hexadecimalString:data];
        if([value containsString:@"ff"]&&init == 1){
            NSUInteger len = [data length];
            Byte *byteData = (Byte*)malloc(len);
            memcpy(byteData, [data bytes], len);
            Byte dataArr[4];
            for (int i=0; i<4; i++) {
                dataArr[i] = byteData[i+1];
            }
            NSData * myData = [NSData dataWithBytes:dataArr length:4];
            NSLog(@"%@",myData);
            dispatch_time_t littletime = dispatch_time(DISPATCH_TIME_NOW, 0.3*NSEC_PER_SEC);
            dispatch_after(littletime, dispatch_get_main_queue(), ^{
                [_myPeripheral writeValue:myData forCharacteristic:_requestdataCharacteristic type:CBCharacteristicWriteWithResponse];
                NSLog(@"重新写入characteristic以获得光谱数据 : %@, data : %@,\nvalue : %@", characteristic, data, myData);
            });
        }
    }
    //获取光谱数据并处理
    if([characteristic.UUID.UUIDString containsString:@"4128"]){
        packageNo = packageNo+1;
        NSData* data = characteristic.value;
        //收到的byte数组
        NSUInteger len = [data length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [data bytes], len);
        if (packageNo > 2) {
            for (int c = 0; c<len-1; c++) {
                if (returnByteNo >= 4001) {
                    break;
                }
                returnData[returnByteNo] = byteData[c+1];
                if (returnByteNo == 3731) {
                    switch (statement) {
                        case 0:{//采集完成后，收到参比数据用C++方法处理
                            bool isGetDataCB = getDLPData(returnData,waveLength, cb,workFlowPointsType);
                            NSLog(@"C++参比处理结果:%d",isGetDataCB);
                            BOOL isDataRight = [Tools isCbDataCurrent:cb :workFlowPoints];
                            if (isDataRight == YES) {
                                [_uplabel setText:@"采集参比完成，请采集样品!"];
                                isCbInited = true;
                                formerType = projectIDStr;
                                [self stoping];//停止loading
                                [_writeBtn setTitle:@"采集样品" forState:UIControlStateNormal];
                            }else if(isDataRight == NO){
                                [self warningCB];
                            }
                            _writeBtn.userInteractionEnabled = YES;
                            break;
                        }
                        case 1:{//采集完成后，收到样品数据用C++方法处理，再和参比数据比对后得到吸光度光谱数据,将得到的吸光度数据http发送给云端（奶粉定量、饼干等需要多次请求数据）
                            bool isGetDataYP = getDLPData(returnData,waveLength, intentsities,workFlowPointsType);
                            NSLog(@"C++样品检测结果：%d",isGetDataYP);
                            
                            BOOL isDataRight = [Tools isIntentDataCurrent:intentsities :workFlowPoints];//判断样品光谱是否正常
                            if (isDataRight == YES) {
                                [_uplabel setText:@"采集样品完成！"];
                                _writeBtn.userInteractionEnabled = YES;
                                dataString = [self getAbs:cb intentsities:intentsities];
                                if ([projectIDStr intValue] == 552) {
                                    NSString *titleStr = [Tools getRestData:projectIDStr :dataString];
                                    if ([titleStr containsString:@"三聚氰胺"]) {
                                        [_showResultNow appendString:[NSString stringWithFormat:@"        %@\n",titleStr]];
                                    }else{
                                        projectIDStr = @"626";
                                        NSString* danbaiStr = [Tools getRestData:projectIDStr :dataString];
                                        danbaiStr = [danbaiStr substringToIndex:danbaiStr.length-1];
                                        danbaiStr = [danbaiStr stringByAppendingString:@"g"];
                                        projectIDStr = @"632";
                                        NSString* tanshuiStr = [Tools getRestData:projectIDStr :dataString];
                                        tanshuiStr = [tanshuiStr substringToIndex:tanshuiStr.length-1];
                                        tanshuiStr = [tanshuiStr stringByAppendingString:@"g"];
                                        projectIDStr = @"631";
                                        NSString* zhifangStr = [Tools getRestData:projectIDStr :dataString];
                                        zhifangStr = [zhifangStr substringToIndex:zhifangStr.length-1];
                                        zhifangStr = [zhifangStr stringByAppendingString:@"g"];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"                  %@\n",titleStr]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"\n"]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"每100g含：\n"]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"           %@\n",danbaiStr]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"   %@\n",tanshuiStr]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"               %@",zhifangStr]];
                                        NSLog(@"结果：%@",_showResultNow);
                                    }
                                    projectIDStr = @"552";
                                }else if ([projectIDStr intValue] == 792){//小罐子奶粉
                                    NSString *titleStr = [Tools getRestData:projectIDStr :dataString];
                                    if ([titleStr containsString:@"三聚氰胺"]) {
                                        [_showResultNow appendString:[NSString stringWithFormat:@"        %@\n",titleStr]];
                                    }else{
                                        projectIDStr = @"787";
                                        NSString* naifendingxin = [Tools getRestData:projectIDStr :dataString];
                                        projectIDStr = @"788";
                                        NSString* naifendingliang = [Tools getRestData:projectIDStr :dataString];
                                        naifendingliang = [naifendingliang substringToIndex:naifendingliang.length-1];
                                        NSArray *arrys= [naifendingliang componentsSeparatedByString:@";"];
                                        NSString* danbaiStr = (NSString *)arrys[0];
                                        NSString* zhifangStr = (NSString *)arrys[1];
                                        NSString* tanshuiStr = (NSString *)arrys[2];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"%@\n",naifendingxin]];
                                        //[_showResultNow appendString:[NSString stringWithFormat:@"\n"]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"每100g含：\n"]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"               %@\n",danbaiStr]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"       %@\n",tanshuiStr]];
                                        [_showResultNow appendString:[NSString stringWithFormat:@"                   %@",zhifangStr]];
                                    }
                                    projectIDStr = @"792";
                                }
                                else if ([projectIDStr intValue] == 715){//饼干
                                    NSString* danbaiStr = [Tools getRestData:projectIDStr :dataString];
                                    danbaiStr = [danbaiStr substringToIndex:danbaiStr.length-1];
                                    danbaiStr = [danbaiStr stringByAppendingString:@"g"];
                                    projectIDStr = @"716";
                                    NSString* zhifangStr = [Tools getRestData:projectIDStr :dataString];
                                    zhifangStr = [zhifangStr substringToIndex:zhifangStr.length-1];
                                    zhifangStr = [zhifangStr stringByAppendingString:@"g"];
                                    projectIDStr = @"717";
                                    NSString* tanshuiStr = [Tools getRestData:projectIDStr :dataString];
                                    tanshuiStr = [tanshuiStr substringToIndex:tanshuiStr.length-1];
                                    tanshuiStr = [tanshuiStr stringByAppendingString:@"g"];
                                    projectIDStr = @"718";
                                    NSString* nengliangStr = [Tools getRestData:projectIDStr :dataString];
                                    nengliangStr = [nengliangStr substringToIndex:nengliangStr.length-1];
                                    nengliangStr = [nengliangStr stringByAppendingString:@"KJ"];
                                    
                                    [_showResultNow appendString:[NSString stringWithFormat:@"每100g含：\n"]];
                                    [_showResultNow appendString:[NSString stringWithFormat:@"          %@\n",danbaiStr]];
                                    [_showResultNow appendString:[NSString stringWithFormat:@"              %@\n",zhifangStr]];
                                    [_showResultNow appendString:[NSString stringWithFormat:@"  %@\n",tanshuiStr]];
                                    [_showResultNow appendString:[NSString stringWithFormat:@"              %@",nengliangStr]];
                                    NSLog(@"结果：%@",_showResultNow);
                                    projectIDStr = @"715";
                                }else{
                                    NSString* Result = [Tools getRestData:projectIDStr :dataString];
                                    [_showResultNow appendString:[NSString stringWithFormat:@"%@",Result]];
                                }
                                [self stoping];//结束loading
                                [_uplabel setText:@"样品采集完成！"];
                                [self performSegueWithIdentifier:@"result" sender:self];//结果接收,收到结果并处理，跳转
                            }else if(isDataRight == NO){
                                [self warningIntent];
                            }
                            break;
                        }
                            default:
                            NSLog(@"未进行扫描");
                            break;
                    }
                    init = 0;
                    if (_deviceType == 1) {
                        [self writeToPeripheral:@"00" :_duojiCharacteristic];
                        if (isdanliang == YES) {
                            [self writeToPeripheral:@"00" :_ladengCharacteristic];
                        }
                    }
                }
                returnByteNo++;
            }
        }
    }
}

//处理采集的光谱数据转成NSString
- (NSString*)getAbs:(double[864])mcb intentsities:(double[864])mintentsities{
    NSString *dataStr = @"";
    for (int i = 0; i < 864; i++) {
        if(mintentsities[i]==0){
            aBS[i] = 0;
        }else {
            if(mcb[i]<=0){
                aBS[i] = 0;
            }else if(mintentsities[i]<=0){
                aBS[i] = 0;
            }else{
                aBS[i] = log10(mcb[i]/mintentsities[i]);
            }
        }
    }
    
    //总点数
    NSMutableArray *mutArr=[[NSMutableArray alloc]initWithCapacity:workFlowPoints];
    _transXGD = [[NSMutableArray alloc]initWithCapacity:workFlowPoints];
    for (int g = 0; g<workFlowPoints; g++) {
        NSString *arritem = [NSString stringWithFormat:@"%.8f",aBS[g]];//main
        mutArr[g] = arritem;//main
        double f = [arritem doubleValue];
        [_transXGD addObject:@(f)];
        NSLog(@"%@,%d,%@",mutArr[g],g,_transXGD[g]);//main
        if (g == (workFlowPoints - 1)) {
            dataStr = [dataStr stringByAppendingFormat:@"%@", [mutArr objectAtIndex:g]];
        }else{
            dataStr = [dataStr stringByAppendingFormat:@"%@,", [mutArr objectAtIndex:g]];
        }
    }
    return dataStr;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //结果页
    if ([segue.identifier isEqualToString:@"result"]) {
        ResultViewController* rece = segue.destinationViewController;
        rece.name = nil;
        rece.name = [NSMutableString stringWithString:@""];
        rece.name = _showResultNow;
        rece.dataXGDArray = _transXGD;
        _transBC = [[NSMutableArray alloc]initWithCapacity:workFlowPoints];
        for (int i = 0; i < workFlowPoints; i++) {
            NSString *abc = [NSString stringWithFormat:@"%.2f",waveLength[i]];
            double a = [abc doubleValue];
            [_transBC addObject:@(a)];
        }
        rece.dataBCArray = _transBC;
    }
    //工作流页
    if ([segue.identifier isEqualToString:@"workFlow"]) {
        WorkFlowViewController *wkfl = segue.destinationViewController;
        wkfl.configName = workFlowName;
        wkfl.configurationDetail = workFlowDetail;
        wkfl.returnWorkFlow = receStr;
        // 设定委托为self
        [wkfl setValue:self forKey:@"delegate"];
    }
}

//实现返回值的代理的方法
- (void)passValue:(NSInteger)WorkfNo{
    if (_myPeripheral != nil && _myPeripheral.state == CBPeripheralStateConnected) {
        // 设定内容为协议传过来的值
        if (receStr == WorkfNo) {
            NSLog(@"未选择工作流");
        }else{
            receStr = WorkfNo;
            NSLog(@"返回的工作流名称：%ld",(long)receStr);
            testbigstring = workFlowArr[receStr];
            //workFlowPoints = [[workFlowDetail[receStr] substringWithRange:NSMakeRange (3,3)]intValue];
            NSLog(@"点数：%d",workFlowPoints);
            [Tools activeWorkFlow:testbigstring :_myPeripheral :_activeConfigurationCharacteristic];
            [_writeBtn setTitle:@"采集参比" forState:UIControlStateNormal];
        }
    }
}

//掉线时调用,手机端断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    packageNo = 1;
    returnByteNo = 0;
    init = 1;
    statement = 10;
    
    NSLog(@"periheral has disconnect");
    [self stoping];
    [_uplabel setText:@"连接断开！"];
    [_uplabel setTextColor:[UIColor redColor]];
    [_writeBtn setTitle:@"搜索设备" forState:UIControlStateNormal];
    [workFlowArr removeAllObjects];
    [workFlowName removeAllObjects];
    [workFlowDetail removeAllObjects];
    [outsideArr removeAllObjects];
    _writeBtn.userInteractionEnabled = YES;
    _deviceType = 100;
    NSLog(@"%ld断线后的设备类型",(long)_deviceType);
    [self showDeviceType];
    receStr = 0;
    isdanliang = NO;
    if (mCount != 0) { //用mcount是否为0来判断是掉线还是自己搜索设备
        //[_myCentralManager connectPeripheral:_myPeripheral options:nil];
        isReconnected = YES;
    }
    returnByteNo = 0;
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@", error);
    [_uplabel setText:@"连接断开，请重新连接设备！"];
    [_uplabel setTextColor:[UIColor redColor]];
    [_writeBtn setTitle:@"搜索设备" forState:UIControlStateNormal];
}

//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    //Notification has started
    if(characteristic.isNotifying){
        [peripheral readValueForCharacteristic:characteristic];
        NSLog(@"Notification started on %@. connecting", characteristic);
    }else{
        NSLog(@"Notification stopped on %@. Disconnting", characteristic);
        [self.myCentralManager cancelPeripheralConnection:self.myPeripheral];
    }
}

-(void)requestWorkFlowData{
    packageWorkFlowNo = 0;
    returnByteWorkFlowNo = 0;
    packageNumber = 0;
    outsidedatapackageNumber = 0;
    workFlowObject = [Tools dataWithHexstring:testbigstring];
    NSLog(@"写入%@",workFlowObject);
    [_myPeripheral writeValue:workFlowObject forCharacteristic:_requestScanConfigurationDataCharacteristic type:CBCharacteristicWriteWithResponse];
}


//pickerView的方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    //为了说明,在UIPickerView中有多少列`
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger arrayCount = pickArray.count;
    return arrayCount;
    //为了说明每列有多少行
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *screenData = [pickArray objectAtIndex:row];
    return screenData;
    //载入数组数据
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [_typeLabel setText:[pickArray objectAtIndex:row]];
    //pickview选到当前行时执行
}


//tableview的方法,返回rows(行数)。设备列表
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return _myPeripherals.count;
    NSInteger a = _myPeripherals.count;
    NSLog(@"行数：%ld",(long)a);
    return a;
}

//tableview的方法,返回cell的view
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //为表格定义一个静态字符串作为标识符
    static NSString* cellId = @"cellId";
    //从IndexPath中取当前行的行号
    NSUInteger rowNo = indexPath.row;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    UILabel* labelName = (UILabel*)[cell viewWithTag:1];
    UILabel* labelUUID = (UILabel*)[cell viewWithTag:2];
    labelName.text = [[_myPeripherals objectAtIndex:rowNo] name];
    NSString* uuid = [NSString stringWithFormat:@"%@", [[_myPeripherals objectAtIndex:rowNo] identifier]];
    uuid = [uuid substringFromIndex:[uuid length] - 13];
    NSLog(@"UUID%@", uuid);
    labelUUID.text = uuid;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

//tableview的方法,点击行时触发，设备选择
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
    //NSLog(@"%lu", (unsigned long)rowNo);
    _deviceTableView.hidden = YES;
    _myPeripheral = [_myPeripherals objectAtIndex:rowNo];
    self.title = @"检测";
    [self connectClick];
}

//向peripheral中写入数据
- (void)writeToPeripheral:(NSString *)data :(CBCharacteristic*)characterNow{
    if(!characterNow){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    NSData* value = [Tools dataWithHexstring:data];
    [_myPeripheral writeValue:value forCharacteristic:characterNow type:CBCharacteristicWriteWithResponse];
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success : %@", characteristic);
}

//连接完成后
-(void)allReady{
    if (_deviceType == 1) {
        //[self writeToPeripheral:@"00" :_ladengCharacteristic];
        //[self writeToPeripheral:@"00" :_duojiCharacteristic];
    }
    [self chooseCurrentProject];
    [_uplabel setText:@"设备已连接，请采集参比！"];
    [_uplabel setTextColor:[UIColor blackColor]];
    [_writeBtn setTitle:@"采集参比" forState:UIControlStateNormal];
    dispatch_time_t partTime = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
    dispatch_after(partTime, dispatch_get_main_queue(), ^{
        [self stoping];
    });
}

//UI 选择设备型号
- (void)showDeviceType{
    //1. 取出window
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //2. 创建背景视图
    _bgView = [[UIView alloc]init];
    _bgView.frame = window.bounds;
    //3. 背景颜色可以用多种方法
    //_bgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    _bgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [window addSubview:_bgView];
    //4. 把需要展示的控件添加上去
    _deviceTypeChooseTitle.frame = CGRectMake(SCREENWIDTH/2, SCREENHEIGHT/2, 0, 0);
    [_deviceTypeChooseTitle setText:@"请选择设备型号"];
    _deviceTypeChooseTitle.textAlignment = NSTextAlignmentCenter;//文字居中
    _deviceTypeChooseTitle.textColor = [UIColor whiteColor];
    [_deviceTypeChooseTitle setFont:[UIFont systemFontOfSize:27]];
    [window addSubview:_deviceTypeChooseTitle];
    
    _xgzDeviceBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH/2, SCREENHEIGHT/2, 0, 0)];
    [_xgzDeviceBtn setTitle:@"IAS-5000" forState:UIControlStateNormal];
    _xgzDeviceBtn.layer.cornerRadius = SCREENHEIGHT/30;//圆角的弧度
    _xgzDeviceBtn.layer.borderWidth = 2.0f;
    _xgzDeviceBtn.layer.borderColor = [[UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1]CGColor];
    if (_deviceType == 1) {
        [_xgzDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _xgzDeviceBtn.backgroundColor = [UIColor redColor];
    }else{
        [_xgzDeviceBtn setTitleColor:[UIColor colorWithRed:77.0/255 green:77.0/255 blue:77.0/255 alpha:1] forState:UIControlStateNormal];
        _xgzDeviceBtn.backgroundColor = [UIColor whiteColor];
    }
    [window addSubview:_xgzDeviceBtn];
    [_xgzDeviceBtn addTarget:self action:@selector(choosedXGZ) forControlEvents:UIControlEventTouchUpInside];
    
    
    _scsDeviceBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH/2, SCREENHEIGHT/2, 0, 0)];
    [_scsDeviceBtn setTitle:@"IAS-8000" forState:UIControlStateNormal];
    _scsDeviceBtn.layer.cornerRadius = SCREENHEIGHT/30;//圆角的弧度
    _scsDeviceBtn.layer.borderWidth = 2.0f;
    _scsDeviceBtn.layer.borderColor = [[UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1]CGColor];
    if (_deviceType == 0) {
        [_scsDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _scsDeviceBtn.backgroundColor = [UIColor redColor];
    }else{
        [_scsDeviceBtn setTitleColor:[UIColor colorWithRed:77.0/255 green:77.0/255 blue:77.0/255 alpha:1] forState:UIControlStateNormal];
        _scsDeviceBtn.backgroundColor = [UIColor whiteColor];
    }
    [window addSubview:_scsDeviceBtn];
    [_scsDeviceBtn addTarget:self action:@selector(choosedSCS) forControlEvents:UIControlEventTouchUpInside];
    _okBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.6, SCREENHEIGHT*0.7, 0, 0)];
    [_okBtn setBackgroundImage:[UIImage imageNamed:@"yes"] forState:UIControlStateNormal];
    [window addSubview:_okBtn];
    
    //5. 出现动画简单
    [UIView animateWithDuration:0.5 animations:^{
        _deviceTypeChooseTitle.frame = CGRectMake(SCREENWIDTH/8, SCREENHEIGHT*0.3, SCREENWIDTH*3/4, SCREENHEIGHT/15);
        _xgzDeviceBtn.frame = CGRectMake(SCREENWIDTH/8, SCREENHEIGHT*0.43, SCREENWIDTH*3/4, SCREENHEIGHT/15);
        _scsDeviceBtn.frame = CGRectMake(SCREENWIDTH/8, SCREENHEIGHT*0.55, SCREENWIDTH*3/4, SCREENHEIGHT/15);
    }];
    
    if (_deviceType != 100) {
        [_okBtn addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
        NSLog(@"设备型号：%ld，1为小罐子，0为手持",(long)_deviceType);
    }
}

- (void)hideAlertView{//确定
    returnByteWorkFlowNo = 0;
    if (_deviceType == 0) {
        pickArray = [[NSArray alloc]initWithObjects:@"片剂",@"胶囊",@"乳胶",@"面粉",@"珍珠粉",@"爽身粉",@"保鲜膜",@"爬行垫",@"奶嘴",@"奶粉",@"饼干",@"减肥药",@"玛卡",@"纸尿裤",@"辣椒粉",@"阿胶",@"巧克力",@"檀木", nil];
        [_typePickView reloadAllComponents];
        [_typePic setImage:[UIImage imageNamed:@"yaopian"]];
        [_typeLabel setText:@"片剂"];
    }else if (_deviceType == 1){
        pickArray = [[NSArray alloc]initWithObjects:@"片剂",@"茶叶",@"枸杞", @"大米",@"奶粉",@"狗粮",nil];
        [_typePickView reloadAllComponents];
        [_typePic setImage:[UIImage imageNamed:@"yaopian"]];
        [_typeLabel setText:@"片剂"];
    }
    //7.隐去动画简单
    [UIView animateWithDuration:0.3 animations:^{
        _deviceTypeChooseTitle.frame = CGRectMake(SCREENWIDTH/2, SCREENHEIGHT/2, 0, 0);
        _xgzDeviceBtn.frame = CGRectMake(SCREENWIDTH/2, SCREENHEIGHT/2, 0, 0);
        _scsDeviceBtn.frame = CGRectMake(SCREENWIDTH/2, SCREENHEIGHT/2, 0, 0);
        _okBtn.frame = CGRectMake(SCREENWIDTH/2, SCREENHEIGHT/2, 0, 0);
    }];

    // 延迟几秒移除视图
    [self performSelector:@selector(remove) withObject:nil afterDelay:1.3];
    //[self chooseCurrentProject];
    
    //搜索设备
    [self searchDevices];
}

- (void)remove{
    [_bgView removeFromSuperview];
}

-(void)choosedXGZ{//选择5000
    [_xgzDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _xgzDeviceBtn.backgroundColor = [UIColor redColor];
    [_scsDeviceBtn setTitleColor:[UIColor colorWithRed:77.0/255 green:77.0/255 blue:77.0/255 alpha:1] forState:UIControlStateNormal];
    _scsDeviceBtn.backgroundColor = [UIColor whiteColor];
    _deviceType = 1;
    NSLog(@"%ld，小罐子",(long)_deviceType);
    
    _okBtn.frame = CGRectMake(SCREENWIDTH*0.6, SCREENHEIGHT*0.7, SCREENWIDTH*0.15, SCREENWIDTH*0.15);
    //6.给背景添加一个手势，后续方便移除视图
    if (_deviceType != 100) {
        [_okBtn addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
        NSLog(@"设备型号：%ld，1为小罐子，0为手持",(long)_deviceType);
    }
}

-(void)choosedSCS{//选择8000
    [_scsDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _scsDeviceBtn.backgroundColor = [UIColor redColor];
    [_xgzDeviceBtn setTitleColor:[UIColor colorWithRed:77.0/255 green:77.0/255 blue:77.0/255 alpha:1] forState:UIControlStateNormal];
    _xgzDeviceBtn.backgroundColor = [UIColor whiteColor];
    _deviceType = 0;
    NSLog(@"%ld，手持式",(long)_deviceType);
    //[self hideAlertView];
    
    _okBtn.frame = CGRectMake(SCREENWIDTH*0.6, SCREENHEIGHT*0.7, SCREENWIDTH*0.15, SCREENWIDTH*0.15);
    if (_deviceType != 100) {
        [_okBtn addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
        NSLog(@"设备型号：%ld，1为小罐子，0为手持",(long)_deviceType);
    }
}

-(void)chooseCurrentProject{//选择当前模型ID，如果是连接状态，写入工作流
    NSString *typeStr = _typeLabel.text;
    projectIDStr = [Tools setModelType:typeStr :_typePic :_deviceType];
    NSLog(@"模型ID改为：%@",projectIDStr);
    if (_myPeripheral != nil && _myPeripheral.state == CBPeripheralStateConnected){
        _workFlowForNow = [Tools getModelRestDataEverytime:projectIDStr :changedScanConfigWorkFlow :_deviceType];
        NSLog(@"得到的云端蓝牙工作流数据块：%@",_workFlowForNow);
        [self sendWorkFlowToBle];//发送给蓝牙，设定当前工作流
        if ([typeStr containsString:@"胶囊"]) {
        //http请求当前模型的建模参数，合成云端工作流结构体，用蓝牙设置为当前工作流。
        }
    }
}

- (IBAction)done:(id)sender {//样品选择
    _typePickView.hidden = YES;
    _done.hidden = YES;
    _typePic.hidden = NO;
    [self chooseCurrentProject];
}

- (IBAction)writeBtn:(id)sender {//采集参比，采集样品，搜索设备一个键
    if (_myPeripheral != nil && _myPeripheral.state == CBPeripheralStateConnected) {
        if ([_writeBtn.currentTitle containsString:@"参比"]) {
            [self collectCB];//采参比
        }else {
            [self collectIntent];//采样品
        }
    }else{//搜索设备(连接设备)[connect]
        [self searchDevices];
    }
}

- (IBAction)moniduankai:(id)sender {
    
}


- (IBAction)disconnect:(id)sender {
    if (_myPeripheral != nil) {
        [_myCentralManager cancelPeripheralConnection:_myPeripheral];
    }
}


- (IBAction)canbi:(id)sender {
     if (_myPeripheral != nil && _myPeripheral.state == CBPeripheralStateConnected) {
         [self collectCB];
     }
}

-(void)sendWorkFlowToBle{
    for (int i = 0; i < _workFlowForNow.count; i++) {
        [self writeToPeripheral:_workFlowForNow[i] :_workFlowForNowCharacteristic];
    }
    NSString* extLight = _workFlowForNow[_workFlowForNow.count-1];
    extLight = [extLight substringWithRange:NSMakeRange(11, 1)];
    NSLog(@"%@",extLight);
    if ([extLight intValue] == 1) {
        //[self writeToPeripheral:@"01" :_ladengCharacteristic];
        isdanliang = NO;
    }else if ([extLight intValue] == 2){
        isdanliang = YES;
    }else{
        isdanliang = NO;
    }
}

-(void)setAllReady{
    if (isReconnected == NO) {
        NSTimer *timerStart = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(allReady) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timerStart forMode:NSDefaultRunLoopMode];
    }else{
        NSTimer *timerStart = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(allReady) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timerStart forMode:NSDefaultRunLoopMode];
        //isReconnected = NO;
    }
}

-(void)warningCB{
    [self stoping];//停止loading
    [_uplabel setText:@"请重新采集参比！"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"参比采集失败！" message:@"请正确使用参比板采集参比！" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil
                                   ];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"重新采集" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self collectCB];
    }];
    [alertController addAction : cancelAction];
    [alertController addAction: okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)warningIntent{
    [self stoping];//停止loading
    [_uplabel setText:@"请重新采集样品！"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"样品采集失败！" message:@"请重新采集样品！" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil
                                   ];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"重新采样" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self collectIntent];
    }];
    [alertController addAction : cancelAction];
    [alertController addAction: okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)collectCB{
    [self initScan];
    statement = 0;
    [_uplabel setText:@"正在采集参比..."];
    isScanningTitle = @"正在采集参比...";
    [AboutUI showIng:isScanningTitle :_mActivityIndicatorView :_ingBgView :_deviceTypeChooseTitle];
}

- (void)collectIntent{//采集样品
    [self initScan];
    statement = 1;
    _showResultNow = nil;
    _showResultNow = [NSMutableString stringWithString:@""];
    [_uplabel setText:@"正在采集样品..."];
    isScanningTitle = @"正在采集样品...";
    [AboutUI showIng:isScanningTitle :_mActivityIndicatorView :_ingBgView :_deviceTypeChooseTitle];
}

-(void)initScan{
    // 初始化
    packageNo = 1;
    returnByteNo = 0;
    init = 1;
    //[self writeToPeripheral:@"01" :_duojiCharacteristic];
    if (_deviceType == 1) {
        if (isdanliang == YES) {
            [self writeToPeripheral:@"01" :_ladengCharacteristic];
        }
        if ([_writeBtn.currentTitle containsString:@"采集样品"]) {
            //[self writeToPeripheral:@"01" :_duojiCharacteristic];
        }
    }
    [self writeToPeripheral:@"00" :_startscanCharacteristic];
    _writeBtn.userInteractionEnabled = NO;
}

-(void)searchDevices{//搜索设备
    mCount = 0;
    [self.myCentralManager stopScan];
    if(_myPeripherals != nil){
        _myPeripherals = nil;
        _myPeripherals = [NSMutableArray array];
        [_deviceTableView reloadData];
    }
    returnByteWorkFlowNo = 0;
    [self scanClick];
}


-(void)stoping{
    [_mActivityIndicatorView stopAnimating]; // 结束旋转
    [_mActivityIndicatorView setHidesWhenStopped:YES]; //当旋转结束时隐藏
    _ingBgView.frame = CGRectMake(0, 0, 0, 0);
    _deviceTypeChooseTitle.frame = CGRectMake(SCREENWIDTH*0.25, SCREENHEIGHT*0.7, 0, 0);
}

//样品类型typelabel点击事件
-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UILabel *label = (UILabel*)recognizer.view;
    _typePic.hidden = YES;
    _typePickView.hidden = NO;
    _done.hidden = NO;
    NSLog(@"当前类型：%@",label.text);
}

-(void)tapGestureRecognizer
{
    //创建手势对象
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    //轻拍次数
    tap.numberOfTapsRequired = 1;
    //轻拍手指个数
    tap.numberOfTouchesRequired = 1;
    //讲手势添加到指定的视图上
    [_lowestView addGestureRecognizer:tap];
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    //点击视图
    NSLog(@"点击主屏幕");
    _deviceTableView.hidden = YES;
    self.title = @"检测";
}

-(void)setUI{
    _uplabel.frame = CGRectMake(SCREENWIDTH*0.01, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.06);
    _uplabel.textAlignment = NSTextAlignmentCenter;
    _deviceTableView.frame = CGRectMake(SCREENWIDTH*0.097, SCREENHEIGHT*0.2, SCREENWIDTH*0.857, SCREENHEIGHT*0.58);
    _typePic.frame = CGRectMake(SCREENWIDTH*0.198, SCREENHEIGHT*0.3, SCREENWIDTH*0.604, SCREENHEIGHT*0.34);
    _typePickView.frame = CGRectMake(0, SCREENHEIGHT*0.355, SCREENWIDTH, SCREENHEIGHT*0.299);
    _writeBtn.frame = CGRectMake(SCREENWIDTH*0.169, SCREENHEIGHT*0.817, SCREENWIDTH*0.664, SCREENHEIGHT*0.083);
    _typelabelleft.frame = CGRectMake(SCREENWIDTH*0.2, SCREENHEIGHT*0.705, SCREENWIDTH*0.4, SCREENHEIGHT*0.041);
    _done.frame = CGRectMake(SCREENWIDTH*0.8, SCREENHEIGHT*0.599, SCREENWIDTH*0.2, SCREENHEIGHT*0.1);
    _typeLabel.frame = CGRectMake(SCREENWIDTH*0.46, SCREENHEIGHT*0.681, SCREENWIDTH*0.35, SCREENHEIGHT*0.082);
    
    [self.view bringSubviewToFront:_done];
    [self.view sendSubviewToBack:_lowestView];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:17.0/255 green:55.0/255 blue:108.0/255 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];//返回按钮
    self.title = @"检测";
    [_writeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_writeBtn setBackgroundColor:[UIColor colorWithRed:20.0/255 green:61.0/255 blue:122.0/255 alpha:1]];
    _writeBtn.layer.cornerRadius = SCREENHEIGHT*0.041;//圆角的弧度
    _writeBtn.layer.borderWidth = 3.0f;
    _writeBtn.layer.borderColor = [[UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1]CGColor];
    
    [_disconnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_disconnect setBackgroundColor:[UIColor colorWithRed:20.0/255 green:61.0/255 blue:122.0/255 alpha:1]];
    _disconnect.layer.cornerRadius = 15;//圆角的弧度
    _disconnect.layer.borderWidth = 1.0f;
    _disconnect.layer.borderColor = [[UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1]CGColor];
    
    
    _typeLabel.layer.borderWidth = 4.0f;
    _typeLabel.layer.cornerRadius = SCREENHEIGHT*0.041;
    _typeLabel.layer.borderColor = [[UIColor colorWithRed:20.0/255 green:61.0/255 blue:122.0/255 alpha:1]CGColor];
    _typePickView.backgroundColor  = [UIColor clearColor];
     /*
    UIImage* img = [UIImage imageNamed:@"btnyellow"];
    img = [self TransformtoSize:CGSizeMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.082)];
    
    UIColor * color = [UIColor colorWithPatternImage:img];//image为需要添加的背景图
    [_typeLabel setBackgroundColor:color];
    */
    
    [_uplabel setText:@"请打开蓝牙"];
    _typePickView.hidden = YES;
    _done.hidden = YES;
    _deviceTableView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
