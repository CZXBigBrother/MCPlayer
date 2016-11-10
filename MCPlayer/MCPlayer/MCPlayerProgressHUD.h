//
//  MCPlayerProgressHUD.h
//  MCPlayer
//
//  Created by 陈正星 on 16/11/8.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPlayerProgressHUD : UIView

+ (instancetype)showType:(NSInteger)type currentProgress:(CGFloat)time totalProgress:(CGFloat)total toView:(UIView *)view;
- (void)showType:(NSInteger)type currentProgress:(CGFloat)time totalProgress:(CGFloat)total toView:(UIView *)view;

- (void)seekToTime:(CGFloat)time;

- (void)hideView;
- (void)startStatus;
- (void)stopStatus;
@end
