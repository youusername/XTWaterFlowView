//
//  ViewController.m
//  XTWaterFlowView
//
//  Created by zhangjing on 2018/11/21.
//  Copyright © 2018 214644496@qq.com. All rights reserved.
//

#import "ViewController.h"
#import "XTWaterFlowView.h"

@interface ContentModel : NSObject
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,strong) NSString * imageName;
@end
@implementation ContentModel
- (CGFloat)width{
    if (_width == 0) {
        @autoreleasepool {
            NSImage * image = [NSImage imageNamed:self.imageName];
            _width = image.size.width;
            _height = image.size.height;
            image = nil;
        }
    }
    return _width;
}
- (CGFloat)height{
    if (_height == 0) {
        @autoreleasepool {
            NSImage * image = [NSImage imageNamed:self.imageName];
            _width = image.size.width;
            _height = image.size.height;
            image = nil;
        }
    }
    return _height;
}
@end

@interface ViewController ()<XTWaterFlowViewDataSource,XTWaterFlowViewDelegate>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray *itemArray;
@property (nonatomic,strong) XTWaterFlowView *waterFlowView;
//@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,strong) NSDictionary *param;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.itemArray = [NSMutableArray array];
    for (int i = 0; i<26; i++) {
        ContentModel * model = [ContentModel new];
        model.imageName = [NSString stringWithFormat:@"s%d.jpg",i];
        [self.itemArray addObject:model];
        
        ContentModel * model2 = [ContentModel new];
        model2.imageName = [NSString stringWithFormat:@"f%d.jpg",i];
        [self.itemArray addObject:model2];
    }
    
    [self loadWaterFlowView];
    
    [self addObserveNotification];

    
    
}
- (void)addObserveNotification{
    
    [self.scrollView setDrawsBackground:NO];
    NSView *contentView = [self.scrollView contentView];
    [contentView setPostsBoundsChangedNotifications:YES];
    
    //    加载下一页功能
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundDidChange:) name:NSViewBoundsDidChangeNotification object:contentView];

    
}



- (void)loadAPIData:(NSArray*)array{
//    NSInteger curPointY = self.waterFlowView.frame.size.height;
    //        NSLog(@"curPointY__%ld   frame__%@",curPointY,NSStringFromRect(self.waterFlowView.frame));

    self.itemArray = [NSMutableArray arrayWithArray:array];

    [self.waterFlowView reloadData];
    
//    if (self.page == 1) {
        NSPoint pt = NSMakePoint(0.0, [[self.scrollView documentView] bounds].size.height);
        [self.scrollView.documentView scrollPoint:pt];
//    }else{
//        NSPoint pt = NSMakePoint(0.0, self.waterFlowView.frame.size.height - curPointY);
//        [self.scrollView.documentView scrollPoint:pt];
//    }
}

- (void)loadWaterFlowView{
    
    self.waterFlowView = [[XTWaterFlowView alloc] initWithFrame:NSMakeRect(0, 0, 500, 1600)];
    //    self.waterFlowView.boundsSize = self.scrollView.bounds.size;
    self.waterFlowView.dataSource = self;
    self.waterFlowView.delegate = self;
    
    [self.waterFlowView reloadData];
    
    
    NSView*view = [self.scrollView documentView];
    [view addSubview:self.waterFlowView];

}

- (void)boundDidChange:(NSNotification *)notification {

//    NSClipView *changedContentView = (NSClipView*)[notification object];


//    if (changedContentView.visibleRect.origin.y < 100 && !self.isLoading && self.page < 10 && self.itemArray.count > 0) {
//        NSLog(@"%@    %@",NSStringFromRect(changedContentView.visibleRect),NSStringFromRect(changedContentView.documentVisibleRect));
//
//
//        self.page += 1;
//        [self reloadContentData];
//    }

    [self.waterFlowView reloadData];
}
- (void)viewWillLayout{
    [super viewWillLayout];
    
    self.waterFlowView.frame = self.view.bounds;
    //    self.waterFlowView.boundsSize = self.view.frame.size;
    ///这里刷新是因为有可能会改变窗口大小
    [self.waterFlowView reloadData];
    
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - =======================XTWaterFlowView数据源=======================
- (NSPoint)contentOffsetWaterFlowView:(XTWaterFlowView *)waterFlowView{
    return self.scrollView.documentVisibleRect.origin;
}
- (NSSize)boundsSizeWaterFlowView:(XTWaterFlowView *)waterFlowView{
    return self.view.frame.size;
}
- (NSUInteger)numberOfCellsInWaterFlowView:(XTWaterFlowView *)waterFlowView {
    return self.itemArray.count;
}

- (NSUInteger)numberOfColumnsInWaterFlowView:(XTWaterFlowView *)waterFlowView {
    return 3;
}

- (XTWaterFlowViewCell *)waterFlowView:(XTWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index {
    XTWaterFlowViewCell *cell = [waterFlowView dequeueReusableCellWithIdentifier:@"reuseID"];
    
    ContentModel *model = self.itemArray[index];
    
    if (cell == nil) {
        cell = [[XTWaterFlowViewCell alloc] init];
        cell.identifier = @"reuseID";

    }
    cell.index = index;
    cell.imageName = model.imageName;

    
    return cell;
}

#pragma mark - =======================XTWaterFlowView代理=======================
- (CGSize)waterFlowView:(XTWaterFlowView *)waterFlowView sizeAtIndex:(NSUInteger)index {
    ContentModel * model = self.itemArray[index];
    
    return CGSizeMake(model.width, model.height);
    
}

- (CGFloat)waterFlowView:(XTWaterFlowView *)waterFlowView marginForType:(XTWaterFlowViewMarginType)type {
    switch (type) {
        case XTWaterFlowViewMarginTypeTop:
            return 10;
            break;
        case XTWaterFlowViewMarginTypeBottom:
            return 20;
            break;
        case XTWaterFlowViewMarginTypeLeft:
            return 10;
            break;
        case XTWaterFlowViewMarginTypeRight:
            return 20;
            break;
        default:
            return 10;
            break;
    }
}
- (void)waterFlowView:(XTWaterFlowView *)waterFlowView didHeight:(CGFloat)height{
    NSRect rect = self.scrollView.documentView.frame;
    rect.size.height = height;
    rect.origin.y   = 0;
    self.scrollView.documentView.frame = rect;
}

#pragma mark - =======================Other=======================
- (void)waterFlowView:(XTWaterFlowView *)waterFlowView didSelectCellAtIndex:(NSUInteger)index {
    
    NSLog(@"didSelectCellAtIndex %ld",index);
}

@end
