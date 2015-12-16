//
//  WaterFlowView.h
//  瀑布流
//
//  Created by 郑雨鑫 on 15/11/5.
//  Copyright © 2015年 郑雨鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterFlowViewCell.h"
@class WaterFlowView,MushroomCell;

typedef enum {
    WaterflowViewMarginTypeTop,
    WaterflowViewMarginTypeBottom,
    WaterflowViewMarginTypeLeft,
    WaterflowViewMarginTypeRight,
    WaterflowViewMarginTypeColumn, // 每一列
    WaterflowViewMarginTypeRow,
} WaterflowViewMargin;

@protocol WaterflowViewDataSource <NSObject>
@required

-(NSUInteger)numberOfCellsInWaterflowView:(WaterFlowView *)watherflowView;
-(WaterFlowViewCell *)waterflowView:(WaterFlowView *)watherflowView cellAtIndex:(NSUInteger)index;

@optional

-(NSUInteger)numberOfColumnsInWaterflowView:(WaterFlowView *)watherflow;

@end

@protocol WaterflowViewDelegate <UIScrollViewDelegate>
@optional
-(CGFloat)waterflowView:(WaterFlowView *)watherflowView heightAtIndex:(NSUInteger)index;
-(void)waterflowView:(WaterFlowView *)watherflowView didSelectAtIndex:(NSUInteger)index;
-(CGFloat)waterflowView:(WaterFlowView *)watherflowView marginAtType:(WaterflowViewMargin)type;

@end


@interface WaterFlowView : UIScrollView

@property (nonatomic,weak) id <WaterflowViewDataSource> dataSource;
@property (nonatomic,weak) id <WaterflowViewDelegate> delegate;
/**
 刷新数据
 */
-(void)reloadData;

-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/**
 行宽
 */
-(CGFloat)weightOfCell;
@end
