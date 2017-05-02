//
//  ResultViewController.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/30.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "ResultViewController.h"
#import "DateValueFormatter.h"
#import "SetValueFormatter.h"
#define screenWidth  [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define ARC4RANDOM_MAX      0x100000000

@import Charts;
@interface ResultViewController ()
{
    double Ymax;
    double Ymin;
}
@property (nonatomic,strong) LineChartView * lineView;
@property (nonatomic,strong) UILabel * markY;
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _type.frame = CGRectMake(screenWidth*0.0845, screenHeight*0.12, screenWidth*0.8575, screenHeight*0.08*4);
    if ([_name containsString:@"奶粉"] || [_name containsString:@"能量"]){
        _type.textAlignment = NSTextAlignmentLeft;
    }else{
        _type.textAlignment = NSTextAlignmentCenter;
    }
    [_type setText:_name];
    NSLog(@"结果页数据：%@",_name);
    self.title = @"检测结果";
    // Do any additional setup after loading the view.
    Ymax = [[_dataXGDArray valueForKeyPath:@"@max.floatValue"]doubleValue];
    Ymin = [[_dataXGDArray valueForKeyPath:@"@min.floatValue"]doubleValue];
    NSLog(@"最大最小值：%f,%f",Ymax,Ymin);
    //吸光度图谱
    [self.view addSubview:self.lineView];
    self.lineView.data = [self setData];
}

//折线图
- (LineChartView *)lineView {
    if (!_lineView) {
        _lineView = [[LineChartView alloc] initWithFrame:CGRectMake(0, screenHeight*0.43, screenWidth*0.98, screenHeight*0.55)];
        _lineView.delegate = self;//设置代理
        _lineView.backgroundColor =  [UIColor whiteColor];
        _lineView.noDataText = @"暂无数据";
        _lineView.chartDescription.enabled = YES;
        _lineView.scaleYEnabled = YES;//取消Y轴缩放
        _lineView.autoScaleMinMaxEnabled = YES;//!!!
        _lineView.doubleTapToZoomEnabled = YES;//双击缩放
        _lineView.dragEnabled = YES;//启用拖拽图标
        _lineView.dragDecelerationEnabled = YES;//拖拽后是否有惯性效果
        _lineView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        //设置滑动时候标签
        ChartMarkerView *markerY = [[ChartMarkerView alloc]init];
        markerY.offset = CGPointMake(-999, -8);
        markerY.chartView = _lineView;
        _lineView.marker = markerY;
        [markerY addSubview:self.markY];
        
        //获取左边Y轴
        _lineView.rightAxis.enabled = NO;//不绘制右边轴
        ChartYAxis *leftAxis = _lineView.leftAxis;
        leftAxis.labelCount = 5;//Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.forceLabelsEnabled = NO;//不强制绘制指定数量的label
        leftAxis.axisMinValue = Ymin;//设置Y轴的最小值
        leftAxis.axisMaxValue = Ymax;//设置Y轴的最大值
        leftAxis.inverted = NO;//是否将Y轴进行上下翻转
        leftAxis.axisLineColor = [UIColor blackColor];//Y轴颜色
        
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//label位置
        leftAxis.labelTextColor = [UIColor blackColor];//文字颜色
        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
        leftAxis.gridColor = [UIColor grayColor];//网格线颜色
        leftAxis.gridAntialiasEnabled = NO;//开启抗锯齿
        ChartXAxis *xAxis = _lineView.xAxis;
        xAxis.granularityEnabled = YES;//设置重复的值不显示
        xAxis.labelPosition= XAxisLabelPositionBottom;//设置x轴数据在底部
        xAxis.gridColor = [UIColor grayColor];
        xAxis.labelTextColor = [UIColor blackColor];//文字颜色
        xAxis.axisLineColor = [UIColor grayColor];
        _lineView.maxVisibleCount = 999;
        //描述及图例样式
        [_lineView setDescriptionText:@"吸光度"];
        _lineView.legend.enabled = NO;
        
        [_lineView animateWithXAxisDuration:1.0f];
    }
    return _lineView;
}

- (LineChartData *)setData{
    NSInteger xVals_count = _dataBCArray.count;//X轴上要显示多少条数据
    //X轴上面需要显示的数据
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < xVals_count; i++) {
        NSString *Xdata = [NSString stringWithFormat:@"%@", _dataBCArray[i]];
        [xVals addObject: Xdata];
    }
    _lineView.xAxis.valueFormatter = [[DateValueFormatter alloc]initWithArr:xVals];
    
    //对应Y轴上面需要显示的数据
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < xVals_count; i++) {
        double a;
        a = [_dataXGDArray[i] doubleValue];
        ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:i y:a];
        [yVals addObject:entry];
    }
    
    LineChartDataSet *set1 = nil;
    if (_lineView.data.dataSetCount > 0) {
        LineChartData *data = (LineChartData *)_lineView.data;
        set1 = (LineChartDataSet *)data.dataSets[0];
        set1.values = yVals;
        set1.valueFormatter = [[SetValueFormatter alloc]initWithArr:yVals];
        return data;
    }else{
        //创建LineChartDataSet对象
        set1 = [[LineChartDataSet alloc]initWithValues:yVals label:nil];
        //设置折线的样式
        set1.lineWidth = 2.0/[UIScreen mainScreen].scale;//折线宽度
        set1.drawValuesEnabled = YES;//是否在拐点处显示数据
        set1.valueFormatter = [[SetValueFormatter alloc]initWithArr:yVals];
        
        set1.valueColors = @[[UIColor brownColor]];//折线拐点处显示数据的颜色
        
        [set1 setColor:[UIColor blueColor]];//折线颜色
        set1.highlightColor = [UIColor redColor];
        set1.drawSteppedEnabled = NO;//是否开启绘制阶梯样式的折线图
        //折线拐点样式
        set1.drawCirclesEnabled = NO;//是否绘制拐点
        set1.drawFilledEnabled = NO;//是否填充颜色
        
        //将 LineChartDataSet 对象放入数组中
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        //添加第二个LineChartDataSet对象
        
        NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
        for (int i = 0; i <  xVals_count; i++) {
            double a = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 1000000);
            a = a/1000000;
            ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:i y:a];
            [yVals2 addObject:entry];
        }
        LineChartDataSet *set2 = [set1 copy];
        set2.values = yVals2;
        set2.drawValuesEnabled = NO;
        [set2 setColor:[UIColor greenColor]];
        
        //[dataSets addObject:set2];
        //创建 LineChartData 对象, 此对象就是lineChartView需要最终数据对象
        LineChartData *data = [[LineChartData alloc]initWithDataSets:dataSets];
        
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];//文字字体
        [data setValueTextColor:[UIColor blackColor]];//文字颜色
        
        return data;
    }
}

//当前点击的点显示数值
- (UILabel *)markY{
    if (!_markY) {
        _markY = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
        _markY.font = [UIFont systemFontOfSize:15.0];
        _markY.textAlignment = NSTextAlignmentCenter;
        _markY.text =@"";
        _markY.textColor = [UIColor whiteColor];
        _markY.backgroundColor = [UIColor grayColor];
    }
    return _markY;
}

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight {
    _markY.text = [NSString stringWithFormat:@"%.8f",(double)entry.y];
    //将点击的数据滑动到中间
    [_lineView centerViewToAnimatedWithXValue:entry.x yValue:entry.y axis:[_lineView.data getDataSetByIndex:highlight.dataSetIndex].axisDependency duration:1.0];
}

- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"XGD"]) {
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
