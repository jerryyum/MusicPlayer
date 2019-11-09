//
//  JYLrcInfo.h
//  MusicPlayer
//
//  Created by miao yu on 2019/11/7.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 lrc 单句歌词模型, 开始时间+歌词内容
 例: [01:54.18][00:18.81]平凡地与你看看电影
 */
@interface JYLrcLine : NSObject

@property (nonatomic, assign) int startTime;    // 歌词开始时间, 单位ms
@property (nonatomic, copy) NSString *lineText; // 歌词的内容

@end

/**
 整首歌曲的 lrc 格式歌词信息.
 lrc 歌词, 每行歌词一个时间, 时间只能精确到每行歌词
 */
@interface JYLrcInfo : NSObject

@property (nonatomic, copy) NSString *title;   // 歌曲名
@property (nonatomic, copy) NSString *artist;  // 演唱者
@property (nonatomic, copy) NSString *album;   // 专辑
@property (nonatomic, copy) NSString *language;// 语言
@property (nonatomic, assign) int offset;      // 全局偏移量

@property (nonatomic, strong) NSMutableArray<JYLrcLine *> *lrcLines; // 整首 lrc 包含的歌词行

/// 根据文件内容构造整个 lrc 信息
/// @param content 歌词文件内容
- (instancetype)initWithLrcContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
