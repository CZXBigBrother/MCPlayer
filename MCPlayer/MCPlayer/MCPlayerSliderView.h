//
//  MCPlayerSliderView.h
//  MCPlayer
//
//  Created by 陈正星 on 16/11/4.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCPlayerSliderViewDelegate <NSObject>

@end

@interface MCPlayerSliderView : UIView

@property(nonatomic, weak)UILabel *lblCurrentTime;
@property(nonatomic, weak)UILabel *lblTotalTime;
@property(nonatomic, weak)UIButton *btnPlay;
@property(nonatomic, weak)UIButton *btnFull;
@property(nonatomic, weak)UISlider *sldProgress;
@property(nonatomic, weak)UIProgressView *prgCache;

@end
