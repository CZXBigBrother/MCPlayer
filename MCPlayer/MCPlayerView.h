//
//  MCPlayerView.h
//  MCPlayer
//
//  Created by 陈正星 on 16/11/7.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MCPlayer.h"

@protocol MCPlayerDelagate <NSObject>

@optional
- (void)mc_playerBackButtonOnClick;

@end

@class MCPlayerModel;

@interface MCPlayerView : UIView

+ (instancetype)sharedPlayerView;
// 是否允许横屏播放
@property(nonatomic, assign) BOOL allowFullScreen;
@property(nonatomic, strong) MCPlayerModel  *playModel;
@property(nonatomic, weak)id<MCPlayerDelagate> delegate;
@property(nonatomic, strong)UITableViewCell *cell;

- (void)MCPlayerPlay;
- (void)MCPlayerPause;
- (void)MCPlayerReset;
+ (void)setupViewToTopLocation:(UIView *)selfView withPlayerView:(UIView *)targetView;

@end
