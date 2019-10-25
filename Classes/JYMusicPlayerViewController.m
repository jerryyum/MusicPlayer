//
//  JYMusicPlayerViewController.m
//  MusicPlayer
//
//  Created by miao yu on 2019/10/25.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "JYMusicPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface JYMusicPlayerViewController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *songs;

@end

@implementation JYMusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSongs];
    [self setAudioSession];
    
    
}

- (void)loadSongs {
    _songs = [NSMutableArray arrayWithObjects:
              @"王菲-平凡最浪漫",
              @"容易受伤的女人",
              @"Groove Coverage - God Is A Girl",
              nil];
}

- (void)setAudioSession {
    // 设置后台播放功能，并调用 setActive 将会话激活才能起作用
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
}

#pragma mark - Observer

- (void)addObserver {
    
}

- (void)removeObserver {
    
}

@end
