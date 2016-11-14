//
//  MCPlayerTopView.m
//  MCPlayer
//
//  Created by 陈正星 on 16/11/7.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import "MCPlayerTopView.h"
#import "MCPlayer.h"
#import <Masonry.h>

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
    
    [self createViewMakeConstraints];
}

- (void)createViewMakeConstraints {
    WEAK_SELF;
    [self.imgBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(MarginView);
        make.width.height.mas_equalTo(24);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    [self.lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.height.equalTo(weakSelf.mas_height);
        make.center.equalTo(weakSelf);
    }];
}
- (void)setData:(MCPlayerModel *)data {
    self.lblTitle.text = data.title;
}

@end
