//
//  MCPlayer.h
//  MCPlayer
//
//  Created by 陈正星 on 16/11/7.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

// 屏幕的宽
#define ScreenWidth   [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define ScreenHeight  [[UIScreen mainScreen] bounds].size.height
// 颜色值RGB
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define HEIGHT_VIEW   (self.frame.size.height)
#define WIDTH_VIEW    (self.frame.size.width)
#define MarginView    (5)

#define MCPlayerSrcName(file) [@"MCPlayer.bundle" stringByAppendingPathComponent:file]
#define MCPlayerImage(file)   [UIImage imageNamed:MCPlayerSrcName(file)]

#define WEAK_SELF __weak typeof(self) weakSelf = self
#define WEAK_OBJ(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

#import "MCPlayerView.h"
#import "MCPlayerProgressHUD.h"
#import "MCPlayerSliderView.h"
#import "MCPlayerTopView.h"
