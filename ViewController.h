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


@interface ViewController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate,UITableViewDataSource, UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    uScanConfig scanConfigWorkFlow;//用来接收设备中的工作流
    uScanConfig changedScanConfigWorkFlow;
    WorkFlowExt outsideWorkFlow;
    NSArray *pickArray;
    int init;
    int packageNumber;
    int packageNo;
    int returnByteNo;
    int packageWorkFlowNo;
    int returnByteWorkFlowNo;
    int statement;
    int isRepeat;
    int workFlowNumber;
    NSInteger mCount;
    char returnWorkFlowBlueData[212];
    char returnWorkFlowBlueDataExt[212];
    char returnWorkFlowData[1000];
    char returnData[4000];
    bool isGetCb;
    bool isCbInited;
    bool isReconnected;
    BOOL isdanliang;
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
    NSString *testduojiladeng;
    NSString *segueToResult;
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
    int testnumber;
    NSString *bluedatastr;
}

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
@property (weak, nonatomic) IBOutlet UILabel *uplabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIButton *writeBtn;
@property (weak, nonatomic) IBOutlet UIButton *done;
@property (weak, nonatomic) IBOutlet UIPickerView *typePickView;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property (weak, nonatomic) IBOutlet UIImageView *typePic;

- (IBAction)done:(id)sender;
- (IBAction)writeBtn:(id)sender;

- (IBAction)ladeng:(id)sender;
- (IBAction)duoji:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)transWorkFlow:(id)sender;
- (IBAction)getData:(id)sender;

@end

