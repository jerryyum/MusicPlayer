//
//  JYMusicPlayer.m
//  MusicPlayer
//
//  Created by miao yu on 2019/10/25.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "JYMusicPlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface JYMusicPlayer ()

/// 当前的歌曲列表
@property (nonatomic, strong) NSMutableArray<NSString *> *songs;
/// 正在播放的歌曲索引
@property (nonatomic, assign) NSInteger playingIdx;
/// 歌曲播放循环模式
@property (nonatomic, assign) PlayerLoopMode loopMode;

/// 当前歌曲的播放器对象，切换歌曲时需要重新创建该对象
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation JYMusicPlayer

- (NSArray<NSString *> *)songs {
    return [_songs copy];
}

/// 根据循环模式，产生下一个索引
- (NSInteger)_nextIndex {
    if (_songs == nil || _songs.count == 0) {
        return INVALID_PLAYING_INDEX;
    }
    
    NSInteger nextIndex = INVALID_PLAYING_INDEX;
    if (_loopMode == PlayerLoopAll) {
        nextIndex = (_playingIdx + 1) % _songs.count;
    } else if (_loopMode == PlayerLoopSingle) {
        nextIndex = _playingIdx == INVALID_PLAYING_INDEX ? 0 : _playingIdx;
    } else if (_loopMode == PlayerLoopShuffle) {
        NSUInteger songCount = _songs.count;
        nextIndex = arc4random_uniform((u_int32_t)songCount); // 产生随机数
        if (nextIndex == _playingIdx) {
            // 产生的随机数与前播放歌曲序号相等, 则+1确保不要播同一首歌
            nextIndex = (nextIndex + 1) % songCount;
        }
    }
    return nextIndex;
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    _playingIdx = INVALID_PLAYING_INDEX;
    _loopMode = PlayerLoopAll;
    return self;
}

#pragma mark - Add Song

- (void)addSong:(NSString *)song {
    if (_songs != nil) {
        [_songs addObject:song];
    } else {
        _songs = [NSMutableArray arrayWithObjects:song, nil];
    }
}

- (void)addSongs:(NSArray<NSString *> *)songs {
    if (_songs != nil) {
        [_songs addObjectsFromArray:songs];
    } else {
        _songs = [songs mutableCopy];
    }
}

#pragma mark - Player Operations

- (void)play {
    if (_songs == nil || _songs.count == 0) {
        NSLog(@"歌曲列表为空，请添加歌曲！");
        return;
    }
    
    NSInteger index;
    if (_playingIdx != INVALID_PLAYING_INDEX) {
        index = _playingIdx;
    } else {
        index = [self _nextIndex];
    }
    [self playIndexSong:index];
}

- (void)pause {
    if (_audioPlayer.isPlaying) {
        [_audioPlayer pause];
    }
}

- (void)playPreSong {
    if (_songs == nil || _songs.count == 0) {
        NSLog(@"歌曲列表为空，请添加歌曲！");
        return;
    }
    
    NSInteger songIdx = 0;
    if (_playingIdx == 0) {
        NSLog(@"已经是第一首歌曲！");
        return;
        
    } else if (_playingIdx > 0) {
        songIdx = _playingIdx - 1;
    }
    
    [self playIndexSong:songIdx];
}

- (void)playNextSong {
    if (_songs == nil || _songs.count == 0) {
        NSLog(@"歌曲列表为空，请添加歌曲！");
        return;
    }
    
    NSInteger nextIndex = [self _nextIndex];
    [self playIndexSong:nextIndex];
}

- (void)playIndexSong:(NSInteger)index {
    NSAssert(index != INVALID_PLAYING_INDEX, @"无效的歌曲索引");
    NSAssert(index < _songs.count, @"索引值超过歌曲数量");
    
    if (index == _playingIdx) {
        if (!_audioPlayer.isPlaying) {
            [_audioPlayer play];
        }
    } else {
        if (_audioPlayer != nil) {
            [_audioPlayer stop];
        }
        
        _audioPlayer = nil;
        _playingIdx = index;
        
        NSString *song = _songs[_playingIdx];
        NSURL *songURL = [[NSBundle mainBundle] URLForResource:song withExtension:nil subdirectory:@"Songs"];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:nil];
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
}

- (void)changeLoopMode {
    switch (_loopMode) {
        case PlayerLoopAll:
            self.loopMode = PlayerLoopShuffle;
            NSLog(@"随机播放");
            break;
        case PlayerLoopShuffle:
            self.loopMode = PlayerLoopSingle;
            NSLog(@"单曲循环");
            break;
        case PlayerLoopSingle:
            self.loopMode = PlayerLoopAll;
            NSLog(@"列表循环");
            break;
        default:
            break;
    }
}

@end
