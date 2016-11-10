//
//  MCPlayerProgressHUD.m
//  MCPlayer
//
//  Created by 陈正星 on 16/11/8.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import "MCPlayerProgressHUD.h"
#import <Masonry.h>
#import "MCPlayer.h"

@interface MCPlayerProgressHUD()

@property(nonatomic, weak)UIProgressView *myProgress;

@property(nonatomic, weak)UIActivityIndicatorView *myActiveIndView;

@property(nonatomic, weak)UILabel *lblTime;

@property(nonatomic, assign)NSInteger showType;

@property(nonatomic, weak)UIImageView *imgIcon;

@property(nonatomic, assign)CGFloat totalTime;

@property(nonatomic, assign)CGFloat initTime;

@end

@implementation MCPlayerProgressHUD
- (void)showType:(NSInteger)type currentProgress:(CGFloat)time totalProgress:(CGFloat)total toView:(UIView *)view {
    @WEAK_OBJ(view);
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewWeak);
        make.centerY.equalTo(viewWeak);
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(80);
    }];
    self.showType = type;
    self.initTime = time;
    self.totalTime = total;
}
+ (instancetype)showType:(NSInteger)type currentProgress:(CGFloat)time totalProgress:(CGFloat)total toView:(UIView *)view {
    MCPlayerProgressHUD * hud = [[MCPlayerProgressHUD alloc]init];
    [view addSubview:hud];
    @WEAK_OBJ(view);
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewWeak);
        make.centerY.equalTo(viewWeak);
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(80);
    }];
    hud.showType = type;
    hud.initTime = time;
    hud.totalTime = total;
    return hud;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}
- (UIActivityIndicatorView *)myActiveIndView {
    if (_myActiveIndView == nil) {
        UIActivityIndicatorView * active = [[UIActivityIndicatorView alloc]init];
        [self addSubview:active];
        _myActiveIndView = active;
        WEAK_SELF;
        [active mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf);
            make.centerY.equalTo(weakSelf);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);

        }];
    }
    return _myActiveIndView;
}

- (UIProgressView *)myProgress {
    if (_myProgress == nil) {
        UIProgressView * progress = [[UIProgressView alloc]init];
        [self addSubview:progress];
        _myProgress = progress;
        _myProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _myProgress.progress = 0.5;
        WEAK_SELF;
        [progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).mas_offset(15);
            make.right.equalTo(weakSelf).mas_offset(-15);
            make.bottom.equalTo(weakSelf).mas_offset(-15);
            make.height.mas_equalTo(2);
        }];
    }
    return _myProgress;
}
- (UILabel *)lblTime {
    if (_lblTime == nil) {
        UILabel * time = [[UILabel alloc]init];
        time.textAlignment = NSTextAlignmentCenter;
        time.text = @"00:00/00:00";
        [self addSubview:time];
        _lblTime = time;
        _lblTime.textColor = [UIColor whiteColor];
        WEAK_SELF;
        [time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf).offset(-15);
            make.left.equalTo(weakSelf).offset(15);
            make.bottom.equalTo(weakSelf.myProgress.mas_top).offset(-5);
            make.height.mas_equalTo(21);
        }];
    }
    return _lblTime;
}
- (UIImageView *)imgIcon {
    if (_imgIcon == nil) {
        UIImageView * icon = [[UIImageView alloc]init];
        [self addSubview:icon];
        _imgIcon = icon;
        WEAK_SELF;
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(32);
            make.centerX.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf.lblTime.mas_top).offset(-3);
        }];
    }
    return _imgIcon;
}

- (void)setShowType:(NSInteger)showType {
    _showType = showType;
    if (showType == 0) {
        self.backgroundColor = [UIColor clearColor];
    }else {
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 15;
    self.layer.masksToBounds = YES;
}

- (void)seekToTime:(CGFloat)time {
    NSInteger current = time * _totalTime;
    self.imgIcon.image = current >= _initTime ? [UIImage imageNamed:@"mv_fast_forward"] : [UIImage imageNamed:@"mv_fast_backward"];
    NSInteger proMin = (NSInteger)current/ 60;//当前分钟
    NSInteger proSec = (NSInteger)current % 60;//当前秒
    NSInteger durMin = (NSInteger)self.totalTime / 60;//总分钟
    NSInteger durSec = (NSInteger)self.totalTime % 60;//总秒
    self.lblTime.text = [NSString stringWithFormat:@"%02zd:%02zd/%02zd:%02zd",proMin,proSec,durMin,durSec];
    self.myProgress.progress = time;
}
- (void)startStatus {
    if (self.showType == 0) [self.myActiveIndView startAnimating];
}
- (void)stopStatus {
    if (self.showType == 0) [self.myActiveIndView stopAnimating];
}
- (void)hideView {
    [self removeFromSuperview];
}


@end
