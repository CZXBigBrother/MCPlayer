//
//  MCPlayerView.m
//  MCPlayer
//
//  Created by 陈正星 on 16/11/7.
//  Copyright © 2016年 MarcoChen. All rights reserved.
//
#import "MCPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

#define isAllowStartFunc if (self.isAllowStart == NO) {return;}
// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};
// 播放器的几种状态
typedef NS_ENUM(NSInteger, MCPlayerState) {
    MCPlayerStateFailed,     // 播放失败
    MCPlayerStateBuffering,  // 缓冲中
    MCPlayerStatePlaying,    // 播放中
    MCPlayerStateStopped,    // 停止播放
    MCPlayerStatePause       // 暂停播放
};

@interface MCPlayerView()<UIGestureRecognizerDelegate>
// 播放属性
@property(strong, nonatomic)AVPlayer *player;
// playerLayer
@property(strong, nonatomic)AVPlayerLayer *playerLayer;

@property(nonatomic, strong)UISlider               *volumeViewSlider;
@property(nonatomic, assign)BOOL                   isVolume;

@property(nonatomic, weak)MCPlayerSliderView *myPlayerSliderView;
@property(nonatomic, weak)MCPlayerTopView *myPlayerTopView;
@property(nonatomic, weak)MCPlayerProgressHUD *myPlayerHud;
@property(nonatomic, weak)MCPlayerProgressHUD *myActiveHud;

@property(nonatomic, copy)NSString *currentUrl;

/** 初始位置*/
@property(nonatomic, assign)CGRect initFrame;
/** 用来保存快进的总时长 */
@property(nonatomic, assign)CGFloat sumTime;
/** 定时器*/
@property(nonatomic, strong)NSTimer * myTimer;

@property(nonatomic, assign)BOOL isDrag;
@property(assign, nonatomic)BOOL isFullScreen;
@property(nonatomic, assign)BOOL isHiddenComponent;
@property(nonatomic, assign)BOOL isAllowStart;

@property(nonatomic, assign)PanDirection panDirection;

@property(nonatomic, assign)MCPlayerState myStatus;


@end

@implementation MCPlayerView
- (instancetype)init {
    if (self = [super init]) {
        [self createView];
        [self createParam];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesBegan");
//}
#pragma mark - 创建参数
- (void)createParam {
    self.allowFullScreen = YES;
    //屏幕方向发生变化通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    // 耳机插拔事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    [self addGestureRecognizer:pan];
    
    [self configureVolume];

}
- (void)addObserver {
    // 监听播放器播放状态属性
    [self.player.currentItem addObserver:self
                              forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"loadedTimeRanges"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"playbackBufferEmpty"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"playbackLikelyToKeepUp"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
}
- (void)addTimer
{
    if(self.myTimer) return;
    self.myTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}
-(void)stopTimer
{
    [self.myTimer invalidate];
    self.myTimer=nil;
}
- (void)createView {
    MCPlayerSliderView * playerSliderView = [[MCPlayerSliderView alloc]init];
    MCPlayerTopView * playerTopView = [[MCPlayerTopView alloc]init];
    
    [self addSubview:playerSliderView];
    [self addSubview:playerTopView];
    
    self.myPlayerSliderView = playerSliderView;
    self.myPlayerTopView = playerTopView;
    
    [self.myPlayerSliderView.sldProgress addTarget:self action:@selector(moveSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [self.myPlayerSliderView.sldProgress addTarget:self action:@selector(startSliderProgress:) forControlEvents:UIControlEventTouchDown];
    [self.myPlayerSliderView.sldProgress addTarget:self action:@selector(stopSliderProgress:) forControlEvents:UIControlEventTouchUpInside];
    [self.myPlayerSliderView.sldProgress addTarget:self action:@selector(stopSliderProgress:) forControlEvents:UIControlEventTouchCancel];
    [self.myPlayerSliderView.sldProgress addTarget:self action:@selector(stopSliderProgress:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.myPlayerSliderView.btnPlay addTarget:self action:@selector(MCPlayerPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.myPlayerSliderView.btnFull addTarget:self action:@selector(MCPlayerScreenFull) forControlEvents:UIControlEventTouchUpInside];

    [self.myPlayerTopView.btnClose addTarget:self action:@selector(MCPlayerClose) forControlEvents:UIControlEventTouchUpInside];
    
    WEAK_SELF;
    [playerSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
        make.height.mas_equalTo(44);
    }];
    [playerTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf);
        make.height.mas_equalTo(44);
    }];
}
- (CGFloat)getTotolTime {
    return CMTimeGetSeconds(self.player.currentItem.duration) >= 0 ? CMTimeGetSeconds(self.player.currentItem.duration): 0;
}

- (CGFloat)getCurrentTime {
    return CMTimeGetSeconds(self.player.currentItem.currentTime) >= 0 ? CMTimeGetSeconds(self.player.currentItem.currentTime) : 0;
}

- (NSTimeInterval)availableDuration {
    
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//  获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;//  计算缓冲总进度
    return result;
}
- (MCPlayerProgressHUD *)myPlayerHud {
    if (_myPlayerHud == nil) {
        MCPlayerProgressHUD * hud = [MCPlayerProgressHUD showType:1 currentProgress:[self getCurrentTime] totalProgress:[self getTotolTime] toView:self];
        _myPlayerHud = hud;
    }
    return _myPlayerHud;
}
- (MCPlayerProgressHUD *)myActiveHud {
    if (_myActiveHud == nil) {
        MCPlayerProgressHUD * hud = [MCPlayerProgressHUD showType:0 currentProgress:[self getCurrentTime] totalProgress:[self getTotolTime] toView:self];
        _myActiveHud = hud;
    }
    return _myActiveHud;
}
#pragma mark - 刷新
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.initFrame.size.width < 1) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect converRect = [self convertRect:self.frame toView:window];
        self.frame = converRect;
        self.initFrame = self.frame;
    }
    if (self.isFullScreen) {
        self.playerLayer.frame = (CGRect){CGPointZero,[UIScreen mainScreen].bounds.size};
    }else {
        self.playerLayer.frame = self.bounds;
    }

}
- (void)updateTime {
    NSInteger proMin = (NSInteger)[self getTotolTime] / 60;//当前分钟
    NSInteger proSec = (NSInteger)[self getTotolTime] % 60;//当前秒
    NSInteger durMin = (NSInteger)[self getCurrentTime] / 60;//总分钟
    NSInteger durSec = ((NSInteger)[self getCurrentTime]) % 60;//总秒
    self.myPlayerSliderView.lblCurrentTime.text = [NSString stringWithFormat:@"%02zd:%02zd",durMin,durSec];
    self.myPlayerSliderView.lblTotalTime.text = [NSString stringWithFormat:@"%02zd:%02zd",proMin,proSec];
    
    CGFloat progress = [self availableDuration] / [self getTotolTime];
    self.myPlayerSliderView.prgCache.progress = isnan(progress) ? 0 : progress;
    if(self.isDrag == NO) self.myPlayerSliderView.sldProgress.value = [self getCurrentTime] / [self getTotolTime];
}
#pragma mark 强制转屏相关
// 强制转换屏幕方向
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    // 是否允许全屏
    if (self.allowFullScreen == NO && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        return;
    }
    
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - 操作
- (void)start {
    if (self.player == nil) {
        AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://baobab.wdjcdn.com/1456117847747a_x264.mp4"]];
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//        [self.layer insertSublayer:self.playerLayer atIndex:0];
        [self.layer insertSublayer:self.playerLayer below:self.myPlayerSliderView.layer];
        [self.layer insertSublayer:self.myPlayerTopView.layer below:self.myPlayerSliderView.layer];
    }
    self.myPlayerSliderView.btnPlay.selected = YES;
    [self.player play];
    [self addTimer];
    [self addObserver];
    [self.myActiveHud stopStatus];
}
- (void)pause {
    [self.player pause];
    self.myPlayerSliderView.btnPlay.selected = NO;
}
- (void)clear {
    [self.player pause];
    self.player = nil;
    [self.playerLayer removeFromSuperlayer];
    [self stopTimer];
}
- (void)startSliderProgress:(UISlider *)sender {
    [self moveChangeProgress:sender.value];
}
- (void)moveSliderProgress:(UISlider *)sender {
    [self moveChangeProgress:sender.value];
}
- (void)stopSliderProgress:(UISlider *)sender {
    [self stopChangeProgress:sender.value];
}
/*
 *  拖动事件
 */
- (void)moveChangeProgress:(CGFloat)value {
    isAllowStartFunc
    self.isDrag = YES;
    [self.myPlayerHud seekToTime:value];
}
- (void)stopChangeProgress:(CGFloat)value {
    isAllowStartFunc
    WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.isDrag = NO;
    });
    [self.myPlayerHud removeFromSuperview];
    [self MCPlayerSeekToTime:value];
}
/*
 *  单击事件
 */
- (void)singleTapAction:(UITapGestureRecognizer *)gesture
{
    [self MCPlayerHidden];
}
/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    isAllowStartFunc
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                self.panDirection = PanDirectionHorizontalMoved;
                self.isDrag = YES;
//                [self.myPlayerHud seekToTime:sender.value];
                // 给sumTime初值
                CMTime time       = self.player.currentTime;
                self.sumTime      = time.value/time.timescale;
                NSLog(@"sumTime == %lf",self.sumTime);
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    self.isDrag = YES;
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    NSLog(@"sumTime == %lf",self.sumTime);

                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
//                    self.isPauseByUser = NO;
//                    [self seekToTime:self.sumTime completionHandler:nil];
                    // 把sumTime滞空，不然会越加越多
                    NSLog(@"sumTime == %lf",self.sumTime);
                    CGFloat pro = self.sumTime/[self getTotolTime];
                    [self stopChangeProgress:pro];
                    self.myPlayerSliderView.sldProgress.value = pro;
                    self.sumTime = 0;
                    
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark 外部操作
- (void)MCPlayerPlay {
    self.myPlayerSliderView.btnPlay.selected =  !self.myPlayerSliderView.btnPlay.selected;
    self.myPlayerSliderView.btnPlay.selected == YES ? [self start] : [self pause];
}
- (void)MCPlayerPause {
    [self pause];
}
- (void)MCPlayerStop {
    
}
- (void)MCPlayerScreenFull {
    if (self.isFullScreen) {
        self.myPlayerSliderView.btnFull.selected = NO;
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
    else if (self.allowFullScreen){
        self.myPlayerSliderView.btnFull.selected = YES;
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}
- (void)MCPlayerSeekToTime:(CGFloat)value {
    CMTime dragedCMTime = CMTimeMake(value * [self getTotolTime], 1);
    __weak typeof(self) weakSelf = self;
    [weakSelf.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        [weakSelf.player play];
        weakSelf.myPlayerSliderView.btnPlay.selected = YES;
    }];
}
- (void)MCPlayerClose {
    if (self.isFullScreen) {
        [self MCPlayerScreenFull];
    }else {
        NSLog(@"做些奇奇怪怪的事情");
    }
}
- (void)MCPlayerHidden {
    self.isHiddenComponent = !self.isHiddenComponent;
    [UIView animateWithDuration:0.5 animations:^{
        self.myPlayerSliderView.alpha = self.isHiddenComponent ? 0.0 : 1.0;
        self.myPlayerTopView.alpha = self.isHiddenComponent ? 0.0 : 1.0;
    }completion:^(BOOL finished) {
        
    }];

}
#pragma mark - 通知
// 监听设备旋转方向
- (void)deviceOrientationDidChangeNotification {
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationPortrait:
            {
                // 切换到小屏(默认16：9的宽高比)
                self.isFullScreen = NO;
                if (self.initFrame.size.width > 1) {
                    self.frame = self.initFrame;
                }
//                self.myPlayerTopView.hidden = YES;
            }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            {
                //不允许横屏
                if (!self.allowFullScreen) return;
                self.isFullScreen = YES;
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                self.frame = window.frame;
//                self.myPlayerTopView.hidden = NO;
            }
            break;
        default:
            break;
    }

}
//耳机链接
- (void)audioSessionRouteChanged:(NSNotification *)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
//            [self play];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}
#pragma mark -   --kvo && observer

// 播放对象的相关状态变化通知
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"rate"]) {
        NSLog(@"------播放状态变化了ratechange----->:%@",change);
        NSString *value = [NSString stringWithFormat:@"%@",change[NSKeyValueChangeNewKey]];
        
        //在已经获取到视频信息后才允许刷新加载状态
//        if (self.currentPlayTime < self.totalTime - 1 && self.totalTime > 0) {
//            [self showActivity:value.integerValue == 0?YES:NO];
//        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //缓冲到的最大的时间点
        NSTimeInterval timeInterval = [self availableDuration];
        
//        NSLog(@"---------01010110-------:\ncurrentTime:%lf\ncurrentMaxTime:%f\n%@",[self getCurrentTime],timeInterval,change);
        if ([self getCurrentTime] < (timeInterval - 2)) {
            // 非暂停状态继续播放
//            if (!self.startBtn.selected) {
//                [self mmPlayerPlay];
//            }
            [self.myActiveHud hideView];
        }else {
            [self.myActiveHud startStatus];
        }
//        [self.cacheProgressView setProgress:timeInterval/self.totalTime animated:NO];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
//        NSLog(@"---------02020220-------:%@",change);
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
//        NSLog(@"--------030303130--------:%@",change);
//        [self.myActiveHud startStatus];
        
    } else if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"---------040401440-------:%@",change);
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusUnknown:
                NSLog(@"AVPlayerStatusUnknown");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"AVPlayerStatusReadyToPlay");
                self.isAllowStart = YES;
                [self.myActiveHud hideView];
                if (self.myPlayerSliderView.btnPlay.selected == YES) {
                    [self start];
                }
//                [self showActivity:NO];
                break;
            case AVPlayerStatusFailed:
                NSLog(@"AVPlayerStatusFailed:%@",[self.player.currentItem error]);
                break;
        }
    }
    
}

/**
 *  获取系统音量
 */
- (void)configureVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
//    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
//            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
    // 监听耳机插入和拔掉通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}
/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value
{
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value
{
//    NSLog(@"horizontalMoved %lf",value);
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime           = self.player.currentItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) { return; }
    [self moveChangeProgress:self.sumTime / totalMovieDuration];
    self.myPlayerSliderView.sldProgress.value = self.sumTime/[self getTotolTime];
}
@end
