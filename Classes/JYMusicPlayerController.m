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
        _controller = [[self alloc] init];
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

- (instancetype)init {
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
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
    
    NSLog(@"progress: %f/%f", currentTime, duration);
}

#pragma mark - Button Actions

- (IBAction)prevButtonClicked:(id)sender {
    [self.musicPlayer playPrevSong];
}

- (IBAction)nextButtonClicked:(id)sender {
    [self.musicPlayer playNextSong];
}

- (IBAction)playButtonClicked:(id)sender {
    NSString *title = self.musicPlayer.audioPlayer.isPlaying ? @"播放" : @"暂停";
    [_playButton setTitle:title forState:UIControlStateNormal];
    [self.musicPlayer changePlayStatus];
}

- (IBAction)sliderTouchDown:(id)sender {
    _draggingSlider = YES;
    [self.musicPlayer pause];
}

- (IBAction)sliderTouchUp:(id)sender {
    _draggingSlider = NO;
    NSTimeInterval time = _slider.value;
    [self.musicPlayer playAtTime:time];
}

- (IBAction)sliderValueChanged:(id)sender {
    if (!_draggingSlider)
        return;
    
    // 更新_currentTimeLabel和_durationTimeLabel
//    int position = _timeSlider.value;
//    int duration = _timeSlider.maximumValue;

}

@end
