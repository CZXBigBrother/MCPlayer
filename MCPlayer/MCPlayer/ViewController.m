//
//  ViewController.m
//  MCPlayer
//
//  Created by 陈正星 on 16/11/4.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//

#import "ViewController.h"
#import "MCPlayerSliderView.h"
#import "MCPlayerView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    MCPlayerSliderView * mc = [[MCPlayerSliderView alloc]init];
//    mc.frame = CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, 44);
//    [self.view addSubview:mc];
    
    MCPlayerView * mp = [[MCPlayerView alloc]init];
    mp.frame = CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 9.0/16.0 * [UIScreen mainScreen].bounds.size.width);
    [self.view addSubview:mp];
    [mp start];
//    mp.backgroundColor = [UIColor blueColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
