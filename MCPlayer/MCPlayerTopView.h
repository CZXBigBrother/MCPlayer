//
//  MCPlayerTopView.h
//  MCPlayer
//
//  Created by 陈正星 on 16/11/7.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCPlayerModel;
@interface MCPlayerTopView : UIView

@property(nonatomic, weak)UIButton *btnClose;
@property(nonatomic, weak)UILabel *lblTitle;

- (void)setData:(MCPlayerModel *)data;

@end
