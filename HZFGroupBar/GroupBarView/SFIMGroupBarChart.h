//
//  SFIMGroupBarChart.h
//  HZFGroupBar
//
//  Created by Eric Huang on 2019/12/8.
//  Copyright © 2019 hzf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIMGroupBarItem.h"

@protocol SFIMGroupBarChartDelegate <NSObject>
@optional

- (void)selectedGroupBarAtIndex:(NSInteger)selectedIndex;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SFIMGroupBarChart : UIScrollView

// delegate
@property (nonatomic, strong) id<SFIMGroupBarChartDelegate> barChartDelegate;

- (void)refreshGroupBarChart;

//- (instancetype)initWithFrame:(CGRect)frame
//                dataItemArray:(NSMutableArray<SFIMGroupBarItem *> *)dataItemArray
//                    topNumber:(NSNumber *)topNumbser
//                 bottomNumber:(NSNumber *)bottomNumber;

/**
 dataItemArray
 */
@property (nonatomic, strong) NSMutableArray<SFIMGroupBarItem *> *dataItemArray;

/**
 纵坐标最高点
 */
@property (nonatomic, strong) NSNumber *top;

/**
 纵坐标最低点
 */
@property (nonatomic, strong) NSNumber *bottom;

@end

NS_ASSUME_NONNULL_END
