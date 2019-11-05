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

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation JYMusicPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAudioSession];
    [self loadSongs];
    
    
}

- (void)setAudioSession {
    // 设置后台播放功能，并调用 setActive 将会话激活才能起作用
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
}

- (void)loadSongs {
    NSArray<NSString *> *songs = @[@"王菲-平凡最浪漫.mp3",
                                   @"容易受伤的女人.mp3",
                                   @"Groove Coverage - God Is A Girl.mp3"];
    
    [[JYMusicPlayer sharedPlayer] addSongs:songs];
}

#pragma mark - Observer

- (void)addObserver {
    
}

- (void)removeObserver {
    
}

#pragma mark - Button Actions

- (IBAction)prevButtonClicked:(id)sender {
    [[JYMusicPlayer sharedPlayer] playPreSong];
}
- (IBAction)nextButtonClicked:(id)sender {
    [[JYMusicPlayer sharedPlayer] playNextSong];
}
- (IBAction)playButtonClicked:(id)sender {
    [[JYMusicPlayer sharedPlayer] changePlayStatus];
}


@end
