//
//  JYMusicPlayer.h
//  MusicPlayer
//
//  Created by miao yu on 2019/11/5.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define INVALID_PLAYING_INDEX  -1 // 无效的播放索引


NS_ASSUME_NONNULL_BEGIN

/// 歌曲播放循环模式
typedef NS_ENUM(NSInteger, PlayerLoopMode) {
    PlayerLoopAll        = 0, /// 列表循环
    PlayerLoopShuffle    = 1, /// 随机播放
    PlayerLoopSingle     = 2, /// 单曲循环
};


/// 音乐播放器类，保存有歌曲，当前播放的序号，循环模式等。
/// 需要 retain，否则会释放
@interface JYMusicPlayer : NSObject

/// 当前的歌曲列表
@property (nonatomic, strong, readonly) NSArray<NSString *> *songs;

/// 正在播放的歌曲索引
@property (nonatomic, assign, readonly) NSInteger playingIdx;

/// 歌曲播放循环模式
@property (nonatomic, assign, readonly) PlayerLoopMode loopMode;

/// 当前歌曲的播放器对象，切换歌曲时需要重新创建该对象
@property (nonatomic, strong, readonly) AVAudioPlayer *audioPlayer;

#pragma mark - Add Song

/// 添加一首歌曲
- (void)addSong:(NSString *)song;

/// 添加多首歌曲
/// @param songs 要添加的歌曲
- (void)addSongs:(NSArray<NSString *> *)songs;


#pragma mark - Player Operations

- (void)play;
- (void)pause;
- (void)playPrevSong;
- (void)playNextSong;
- (void)playIndexSong:(NSInteger)index;
- (void)playAtPosition:(NSTimeInterval)time;

/// 切换播放/暂停
- (void)changePlayStatus;

/// 修改循环模式
- (void)changeLoopMode;


@end

NS_ASSUME_NONNULL_END
