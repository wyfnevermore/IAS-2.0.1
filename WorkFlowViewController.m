//
//  WorkFlowViewController.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/30.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "WorkFlowViewController.h"

@interface WorkFlowViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL isClick;
}
@end

@implementation WorkFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"工作流选择";
    self.tableViewC.dataSource = self;
    self.tableViewC.delegate = self;
    AboutUI *abUI = [[AboutUI alloc]init];
    [abUI setExtraCellLineHidden:_tableViewC];
    _isClickWorkFlow = NO;
    isClick = NO;
    _lastpath = [NSIndexPath indexPathForItem:_returnWorkFlow inSection:0];
    //_configName = [[NSMutableArray alloc]init];
    //_configurationDetail = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    NSLog(@"viewdidload");
    [_tableViewC reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//每一组有多少行，
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _configName.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"configureCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    //选中效果
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //辅助视图的样式
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    //设置左侧图片
    //cell.imageView.image = [UIImage imageNamed:@""];
    //标题视图
    cell.textLabel.text = [_configName objectAtIndex:indexPath.row];
    //副标题视图
    cell.detailTextLabel.text = [_configurationDetail objectAtIndex:indexPath.row];
    NSLog(@"cell");
    
    NSUInteger row = [indexPath row];
    NSUInteger oldRow = _returnWorkFlow;
    //如何点击当前的cell 最右边就会出现一个对号 ，在点击其他的cell 对号显示当前，上一个小时
    cell.accessoryType = (row==oldRow)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    return cell;
}

//tableview的方法,点击行时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
    //NSLog(@"第%lu行", (unsigned long)rowNo);
    _returnWorkFlow = rowNo;
    isClick = YES;
    NSInteger newRow = [indexPath row];
    NSInteger oldRow = (_lastpath != nil) ? [_lastpath row] : 0;
    if (newRow != oldRow) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (oldRow == 0) {
            NSIndexPath *path=[NSIndexPath indexPathForItem:0 inSection:0];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:path];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_lastpath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        _lastpath = indexPath;
    }
    // 取消选择状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _isClickWorkFlow = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //呼叫协议中的方法
        if (_returnWorkFlow != 10000000) {
            [self.delegate passValue:_returnWorkFlow];
        }
        NSLog(@"clicked navigationbar back button");
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
