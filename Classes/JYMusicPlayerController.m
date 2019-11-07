//
//  JYMusicPlayerViewController.m
//  MusicPlayer
//
//  Created by miao yu on 2019/10/25.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "JYMusicPlayerController.h"
#import "JYMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface JYMusicPlayerController ()

@property (nonatomic, strong) JYMusicPlayer *musicPlayer;

// 更新进度条的timer, 不是当前界面时不更新进度
@property (nonatomic, strong) NSTimer *timer;

// 是否正在拖动进度条
@property (nonatomic, assign) BOOL draggingSlider;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation JYMusicPlayerController

#pragma mark - init

+ (instancetype)sharedPlayerController {
    static JYMusicPlayerController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JYMusicPlayerController alloc] initWithNibName:nil bundle:nil];
    });
    return _controller;
}

- (void)setAudioSession {
    // 设置后台播放功能，并调用 setActive 将会话激活才能起作用
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback error:nil]) {
        NSLog(@"SetCategory error: %@",[error localizedDescription]);
    }
    if (![session setActive:YES error:nil]) {
        NSLog(@"SetActive error:%@",[error localizedDescription]);
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    [self setAudioSession];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray<NSString *> *songs = @[@"王菲-平凡最浪漫.mp3",
                                   @"容易受伤的女人.mp3",
                                   @"Groove Coverage - God Is A Girl.mp3"];
    
    self.musicPlayer = [[JYMusicPlayer alloc] init];
    [self.musicPlayer addSongs:songs];
    [self.musicPlayer play];
    
    [self createTimer];
    
    [self addObserver];
    
    // 接收音频控制事件(耳机操作)
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
}

- (void)dealloc {
    // 停止接收音频控制事件
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [self removeObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
}

#pragma mark - Observer

- (void)addObserver {
    [self addObserver:self forKeyPath:@"self.musicPlayer.isPlaying" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    // 监视拔出耳机后暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)removeObserver {
    [self removeObserver:self forKeyPath:@"self.musicPlayer.isPlaying" context:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if (object == self && [keyPath isEqualToString:@"self.musicPlayer.isPlaying"]) {
        BOOL isPlaying = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *imageName = isPlaying ? @"btn_pause" : @"btn_play";
            UIImage *image = [UIImage imageNamed:imageName];
            [self.playButton setImage:image forState:UIControlStateNormal];
        });
    }
}

#pragma mark - RouteObserver

// 耳机拨出来的通知处理
- (void)routeChange:(NSNotification*)notice {
    
    NSDictionary *dict = notice.userInfo;
    NSUInteger changeReason = [dict[AVAudioSessionRouteChangeReasonKey] integerValue];
    
    // 等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription = dict[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            [self.musicPlayer pause];
        }
    }
}

#pragma mark - Timer

- (void)createTimer {
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)startTimer {
    if (!self.timer.isValid) {
        [self.timer fire];
    }
}

- (void)stopTimer {
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
}

- (void)timerFire:(id)sender {
    if (_draggingSlider || !self.musicPlayer.audioPlayer.isPlaying) {
        return;
    }
    
    NSTimeInterval currentTime = self.musicPlayer.audioPlayer.currentTime;
    NSTimeInterval duration = self.musicPlayer.audioPlayer.duration;
    
    self.slider.maximumValue = duration;
    //self.slider.value = currentTime;
    [self.slider setValue:currentTime animated:YES];
    
    //NSLog(@"progress: %f/%f", currentTime, duration);
}

#pragma mark - RemoteControl Events

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //快退开始【操作：按耳机线控中间按钮三下不要松开】 UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
    //快退停止【操作：按耳机线控中间按钮三下到了快退的位置松开】 UIEventSubtypeRemoteControlEndSeekingBackward = 107,
    //快进开始【操作：按耳机线控中间按钮两下不要松开】 UIEventSubtypeRemoteControlBeginSeekingForward = 108,
    //快进停止【操作：按耳机线控中间按钮两下到了快进的位置松开】 UIEventSubtypeRemoteControlEndSeekingForward = 109,
    
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay: //播放事件【操作：停止状态下，按耳机线控中间按钮一下】
            case UIEventSubtypeRemoteControlPause: //暂停事件
            case UIEventSubtypeRemoteControlTogglePlayPause://播放或暂停切换【操作：播放或暂停状态下，按耳机线控中间按钮一下】
                [self.musicPlayer changePlayStatus];
                break;
            case UIEventSubtypeRemoteControlStop://停止事件
                [self.musicPlayer pause];
                break;
            case UIEventSubtypeMotionShake: //摇晃事件（从iOS3.0开始支持此事件）
            case UIEventSubtypeRemoteControlNextTrack: //下一曲【操作：按耳机线控中间按钮两下】
                [self.musicPlayer playNextSong];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack: //上一曲【操作：按耳机线控中间按钮三下】
                [self.musicPlayer playPrevSong];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Button Actions

- (IBAction)prevButtonClicked:(id)sender {
    [self.musicPlayer playPrevSong];
}

- (IBAction)nextButtonClicked:(id)sender {
    [self.musicPlayer playNextSong];
}

- (IBAction)playButtonClicked:(id)sender {
    [self.musicPlayer changePlayStatus];
}

- (IBAction)sliderTouchDown:(id)sender {
    _draggingSlider = YES;
    [self.musicPlayer pause];
}

- (IBAction)sliderTouchUp:(id)sender {
    _draggingSlider = NO;
    NSTimeInterval time = _slider.value;
    [self.musicPlayer playAtPosition:time];
}

- (IBAction)sliderValueChanged:(id)sender {
    if (!_draggingSlider)
        return;
    
    // 更新_currentTimeLabel
//    int position = _timeSlider.value;

}

@end
