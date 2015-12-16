//
//  WaterFlowView.m
//  瀑布流
//
//  Created by 郑雨鑫 on 15/11/5.
//  Copyright © 2015年 郑雨鑫. All rights reserved.
//

#import "WaterFlowView.h"
#import "WaterFlowViewCell.h"
#import "UIView+Extension.h"



#define  numberOfColumnsDefault 3
#define  heigthOfCellDefault 70
#define  marginOfTypeDefault 8

@interface WaterFlowView()
@property (nonatomic,strong) NSMutableArray *allFrame;
@property (nonatomic,strong) NSMutableDictionary *allCell;
@property (nonatomic,strong) NSMutableSet *resuableCell;

@end

@implementation WaterFlowView

-(NSMutableArray *)allFrame
{
    if (_allFrame==nil) {
        _allFrame=[NSMutableArray array];
    }
    return _allFrame;
}
-(NSMutableDictionary *)allCell
{
    if (_allCell==nil) {
        _allCell=[NSMutableDictionary dictionary];
    }
    return _allCell;
}

-(NSMutableSet *)resuableCell
{
    if (_resuableCell==nil) {
        _resuableCell=[NSMutableSet set];
    }
    return _resuableCell;
}

-(CGFloat)weightOfCell
{
    NSUInteger numberOfColumns=[self numberOfColumns];
    
    CGFloat LeftM=[self marginOfType:WaterflowViewMarginTypeLeft];
    CGFloat RightM=[self marginOfType:WaterflowViewMarginTypeRight];
    CGFloat ColumnsM=[self marginOfType:WaterflowViewMarginTypeColumn];
    
    CGFloat cellW=(self.frame.size.width-LeftM-RightM-ColumnsM*(numberOfColumns-1))/numberOfColumns;
    
    return cellW;

}
/**
 *  显示在屏幕上
 *
 *  @param newSuperview <#newSuperview description#>
 */
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}
-(void)reloadData
{
    
    [self.allCell.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.allFrame removeAllObjects];
    [self.allCell removeAllObjects];
    [self.resuableCell removeAllObjects];
   
    //cell总数
    NSUInteger numberOfCell=[self.dataSource numberOfCellsInWaterflowView:self];
    
    //cell列数
    NSUInteger numberOfColumns=[self numberOfColumns];
    
    //cell宽度
    CGFloat topM=[self marginOfType:WaterflowViewMarginTypeTop];
    CGFloat bottonM=[self marginOfType:WaterflowViewMarginTypeBottom];
    CGFloat LeftM=[self marginOfType:WaterflowViewMarginTypeLeft];
    CGFloat RightM=[self marginOfType:WaterflowViewMarginTypeRight];
    CGFloat RowM=[self marginOfType:WaterflowViewMarginTypeRow];
    CGFloat ColumnsM=[self marginOfType:WaterflowViewMarginTypeColumn];
   
    CGFloat cellW=[self weightOfCell];


    
    CGFloat maxYOfColunms[numberOfColumns];
    for (int i=0; i<numberOfColumns; i++) {
        maxYOfColunms[i]=0;
    }
    
    
    //cell高度
    for (int i=0; i<numberOfCell;i++) {
        
        int MaxYOfColunm=0;
        
        CGFloat maxY=maxYOfColunms[MaxYOfColunm];
       
        for (int i=1; i<numberOfColumns; i++) {
            if (maxY>maxYOfColunms[i]) {
                MaxYOfColunm=i;
                maxY=maxYOfColunms[i];
            }
        }
        
        CGFloat cellX=LeftM+(cellW+ColumnsM)*MaxYOfColunm;
       
        CGFloat cellY=0.0;
        if (maxY==0.0) {
            cellY=topM;
        }else{
            cellY=maxY+RowM;
        }

        CGFloat cellH=[self heigetOfCellAtIndex:i];
       // NSLog(@"%@",NSStringFromCGSize(CGSizeMake(cellH, cellH)));

        CGRect cellFrame=CGRectMake(cellX, cellY, cellW, cellH);
        
        [self.allFrame addObject:[NSValue valueWithCGRect:cellFrame]];
       
        maxYOfColunms[MaxYOfColunm]=cellY+cellH;
        

    }
    
    CGFloat contentH=maxYOfColunms[0];
    
    for (int i=1; i<numberOfColumns; i++) {
        if (contentH<maxYOfColunms[i]) {
            contentH=maxYOfColunms[i];
        }
    }
    NSLog(@"%@",NSStringFromCGSize(CGSizeMake(contentH, contentH)));
    contentH +=bottonM;
    self.contentSize=CGSizeMake(0, contentH);
    
    NSLog(@"%@",NSStringFromCGSize(self.contentSize));
    
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger numberOfCells=self.allFrame.count;
    for (int i=0; i<numberOfCells; i++) {
        
        CGRect frameOfCell=[self.allFrame[i] CGRectValue];
        
        WaterFlowViewCell *cell=self.allCell[@(i)];
        
       
        if ([self isInTheScreen:frameOfCell]) {
            if (cell==nil) {
                cell=[self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame=frameOfCell;
                [self addSubview:cell];
                self.allCell[@(i)]=cell;
            }
        }else{
            
            if (cell) {
                
                [cell removeFromSuperview];
                self.allCell[@(i)]=nil;
                
                [self.resuableCell addObject:cell];
                
            }
        
        }

        
    }

}

-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block WaterFlowViewCell *resuablecell=nil;
    
    [self.resuableCell enumerateObjectsUsingBlock:^(WaterFlowViewCell *cell, BOOL *stop) {
       
        if ([cell.ID isEqualToString:identifier]) {
            resuablecell=cell;
            *stop=YES;
        }
    }];
    
    if (resuablecell) {
        [self.resuableCell removeObject:resuablecell];
    }
    return resuablecell;

}
#pragma mark 事件处理

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   
    UITouch *touch=[touches anyObject];
    
    CGPoint point=[touch locationInView:self];
    
    __block NSNumber *index =0;
    
    [self.allCell enumerateKeysAndObjectsUsingBlock:^(id key, WaterFlowViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            index=key;
            *stop=YES;
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) {
        [self.delegate waterflowView:self didSelectAtIndex:index.unsignedIntegerValue];
    }
    


}
#pragma mark - 私有方法
-(BOOL)isInTheScreen:(CGRect)frame
{
    return  (CGRectGetMaxY(frame)>self.contentOffset.y && CGRectGetMaxY(frame)<(self.contentOffset.y+self.height));
}

-(CGFloat)marginOfType:(WaterflowViewMargin)type
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginAtType:)]) {
        return [self.delegate waterflowView:self marginAtType:type];
    }else{
        return marginOfTypeDefault;
    }

}
-(NSUInteger)numberOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
       return  [self.dataSource numberOfColumnsInWaterflowView:self];
    }else{
        return numberOfColumnsDefault;
    }
        
}

-(CGFloat)heigetOfCellAtIndex:(int)index
{

    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    }else{
        return heigthOfCellDefault;
    }
}
@end
