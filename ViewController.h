//
//  ViewController.h
//  IAS
//
//  Created by wyfnevermore on 2017/3/28.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "Tools.h"
#import "ResultViewController.h"
#import "dlpdata.h"
#import "AboutUI.h"
#import "Reachability.h"
#import "NetWork.h"

@interface ViewController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate,UITableViewDataSource, UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    uScanConfig scanConfigWorkFlow;//用来接收设备中的工作流
    uScanConfig changedScanConfigWorkFlow;
    WorkFlowExt outsideWorkFlow;
    NSArray *pickArray;//样品数组
    
    int packageNumber;//计数用
    int packageNo;//计数用
    int returnByteNo;//计数用
    int packageWorkFlowNo;//计数用
    int returnByteWorkFlowNo;//计数用
    int statement;//0为采集参比，1为采集样品
    int isRepeat;//是否扫描到重复的设备
    int workFlowNumber;//工作流数量
    NSInteger mCount;
    char returnWorkFlowBlueData[212];
    char returnWorkFlowBlueDataExt[212];
    char returnWorkFlowData[1000];
    char returnData[4000];
    BOOL isAppBtnPress;
    bool isGetCb;
    bool isCaijiInited;
    bool isReconnected;
    BOOL isdanliang;
    BOOL isSystemConnectedAllover;//系统自带的全部完成，做这个标记的目的是因为第二次连接时也会进411D，而进411D只能是app按键进或者物理按键进
    double cb[864];
    double aBS[864];
    double intentsities[864];
    double waveLength[864];
    NSData *workFlowObject;
    NSString *dataString;
    NSString *projectIDStr;
    NSString *workFlowCountData;
    NSString *workFlowData;
    NSString *testbigstring;
    NSString *picToResult;
    NSString *formerType;
    NSInteger receStr;
    NSMutableArray *workFlowArr;
    NSMutableArray *workFlowName;
    NSMutableArray *workFlowDetail;
    NSMutableArray *outsideArr;
    NSMutableArray *getedModelWorkFlow;
    NSArray *outsideItemChoosedNow;
    NSTimer *timer;
    int workFlowCount;
    int delayCount;
    int workFlowPoints;
    int workFlowPointsType;
    int outsidedatapackageNumber;
    NSString *bluedatastr;
    NSString *isScanningTitle;
    double dataMax;
<<<<<<< HEAD
    double scanTime;
    NSTimer *timerStart;
    NetWork *netWork;
=======
>>>>>>> origin/master
}
//BLE
@property (strong, nonatomic) CBCentralManager* myCentralManager;
@property (strong, nonatomic) NSMutableArray* myPeripherals;
@property (strong, nonatomic) CBPeripheral* myPeripheral;
@property (strong, nonatomic) NSMutableArray* nServices;
@property (strong, nonatomic) NSMutableArray* nCharacteristics;
@property (strong, nonatomic) NSMutableArray* transXGD;
@property (strong, nonatomic) NSMutableArray* transBC;
@property (strong, nonatomic) CBCharacteristic* startscanCharacteristic;
@property (strong, nonatomic) CBCharacteristic* requestdataCharacteristic;
@property (strong, nonatomic) CBCharacteristic* requestStoredConfigurationCharacteristicList;
@property (strong, nonatomic) CBCharacteristic* requestScanConfigurationDataCharacteristic;
@property (strong, nonatomic) CBCharacteristic* activeConfigurationCharacteristic;
@property (strong, nonatomic) CBCharacteristic* ladengCharacteristic;
@property (strong, nonatomic) CBCharacteristic* duojiCharacteristic;
@property (strong, nonatomic) CBCharacteristic* outsidesettingCharacteristic;
@property (strong, nonatomic) CBCharacteristic* workFlowForNowCharacteristic;
@property (strong, nonatomic) CBCharacteristic* deviceStatusCharacteristic;
@property (strong, nonatomic) CBCharacteristic* requestScanTimeCharacteristic;
@property (strong, nonatomic) NSMutableString *showResultNow;
@property (strong, nonatomic) NSMutableArray* isCurrentDataArray;
<<<<<<< HEAD
@property (nonatomic,weak) Reachability *hostReach;
=======
>>>>>>> origin/master

//UI相关
@property (strong, nonatomic)UIView *bgView;//半透明背景
@property (strong, nonatomic)UIView *ingBgView;//半透明背景
@property (strong, nonatomic)UIView *alertView;//假设为弹窗
@property (strong, nonatomic)UIButton *xgzDeviceBtn;//小罐子
@property (strong, nonatomic)UIButton *scsDeviceBtn;//手持式
@property (strong, nonatomic)UIButton *okBtn;
@property (strong, nonatomic)UILabel *deviceTypeChooseTitle;//@"请选择设备型号"
@property (assign, nonatomic)NSInteger deviceType;

@property (weak, nonatomic) IBOutlet UILabel *uplabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typelabelleft;
@property (weak, nonatomic) IBOutlet UIButton *writeBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *typePickView;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property (weak, nonatomic) IBOutlet UIImageView *typePic;
@property (weak, nonatomic) IBOutlet UIButton *disconnect;
@property (weak, nonatomic) IBOutlet UIImageView *lowestView;
<<<<<<< HEAD
@property (weak, nonatomic) IBOutlet UIButton *reCollectCB;
@property (weak, nonatomic) IBOutlet UILabel *currentDeviceName;
@property (weak, nonatomic) IBOutlet UIWebView *loadingWebView;
=======
@property (weak, nonatomic) IBOutlet UIButton *canbi;
>>>>>>> origin/master

- (IBAction)writeBtn:(id)sender;

- (IBAction)moniduankai:(id)sender;




- (IBAction)disconnect:(id)sender;
<<<<<<< HEAD
- (IBAction)reCollectCB:(id)sender;

- (BOOL) connectedToNetwork; 
=======
>>>>>>> origin/master


- (IBAction)canbi:(id)sender;

@end

