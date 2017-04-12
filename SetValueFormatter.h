//
//  SetValueFormatter.h
//  Ble for IAS
//
//  Created by wyfnevermore on 2017/3/24.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Charts;
@interface SetValueFormatter : NSObject<IChartValueFormatter>

-(id)initWithArr:(NSArray *)arr;

@end
