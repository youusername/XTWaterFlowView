//
//  XTWaterFlowViewCell.m
//  XTWaterFlowView
//
//  Created by zhangjing on 2018/11/21.
//  Copyright © 2018 214644496@qq.com. All rights reserved.
//

#import "XTWaterFlowViewCell.h"

#define WEAKSELF(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define STRONGSELF(o) autoreleasepool{} __strong typeof(o) o = o##Weak;


@interface XTWaterFlowViewCell()
@property (nonatomic,strong) NSImageView *imageView;
@end

@implementation XTWaterFlowViewCell
@synthesize identifier;

- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.layer = [[CALayer alloc] init];
        self.layer.contentsGravity = kCAGravityResizeAspectFill;
    }
    return self;
}

-(BOOL)isFlipped{
    return YES;
}

- (void)setImageName:(NSString *)imageName{
    if (imageName) {
        self.layer.contents = nil;
        [self setWantsLayer:YES];
        
        @WEAKSELF(self);
        @autoreleasepool{
            __block NSInteger b_index = self.index;
            if (b_index == selfWeak.index) {
                NSImage * image = [NSImage imageNamed:imageName];
                selfWeak.layer.contents = image;
                [selfWeak setWantsLayer:YES];
            }
        }
        _imageName = imageName;
    }
}


@end
