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

/**
 *  生成单例,比如在tableview上使用的时候要保障内存的使用,平时的界面无所谓
 */
+ (instancetype)sharedPlayerView;
/**
 *  参数模型
 */
@property(nonatomic, strong) MCPlayerModel  *playModel;
@property(nonatomic, weak)id<MCPlayerDelagate> delegate;
/**
 *  是否允许横屏播放
 */
@property(nonatomic, assign) BOOL allowFullScreen;
/**
 *  在tableview上使用的时候需要传入承载播放器的cell
 */
@property(nonatomic, strong)UITableViewCell *cell;
/**
 *  播放
 */
- (void)MCPlayerPlay;
/**
 *  暂停
 */
- (void)MCPlayerPause;
/**
 *  重置
 */
- (void)MCPlayerReset;
+ (void)setupViewToTopLocation:(UIView *)selfView withPlayerView:(UIView *)targetView;

@end
