//
//  MCPlayerModel.h
//  MCPlayer
//
//  Created by 陈正星 on 16/11/11.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MCPlayerModel : NSObject
@property (nonatomic, copy  ) NSString     *title;
@property (nonatomic, copy  ) NSString     *videoURL;
@property (nonatomic, strong) UIImage      *placeholderImage;
@property (nonatomic, assign) NSInteger    seekTime;

@end
