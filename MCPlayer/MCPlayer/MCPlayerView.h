//
//  MCPlayerView.h
//  MCPlayer
//
//  Created by 陈正星 on 16/11/7.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPlayerView : UIView
// 是否允许横屏播放
@property (nonatomic, assign) BOOL allowFullScreen;

- (void)start;
@end
