//
//  ViewController.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/28.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "ViewController.h"
#import "WorkFlowViewController.h"

@interface ViewController ()<WorkFlowChooseDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view bringSubviewToFront:_done];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:17.0/255 green:55.0/255 blue:108.0/255 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [_writeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_writeBtn setBackgroundColor:[UIColor colorWithRed:20.0/255 green:61.0/255 blue:122.0/255 alpha:1]];
    _writeBtn.layer.cornerRadius = 30.5;//圆角的弧度
    _writeBtn.layer.borderWidth = 3.0f;
    _writeBtn.layer.borderColor = [[UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1]CGColor];
    _typeLabel.layer.borderWidth = 4.0f;
    _typeLabel.layer.cornerRadius = 18;
    _typeLabel.layer.borderColor = [[UIColor redColor]CGColor];
    //_typeLabel.backgroundColor = [UIColor grayColor];
    [_uplabel setText:@"请打开蓝牙"];
    workFlowPoints = 800;
    workFlowPointsType = 2;//2即为把420点差分成800
    testduojiladeng = @"0";
    isdanliang = NO;
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];//返回按钮
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"配置";
    _typePickView.hidden = YES;
    _done.hidden = YES;
    _deviceTableView.delegate = self;
    _deviceTableView.dataSource = self;
    _deviceTableView.hidden = YES;
    _typePickView.backgroundColor  = [UIColor whiteColor];
    _typePickView.delegate = self;
    _typePickView.dataSource = self;
    pickArray = [[NSArray alloc] initWithObjects:@"乳胶",@"爬爬垫", @"珍珠粉",@"保鲜膜",@"奶嘴",@"药品",@"木材",@"奶粉",nil];
    _typeLabel.userInteractionEnabled = YES;
    projectIDStr = @"234";
    formerType = @"234";
    //初始化CBCentralManager
    workFlowArr = [[NSMutableArray alloc]init];
    workFlowName = [[NSMutableArray alloc]init];
    workFlowDetail = [[NSMutableArray alloc]init];
    outsideArr = [[NSMutableArray alloc]init];
    _myPeripherals = [NSMutableArray array];
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@"NO"};
    self.myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [_typeLabel addGestureRecognizer:labelTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//1.开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [_uplabel setText:@"蓝牙已打开, 请搜索设备!"];
            NSLog(@"蓝牙已打开, 请扫描外设!");
            [_uplabel setTextColor:[UIColor blackColor]];
            break;
        default:
            [_uplabel setText:@"请打开蓝牙！"];
            [_uplabel setTextColor:[UIColor redColor]];
            break;
    }
}

//2.点击连接设备按钮时扫描周边设备
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

//4.连接
- (void)connectClick{
    workFlowCount = 0;
    delayCount = 1;
    [self.myCentralManager connectPeripheral:_myPeripheral options:nil];
    [_uplabel setText:@"正在连接设备..."];
    [_uplabel setTextColor:[UIColor blackColor]];
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self.myPeripheral setDelegate:self];
    [self.myPeripheral discoverServices:nil];
    NSLog(@"扫描服务...");
    if (isReconnected == NO) {
        NSTimer *timerStart = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setStartTitle) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timerStart forMode:NSDefaultRunLoopMode];
    }else{
        NSTimer *timerStart = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setStartTitle) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timerStart forMode:NSDefaultRunLoopMode];
        isReconnected = NO;
    }
}

-(void)setStartTitle{
    [_writeBtn setTitle:@"采集参比" forState:UIControlStateNormal];
    [_uplabel setText:@"设备已连接，请采集参比！"];
    [_uplabel setTextColor:[UIColor blackColor]];
    [self allReady];
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

//已发现characteristcs
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
        //工作流配置列表和具体参数的查找和选择
        if ([c.UUID.UUIDString containsString:@"4113"]) {//读取工作流数量
            [self.myPeripheral readValueForCharacteristic:c];
        }
        if([c.UUID.UUIDString containsString:@"4114"]){//请求工作流配置列表
            self.requestStoredConfigurationCharacteristicList = c;
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

//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral readRSSI];
    //获取本机工作流数量
    if ([characteristic.UUID.UUIDString containsString:@"4113"]) {
        NSData* data = characteristic.value;
        NSString *Number = [Tools hexadecimalString:data];
        Number = [Number substringToIndex:2];
        workFlowNumber = [Number intValue];
        NSLog(@"工作流数量：%d",workFlowNumber);
        NSString *tdata = @"01";
        NSData* value = [Tools dataWithHexstring:tdata];
        [_myPeripheral writeValue:value forCharacteristic:_requestStoredConfigurationCharacteristicList type:CBCharacteristicWriteWithResponse];
    }
    //获取工作流配置列表
    if([characteristic.UUID.UUIDString containsString:@"4115"]){
        NSData* data = characteristic.value;
        NSString* list = [Tools hexadecimalString:data];
        NSLog(@"配置包：%@",list);
        if ([[list substringWithRange:NSMakeRange(0, 2)]containsString:@"1"] && workFlowArr.count == 0) {
            workFlowData = [Tools hexadecimalString:data];
            NSLog(@"配置列表：%@",workFlowData);
            for (int i = 2; i < workFlowNumber * 4; i += 4) {
                [workFlowArr addObject:[workFlowData substringWithRange:NSMakeRange(i, 4)]];
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delayCount*NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    NSLog(@"定时排序操作");
                    testbigstring = workFlowArr[workFlowCount];
                    workFlowCount++;
                    [self requestWorkFlowData];
                    dispatch_time_t littletime = dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
                    dispatch_after(littletime, dispatch_get_main_queue(), ^{
                        [self writeToPeripheral:testbigstring :_outsidesettingCharacteristic];
                        if (workFlowCount == workFlowNumber) {
                            [self writeToPeripheral:workFlowArr[0] :_activeConfigurationCharacteristic];
                            NSLog(@"重置工作流");
                        }
                    });
                });
                delayCount++;
            }
            NSLog(@"工作流：%@",workFlowArr);
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
                //NSLog(@"%c,%d",returnWorkFlowData[returnByteWorkFlowNo],returnByteWorkFlowNo);
                if (returnByteWorkFlowNo == (packageNumber-1)*19) {
                    bool isGetScanConfig = getScanCofig(returnWorkFlowData,&(scanConfigWorkFlow));
                    NSLog(@"有无数据：%d,扫描类型：%s,%hhu(0为column，1为hardma)，点数：%hu，波长：%hu到%hu,平均次数:%hu。",isGetScanConfig,scanConfigWorkFlow.slewScanCfg.head.config_name,scanConfigWorkFlow.slewScanCfg.section[0].section_scan_type,scanConfigWorkFlow.slewScanCfg.section[0].num_patterns,scanConfigWorkFlow.slewScanCfg.section[0].wavelength_start_nm,scanConfigWorkFlow.slewScanCfg.section[0].wavelength_end_nm,scanConfigWorkFlow.slewScanCfg.head.num_repeats);
                    NSString *configName;
                    NSString *configDetail;
                    configName = [[NSString alloc] initWithFormat:@"%s",scanConfigWorkFlow.slewScanCfg.head.config_name];
                    configDetail =  [[NSString alloc] initWithFormat:@"点数：%hu",scanConfigWorkFlow.slewScanCfg.section[0].num_patterns];
                    configDetail = [configDetail stringByAppendingFormat:@"，平均次数：%hu次",scanConfigWorkFlow.slewScanCfg.head.num_repeats];
                    [workFlowName addObject:configName];
                    [workFlowDetail addObject:configDetail];
                    NSLog(@"%@,%@",workFlowName,workFlowDetail);
                }
                returnByteWorkFlowNo++;
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
            [outsideArr addObject:outsideData];
            NSLog(@"%@收到的外部数据",outsideArr);
        }
    }
    
    //扫描，获取第一次写入时返回的数据，需再次写入，再次写入吼获得的才是光谱数据
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
            [_myPeripheral writeValue:myData forCharacteristic:_requestdataCharacteristic type:CBCharacteristicWriteWithResponse];
            NSLog(@"characteristic : %@, data : %@,\nvalue : %@", characteristic, data, value);
        }
    }
    //获取光谱数据并处理
    if([characteristic.UUID.UUIDString containsString:@"4128"]){
        packageNo = packageNo+1;
        NSData* data = characteristic.value;
        //NSString* value = [Tools hexadecimalString:data];
        //NSLog(@"characteristic : %@", characteristic);
        //NSLog(@"\n%@\n 触发vlaue", value);
        //收到的byte数组
        NSUInteger len = [data length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [data bytes], len);
        if (packageNo > 2) {
            for (int c = 0; c<len-1; c++) {
                returnData[returnByteNo] = byteData[c+1];
                if (returnByteNo == 3731) {
                    switch (statement) {
                        case 0:{
                            bool isGetDataCB = getDLPData(returnData,waveLength, cb,workFlowPointsType);
                            [_uplabel setText:@"采集参比完成，请采集样品！"];
                            NSLog(@"%d",isGetDataCB);
                            isCbInited = true;
                            formerType = projectIDStr;
                            init = 0;
                            [_writeBtn setTitle:@"采集样品" forState:UIControlStateNormal];
                            break;
                        }
                        case 1:{
                            bool isGetDataYP = getDLPData(returnData,waveLength, intentsities,workFlowPointsType);
                            NSLog(@"%d",isGetDataYP);
                            [_uplabel setText:@"采集样品完成！"];
                            dataString = [self getAbs:cb intentsities:intentsities];
                            [self getRestData];
                            init = 0;
                            break;
                        }
                    }
                    NSString * obj = @"00";
                    [self writeToPeripheral:obj :_duojiCharacteristic];
                    if (isdanliang == YES) {
                        [self writeToPeripheral:obj :_ladengCharacteristic];
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
            }else {
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


//http服务
-(void)getRestData{
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
                                      @"ProjectId" : projectIDStr,
                                      @"SpectrumData" : dataString
                                      }
                              };
    NSData *data2 = [NSJSONSerialization dataWithJSONObject:dicTest options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data2];
    //返回数据
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *receData = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receData);
    if ([receData containsString:@"异常"]) {
        [_uplabel setText:@"数据异常"];
    }else{
        switch ([projectIDStr intValue]) {
                //其它
            case 0:{
                NSArray *arrys01= [receData componentsSeparatedByString:@"@"];
                NSString* str01=(NSString *)arrys01[2];
                NSArray *arrys02= [str01 componentsSeparatedByString:@"\""];
                NSString* str02=(NSString *)arrys02[0];
                NSLog(@"%@",str02);
                segueToResult = str02;
                picToResult = @"yaowan";
            }
                break;
                //木材
            case 167:{
                NSArray *arrys167= [receData componentsSeparatedByString:@"\""];
                NSString* str167=(NSString *)arrys167[3];
                NSLog(@"%@",str167);
                segueToResult = str167;
                picToResult = @"woods";
            }
                break;
                //奶粉
            case 87:{
                NSArray *arrys87= [receData componentsSeparatedByString:@"\""];
                NSString* str87=(NSString *)arrys87[3];
                NSLog(@"%@",str87);
                segueToResult = str87;
                picToResult = @"naifen";
            }
                break;
                //药品ok
            case 471:{
                NSArray *arrys471= [receData componentsSeparatedByString:@"\""];
                NSString* str471=(NSString *)arrys471[3];
                NSLog(@"%@",str471);
                segueToResult = str471;
                picToResult = @"yaowan";
                [_uplabel setText:str471];
                break;
            }
                //乳胶
            case 234:{
                NSArray *arrys234= [receData componentsSeparatedByString:@"\""];
                NSString* str234=(NSString *)arrys234[3];
                NSLog(@"%@",str234);
                segueToResult = str234;
                picToResult = @"yaowan";
                [_uplabel setText:str234];
                break;
            }
                //爬爬垫
            case 257:{
                NSArray *arrys257= [receData componentsSeparatedByString:@"\""];
                NSString* str257=(NSString *)arrys257[3];
                NSLog(@"%@",str257);
                segueToResult = str257;
                picToResult = @"yaowan";
                [_uplabel setText:str257];
                break;
            }
                //奶嘴
            case 265:{
                NSArray *arrys265= [receData componentsSeparatedByString:@"\""];
                NSString* str265=(NSString *)arrys265[3];
                NSLog(@"%@",str265);
                segueToResult = str265;
                picToResult = @"yaowan";
                [_uplabel setText:str265];
                break;
            }
                //珍珠粉
            case 252:{
                NSArray *arrys252= [receData componentsSeparatedByString:@"\""];
                NSString* str252=(NSString *)arrys252[3];
                NSLog(@"%@",str252);
                picToResult = @"yaowan";
                if ([str252 containsString:@"G"]) {
                    [_uplabel setText:@"优质珍珠粉"];
                    segueToResult = @"优质珍珠粉";
                }else if ([str252 containsString:@"L"]){
                    [_uplabel setText:@"劣质珍珠粉"];
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
                picToResult = @"yaowan";
                [_uplabel setText:str301];
                break;
            }
            default:{
                NSArray *arrys1= [receData componentsSeparatedByString:@"\""];
                NSString* str1=(NSString *)arrys1[3];
                NSLog(@"%@",str1);
                segueToResult = str1;
                picToResult = @"yaowan";
                [_uplabel setText:str1];
                break;
            }
        }
    }
    [self performSegueWithIdentifier:@"result" sender:self];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //结果页
    if ([segue.identifier isEqualToString:@"result"]) {
        ResultViewController* rece = segue.destinationViewController;
        rece.name = segueToResult;
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
            isdanliang = [Tools activeOutside:outsideArr :receStr :_myPeripheral :_duojiCharacteristic :_ladengCharacteristic];
            [_writeBtn setTitle:@"采集参比" forState:UIControlStateNormal];
        }
    }
}

//掉线时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"periheral has disconnect");
    [_uplabel setText:@"连接断开！"];
    [_uplabel setTextColor:[UIColor redColor]];
    [_writeBtn setTitle:@"搜索设备" forState:UIControlStateNormal];
    [workFlowArr removeAllObjects];
    [workFlowName removeAllObjects];
    [workFlowDetail removeAllObjects];
    [outsideArr removeAllObjects];
    receStr = 0;
    isdanliang = NO;
    if (mCount != 0) { //用mcount是否为0来判断是掉线还是自己搜索设备
        delayCount = 1;
        workFlowCount = 0;
        //[_myCentralManager connectPeripheral:_myPeripheral options:nil];
        isReconnected = YES;
    }
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


//tableview的方法,返回rows(行数)
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

//tableview的方法,点击行时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
    //NSLog(@"%lu", (unsigned long)rowNo);
    _deviceTableView.hidden = YES;
    _myPeripheral = [_myPeripherals objectAtIndex:rowNo];
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
    [self writeToPeripheral:@"00" :_ladengCharacteristic];
    [self writeToPeripheral:@"00" :_duojiCharacteristic];
}

//label点击事件
-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UILabel *label = (UILabel*)recognizer.view;
    _typePickView.hidden = NO;
    _done.hidden = NO;
    NSLog(@"当前类型：%@",label.text);
}

- (IBAction)done:(id)sender {
    _typePickView.hidden = YES;
    _done.hidden = YES;
    NSString *type = _typeLabel.text;
    projectIDStr = [Tools setType:type :_typePic];
    NSLog(@"%@",projectIDStr);
}

- (IBAction)writeBtn:(id)sender {
    if (_myPeripheral != nil && _myPeripheral.state == CBPeripheralStateConnected) {
        // 初始化
        packageNo = 1;
        returnByteNo = 0;
        init = 1;
        NSString *obj = @"01";
        [self writeToPeripheral:obj :_duojiCharacteristic];
        if (isdanliang == YES) {
            [self writeToPeripheral:obj :_ladengCharacteristic];
        }
        NSString* value = @"00";
        [self writeToPeripheral:value :_startscanCharacteristic];
        if ([_writeBtn.currentTitle containsString:@"参比"]) {
            statement = 0;
            [_uplabel setText:@"正在采集参比..."];
        }else {
            statement = 1;
            [_uplabel setText:@"正在采集样品..."];
        }
    }else{//搜索设备(连接设备)[connect]
        mCount = 0;
        [self.myCentralManager stopScan];
        if(_myPeripherals != nil){
            _myPeripherals = nil;
            _myPeripherals = [NSMutableArray array];
            [_deviceTableView reloadData];
        }
        [self scanClick];
    }
}

- (IBAction)ladeng:(id)sender {
    if ([testduojiladeng intValue] == 1) {
        testduojiladeng = @"00";
    }else{
        testduojiladeng = @"01";
    }
    NSData *writeValue;
    writeValue = [Tools dataWithHexstring:testduojiladeng];
    NSLog(@"写入%@",writeValue);
    if (_ladengCharacteristic == nil) {
        NSLog(@"未找到UUID");
    }else{
        NSLog(@"要写入的charayic，%@",_ladengCharacteristic);
        [_myPeripheral writeValue:writeValue forCharacteristic:_ladengCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (IBAction)duoji:(id)sender {
    if ([testduojiladeng intValue] == 1) {
        testduojiladeng = @"00";
    }else{
        testduojiladeng = @"01";
    }
    NSData *writeValue;
    writeValue = [Tools dataWithHexstring:testduojiladeng];
    NSLog(@"写入%@",writeValue);
    if (_duojiCharacteristic == nil) {
        NSLog(@"未找到UUID");
    }else{
        [_myPeripheral writeValue:writeValue forCharacteristic:_duojiCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (IBAction)disconnect:(id)sender {
    if (_myPeripheral != nil) {
        [_myCentralManager cancelPeripheralConnection:_myPeripheral];
    }
}

@end
