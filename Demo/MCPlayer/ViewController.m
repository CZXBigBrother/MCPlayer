//
//  ViewController.m
//  MCPlayer
//
//  Created by 陈正星 on 16/11/4.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import "ViewController.h"
#import "MCPlayer.h"
#import <Masonry.h>

@interface ViewController ()<MCPlayerDelagate>
@property(nonatomic, weak)MCPlayerView *myPlayerView;
@end

@implementation ViewController

-(void)dealloc {
    NSLog(@"%@",self.class);
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.myPlayerView MCPlayerPause];
    self.navigationController.navigationBarHidden = NO;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    MCPlayerModel * data = [[MCPlayerModel alloc]init];
    data.videoURL = @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4";
    data.title = @"电影一";
    MCPlayerView * playView = [[MCPlayerView alloc]init];
    self.myPlayerView = playView;
    [self.view addSubview:self.myPlayerView];
    self.myPlayerView.playModel = data;
    [self.myPlayerView MCPlayerPlay];
    self.myPlayerView.delegate = self;
    
    //如果直接用代码布局
//    mp.frame = CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 9.0/16.0 * [UIScreen mainScreen].bounds.size.width);
    //如果用masonry布局
    [self.myPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.right.equalTo(self.view);
        // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
        make.height.equalTo(self.myPlayerView.mas_width).multipliedBy(9.0f/16.0f).with.priority(750);
    }];
    //快速置顶显示
//    [MCPlayerView setupViewToTopLocation:self.view withPlayerView:self.myPlayerView];
}
- (void)mc_playerBackButtonOnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)delete:(id)sender {
    [self.myPlayerView MCPlayerReset];
}
- (IBAction)reset:(id)sender {
    MCPlayerModel * data = [[MCPlayerModel alloc]init];
    data.videoURL = @"http://baobab.wdjcdn.com/14571455324031.mp4";
    data.title = @"电影二";
    self.myPlayerView.playModel = data;
    [self.myPlayerView MCPlayerReset];

}



@end
