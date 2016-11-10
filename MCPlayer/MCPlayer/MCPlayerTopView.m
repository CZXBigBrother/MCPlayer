//
//  MCPlayerTopView.m
//  MCPlayer
//
//  Created by 陈正星 on 16/11/7.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import "MCPlayerTopView.h"
#import "MCPlayer.h"

@interface MCPlayerTopView()

@property(nonatomic, weak)UIImageView *imgBackground;

@end

@implementation MCPlayerTopView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}
#pragma mark - 创建控件
- (void)createView {
    UIButton * close = [[UIButton alloc]init];
    UILabel * title = [[UILabel alloc]init];
    UIImageView * background = [[UIImageView alloc]init];
    
    [self addSubview:background];
    [self addSubview:title];
    [self addSubview:close];
    
    self.btnClose = close;
    self.imgBackground = background;
    self.lblTitle = title;

    [self.btnClose setImage:[UIImage imageNamed:@"back_btn"] forState:UIControlStateNormal];
    self.imgBackground.image = [UIImage imageNamed:@"mv_palyer_topbar_bg"];
    
    self.lblTitle.text = @"我是一个标题";
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.font = [UIFont systemFontOfSize:15];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imgBackground.frame = self.bounds;
    
    self.btnClose.frame = (CGRect){{15 ,0},{24,24}};
    self.btnClose.center = CGPointMake(self.btnClose.center.x, HEIGHT_VIEW * 0.5);
    
    self.lblTitle.frame = (CGRect){CGPointZero,{150,HEIGHT_VIEW}};
    self.lblTitle.center = CGPointMake(WIDTH_VIEW * 0.5, HEIGHT_VIEW * 0.5);
    
}
@end
