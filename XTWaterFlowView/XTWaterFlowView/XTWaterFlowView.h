//
//  XTWaterFlowView.h
//  XTWaterFlowView
//
//  Created by zhangjing on 2018/11/21.
//  Copyright © 2018 214644496@qq.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XTWaterFlowViewCell.h"

#pragma mark - ========================枚举定义========================
typedef enum {
    XTWaterFlowViewMarginTypeTop,
    XTWaterFlowViewMarginTypeBottom,
    XTWaterFlowViewMarginTypeLeft,
    XTWaterFlowViewMarginTypeRight,
    // 列间距
    XTWaterFlowViewMarginTypeColumn,
    // 上下相邻cell间距
    XTWaterFlowViewMarginTypeRow
} XTWaterFlowViewMarginType;

#pragma mark - ========================数据源代理定义========================
@class XTWaterFlowView;
@protocol XTWaterFlowViewDataSource <NSObject>

@required
/**
 *  一共多少cell
 *
 *  @param waterFlowView XTWaterFlowView对象
 *
 *  @return cell总个数，NSUInteger保证正数
 */
- (NSUInteger)numberOfCellsInWaterFlowView:(XTWaterFlowView *)waterFlowView;
/**
 *  返回对应索引的cell
 *
 *  @param waterFlowView XTWaterFlowView对象
 *  @param index         索引
 *
 *  @return 对应索引的cell
 */
- (XTWaterFlowViewCell *)waterFlowView:(XTWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index;

/**
 回返当前滚动的位置
 
 @param waterFlowView XTWaterFlowView对象
 @return 位置point
 */
- (NSPoint)contentOffsetWaterFlowView:(XTWaterFlowView *)waterFlowView;

/**
 返回瀑布流区域大小
 
 @param waterFlowView XTWaterFlowView对象
 @return 区域大小
 */
- (NSSize)boundsSizeWaterFlowView:(XTWaterFlowView *)waterFlowView;
@optional
/**
 *  一共多少列，如果数据源没有设置，默认为2列
 *
 *  @param waterFlowView XTWaterFlowView对象
 *
 *  @return 瀑布流列数
 */
- (NSUInteger)numberOfColumnsInWaterFlowView:(XTWaterFlowView *)waterFlowView;

@end

#pragma mark - ========================代理定义=======================
@protocol XTWaterFlowViewDelegate

@optional
/**
 *  返回对应索引的cell的高度
 *
 *  @param waterFlowView XTWaterFlowView对象
 *  @param index         索引
 *
 *  @return 对应索引的cell的高度
 */
- (CGSize)waterFlowView:(XTWaterFlowView *)waterFlowView sizeAtIndex:(NSUInteger)index;
/**
 *  点击cell回调
 *
 *  @param waterFlowView XTWaterFlowView对象
 *  @param index         索引
 */
- (void)waterFlowView:(XTWaterFlowView *)waterFlowView didSelectCellAtIndex:(NSUInteger)index;
/**
 *  返回对应间距类型的间距
 *
 *  @param waterFlowView XTWaterFlowView对象
 *  @param type          间距类型
 *
 *  @return 对应间距类型的间距
 */
- (CGFloat)waterFlowView:(XTWaterFlowView *)waterFlowView marginForType:(XTWaterFlowViewMarginType)type;



- (void)waterFlowView:(XTWaterFlowView *)waterFlowView didHeight:(CGFloat)height;

@end


#pragma mark - ========================类定义=======================
@interface XTWaterFlowView : NSView

/**
 *   代理对象
 */
@property (nonatomic, weak) id<XTWaterFlowViewDelegate> delegate;
/**
 *  数据源对象
 */
@property (nonatomic, weak) id<XTWaterFlowViewDataSource> dataSource;
//@property (nonatomic, assign) NSSize boundsSize;
/**
 *  刷新数据
 *  调用该方法会重新向数据源和代理发送请求。获取数据
 */
- (void)reloadData;


/**
 清空当前所以数据和缓存Cell
 */
- (void)clearData;


/**
 *  根据ID查找可循环利用的cell
 *
 *  @return 可循环利用的cell
 */
- (XTWaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)internal_initInfiniteDocumentView;
@end

