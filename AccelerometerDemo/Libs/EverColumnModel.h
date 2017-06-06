//
//  ColumnFenShiChartModel.h
//  TestChart
//
//  Created by Ever on 15/12/18.
//  Copyright © 2015年 Lucky. All rights reserved.
//

#import "ChartModel.h"
#import "YAxis.h"

@class EverChart;
@interface EverColumnModel : ChartModel
-(void)drawSerie:(EverChart *)chart serie:(NSMutableDictionary *)serie;
@end
