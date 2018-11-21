//
//  XTWaterFlowView.m
//  XTWaterFlowView
//
//  Created by zhangjing on 2018/11/21.
//  Copyright © 2018 214644496@qq.com. All rights reserved.
//

#import "XTWaterFlowView.h"
#import "XTWaterFlowViewCell.h"
#define XTWaterFlowViewDefaultCellH 50
#define XTWaterFlowViewDefaultColumnsCount 3
#define XTWaterFlowViewDefaultMargin 10

#pragma mark - ========================类扩展=======================
@interface XTWaterFlowView ()

/**
 *  所有cell的frame数组
 */
@property (nonatomic, strong) NSMutableDictionary *cellFrames;
/**
 *  正在展示的cell字典，key是cell的index
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;
/**
 *  缓存cell的Set
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;

@end

#pragma mark - ========================类实现=======================
@implementation XTWaterFlowView


- (void)viewDidMoveToWindow{
    [super viewDidMoveToWindow];
    if (self.displayingCells.count == 0) {
        [self reloadData];
        [self internal_initInfiniteDocumentView];
    }
}

- (void)internal_initInfiniteDocumentView {
    CGRect visibleRect = CGRectZero;
    if ([self.dataSource respondsToSelector:@selector(contentOffsetWaterFlowView:)]) {
        visibleRect.origin = [self.dataSource contentOffsetWaterFlowView:self];
    }
    if ([self.dataSource respondsToSelector:@selector(boundsSizeWaterFlowView:)]) {
        visibleRect.size = [self.dataSource boundsSizeWaterFlowView:self];
    }
    
    NSUInteger cellsCount = self.cellFrames.count;
    for (int i = 0; i < cellsCount; i++) {
        // 对应的frame
        NSValue* value = [self.cellFrames objectForKey:@(i)];
        NSRect cellFrame = [value rectValue];
        // 如果该frame在屏幕显示范围内，加载cell
        XTWaterFlowViewCell *cell = self.displayingCells[@(i)];
        
        if ([self isInScreen:cellFrame inVisibleRect:visibleRect]) { // 在屏幕上
            if (cell == nil) {
                // 向代理索取一个cell
                cell = [self.dataSource waterFlowView:self cellAtIndex:i];
                
                [self addSubview:cell];
                
            }
            cell.index = i;
            cell.frame = cellFrame;
            self.displayingCells[@(i)] = cell;
            
        } else {// 不在屏幕上
            if (cell != nil) {
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                // 存进缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
}
-(void)resizeSubviewsWithOldSize:(NSSize)oldSize_in {
    [super resizeSubviewsWithOldSize:oldSize_in];
}

#pragma mark - ========================懒加载=======================
- (NSMutableDictionary *)cellFrames {
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableDictionary dictionary];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells {
    if (_displayingCells == nil) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells {
    if (_reusableCells == nil) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

#pragma mark - ========================Action=======================


#pragma mark - ========================public=======================

- (void)clearData{
    
    [self.reusableCells enumerateObjectsUsingBlock:^(NSView*  _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSView*  _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
        [self.cellFrames removeAllObjects];
        [self.displayingCells removeAllObjects];
        [self.reusableCells removeAllObjects];
    
}

- (void)reloadData {
 

    [self internal_initInfiniteDocumentView];
    
    // 1.计算每一个cell的尺寸位置
    // cell总数
    NSUInteger cellsCount = [self.dataSource numberOfCellsInWaterFlowView:self];
    // 瀑布流列数
    NSUInteger columnsCount = [self numberOfColumns];
    
    CGFloat marginTop = [self marginForType:XTWaterFlowViewMarginTypeTop];
    CGFloat marginBottom = [self marginForType:XTWaterFlowViewMarginTypeBottom];
    CGFloat marginLeft = [self marginForType:XTWaterFlowViewMarginTypeLeft];
    CGFloat marginRight = [self marginForType:XTWaterFlowViewMarginTypeRight];
    CGFloat marginRow = [self marginForType:XTWaterFlowViewMarginTypeRow];
    CGFloat marginColumn = [self marginForType:XTWaterFlowViewMarginTypeColumn];
    
    CGFloat cellW = (self.frame.size.width - marginLeft - marginRight - (columnsCount - 1) * marginColumn) / columnsCount;
    
    NSMutableArray* maxYOfColumns = [NSMutableArray arrayWithCapacity:columnsCount];
    for (int i = 0; i < columnsCount; i++) {
        maxYOfColumns[i] = @(0.0);
    }
    
    for (int i = 0; i < cellsCount; i++) {
        NSUInteger cellColumn = 0;
        NSUInteger maxYOfColumn = [maxYOfColumns[cellColumn] integerValue];

        // 找到当前最短的一列
        for (int j = 0; j < columnsCount; j++) {

            if ([maxYOfColumns[j] integerValue] < maxYOfColumn) {
                // 这个cell将会加在该列
                cellColumn = j;
                maxYOfColumn = [maxYOfColumns[j] integerValue];
            }
            
        }

        
        
        CGSize cell_size = [self sizeAtIndex:i];
        CGFloat cellH = cell_size.height / (cell_size.width/cellW);
        CGFloat cellX = marginLeft + cellColumn * (cellW + marginColumn);
        
        CGFloat cellY = 0;//self.frame.size.height
        
        if (maxYOfColumn == 0.0) { //第一行需要有间距
            cellY = marginTop;
        } else {
            cellY = maxYOfColumn + marginRow;
        }
        
        CGRect cellFrame = CGRectMake(cellX,cellY, cellW, cellH);
        NSLog(@"cell Frame %@   index:%d",NSStringFromRect(cellFrame),i);
        //        [self.cellFrames addObject:[NSValue valueWithRect:cellFrame]];
        [self.cellFrames setObject:[NSValue valueWithRect:cellFrame] forKey:@(i)];
        // 更新这一列的最大Y值
        maxYOfColumns[cellColumn] = [NSNumber numberWithFloat:CGRectGetMaxY(cellFrame)];
        if (isnan([maxYOfColumns[cellColumn] doubleValue])) {
            maxYOfColumns[cellColumn] = [NSNumber numberWithFloat:maxYOfColumn];
        }
    }
    
    // 设置contentSize
    CGFloat contentH = [maxYOfColumns[0] integerValue];
    
    if (isnan(contentH)) {
        contentH = 0;
    }
    
    // 找到当前最短的一列
    for (int i = 0; i < columnsCount; i++) {
        if ([maxYOfColumns[i] integerValue] > contentH) {
            contentH = [maxYOfColumns[i] integerValue];
        }
    }
    contentH += marginBottom;
    
    ///防止数据不够一屏的情况
    if ([self.dataSource respondsToSelector:@selector(boundsSizeWaterFlowView:)]) {
        NSSize size = [self.dataSource boundsSizeWaterFlowView:self];
        if ((size.height-40)>contentH) {
            contentH = size.height-40;
        }
    }
    
    NSRect frame = self.frame;
    frame.size.height = contentH;
    self.frame = frame;
    
    [self internal_initInfiniteDocumentView];
    
    NSObject *obj = (NSObject *)self.delegate;
    if ([obj respondsToSelector:@selector(waterFlowView:didHeight:)]) {
        [self.delegate waterFlowView:self didHeight:contentH];
    }
}

- (XTWaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    
    __block XTWaterFlowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(XTWaterFlowViewCell *cell, BOOL * stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell != nil) { // 如果缓存池中有
        // 从缓存池中移除
        [self.reusableCells removeObject:reusableCell];
    }
    
    return reusableCell;
}

-(BOOL)isFlipped{
    return YES;
}

#pragma mark - ========================private=======================
- (CGSize)sizeAtIndex:(NSUInteger)index {
    CGFloat cellH = XTWaterFlowViewDefaultCellH;
    CGSize size = CGSizeMake(cellH, cellH);
    NSObject *obj = (NSObject *)self.delegate;
    if ([obj respondsToSelector:@selector(waterFlowView:sizeAtIndex:)]) {
        size = [self.delegate waterFlowView:self sizeAtIndex:index];
    }
    
    return size;
}

- (CGFloat)numberOfColumns {
    CGFloat columsCount =  XTWaterFlowViewDefaultColumnsCount;
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterFlowView:)]) {
        columsCount = [self.dataSource numberOfColumnsInWaterFlowView:self];
    }
    return columsCount;
}

- (CGFloat)marginForType:(XTWaterFlowViewMarginType)type {
    CGFloat margin = XTWaterFlowViewDefaultMargin;
    NSObject *obj = (NSObject *)self.delegate;
    if ([obj respondsToSelector:@selector(waterFlowView:marginForType:)]) {
        margin = [self.delegate waterFlowView:self marginForType:type];
    }
    return margin;
}

/**
 *  判断给定frame是否在显示范围内
 *
 *  param frame
 *
 *  @return 给定frame是否在显示范围内
 */
- (BOOL)isInScreen:(CGRect)frame inVisibleRect:(CGRect)visibleRect {
    
    return ((self.bounds.size.height-CGRectGetMaxY(frame)+frame.size.height) > visibleRect.origin.y) && ((self.bounds.size.height-CGRectGetMidY(frame)-frame.size.height) < visibleRect.origin.y + visibleRect.size.height);
}

@end

