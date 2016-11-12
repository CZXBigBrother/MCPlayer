//
//  MCPlayerSliderView.m
//  MCPlayer
//
//  Created by 陈正星 on 16/11/4.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//


#import "MCPlayerSliderView.h"
#import "MCPlayer.h"
#import <Masonry.h>

@interface MCPlayerSliderView()

@property(nonatomic, weak)UIImageView *imgBackground;

@end

@implementation MCPlayerSliderView
#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}
#pragma mark - 创建控件
- (void)createView {
    UILabel * current = [[UILabel alloc]init];
    UILabel * total = [[UILabel alloc]init];
    UIButton * play = [[UIButton alloc]init];
    UIButton * full = [[UIButton alloc]init];
    UISlider * progress = [[UISlider alloc]init];
    UIProgressView * cache = [[UIProgressView alloc]init];
    UIImageView * background = [[UIImageView alloc]init];
    
    [self addSubview:background];
    [self addSubview:current];
    [self addSubview:total];
    [self addSubview:play];
    [self addSubview:full];
    [self addSubview:cache];
    [self addSubview:progress];
    
    self.lblCurrentTime = current;
    self.lblTotalTime = total;
    self.btnPlay = play;
    self.btnFull = full;
    self.sldProgress = progress;
    self.prgCache = cache;
    self.imgBackground = background;
    
    [self.btnPlay setImage:[UIImage imageNamed:@"mv_player_play"] forState:UIControlStateNormal];
    [self.btnPlay setImage:[UIImage imageNamed:@"mv_player_pause"] forState:UIControlStateSelected];
    [self.btnFull setImage:[UIImage imageNamed:@"mv_player_fullScreen_default"] forState:UIControlStateNormal];
    [self.btnFull setImage:[UIImage imageNamed:@"mv_player_fullScreen_selected"] forState:UIControlStateSelected];
    
    self.lblCurrentTime.text = @"00:00";
    self.lblCurrentTime.adjustsFontSizeToFitWidth = YES;
    self.lblCurrentTime.textAlignment = NSTextAlignmentRight;
    self.lblCurrentTime.textColor = [UIColor whiteColor];
    self.lblCurrentTime.font = [UIFont systemFontOfSize:13];
    
    self.lblTotalTime.text = @"00:00";
    self.lblTotalTime.adjustsFontSizeToFitWidth = YES;
    self.lblTotalTime.textAlignment = NSTextAlignmentLeft;
    self.lblTotalTime.textColor = [UIColor whiteColor];
    self.lblTotalTime.font = [UIFont systemFontOfSize:13];

    self.sldProgress.maximumValue = 1.0;
    self.sldProgress.minimumTrackTintColor = [UIColor whiteColor];
    self.sldProgress.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];;
    [self.sldProgress setThumbImage:[UIImage imageNamed:@"mv_player_slider"] forState:UIControlStateNormal];
    
    self.prgCache.progress = 0.0;
    self.prgCache.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.prgCache.trackTintColor = [UIColor clearColor];
    
    self.imgBackground.image = [UIImage imageNamed:@"mv_palyer_bottom_bg"];
    
    [self createViewMakeConstraints];
}

- (void)createViewMakeConstraints {
    
    WEAK_SELF;
    [self.imgBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.btnPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(MarginView);
        make.width.height.mas_equalTo(24);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    [self.btnFull mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.mas_right).offset(-MarginView);
        make.width.height.mas_equalTo(24);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    [self.lblCurrentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_top);
        make.left.equalTo(weakSelf.btnPlay.mas_right).offset(MarginView);
        make.height.equalTo(weakSelf.mas_height);
        make.width.mas_equalTo(40);
    }];
    [self.lblTotalTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_top);
        make.right.equalTo(weakSelf.btnFull.mas_left).offset(-MarginView);
        make.height.equalTo(weakSelf.mas_height);
        make.width.mas_equalTo(40);
    }];
    [self.sldProgress mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.mas_top);
        make.centerY.equalTo(weakSelf.btnPlay.mas_centerY).offset(-1);
        make.left.equalTo(weakSelf.lblCurrentTime.mas_right).offset(MarginView);
        make.right.equalTo(weakSelf.lblTotalTime.mas_left).offset(-MarginView);
        make.height.equalTo(weakSelf.mas_height);
    }];
    [self.prgCache mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnPlay.mas_centerY);
        make.left.equalTo(weakSelf.lblCurrentTime.mas_right).offset(MarginView);
        make.right.equalTo(weakSelf.lblTotalTime.mas_left).offset(-MarginView);
    }];

}



@end
