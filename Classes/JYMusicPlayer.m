//
//  JYMusicPlayer.m
//  MusicPlayer
//
//  Created by miao yu on 2019/11/5.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "JYMusicPlayer.h"

@interface JYMusicPlayer () <AVAudioPlayerDelegate>

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

- (instancetype)init {
    self = [super init];
    _playingIdx = INVALID_PLAYING_INDEX;
    _loopMode = PlayerLoopAll;
    _songs = [NSMutableArray arrayWithCapacity:10];
    return self;
}

- (void)dealloc {
    if (_audioPlayer != nil) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}

#pragma mark - Add Song

- (void)addSong:(NSString *)song {
    [_songs addObject:song];
}

- (void)addSongs:(NSArray<NSString *> *)songs {
    [_songs addObjectsFromArray:songs];
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

- (void)playPrevSong {
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
            _audioPlayer = nil;
        }
        
        self.playingIdx = index;
        
        NSString *song = _songs[_playingIdx];
        NSURL *songURL = [[NSBundle mainBundle] URLForResource:song withExtension:nil subdirectory:@"Songs"];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:nil];
        _audioPlayer.volume = 1.f;
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
}

- (void)playAtTime:(NSTimeInterval)time {
    if (_audioPlayer != nil) {
        NSTimeInterval now = _audioPlayer.deviceCurrentTime;
        BOOL ret = [_audioPlayer playAtTime:now + time];
        NSLog(@"playAtTime: %@", @(ret));
    }
}

- (void)changePlayStatus {
    if (_audioPlayer.isPlaying) {
        [self pause];
    } else {
        [self play];
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

#pragma mark - AVAudioPlayerDelegate

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (flag) {
        [self playNextSong];
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"播放器出错：%@", error);
}

@end
