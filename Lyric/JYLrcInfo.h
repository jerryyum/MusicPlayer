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
 lrc单句歌词模型, 开始时间+歌词内容
 */
@interface JYLrcLine : NSObject

@property (assign, nonatomic) int startTime;       // 歌词开始时间, 单位ms
@property (copy, nonatomic) NSString *lrcLineStr;  // 歌词的内容

- (instancetype)initWithStartTime:(int)startTime lrcLineStr:(NSString *)lrcLineStr;

@end

/**
 lrc格式歌词信息, 每行歌词一个时间, 时间只能精确到每行歌词
 */
@interface JYLrcInfo : NSObject

@property (copy, nonatomic) NSString *title;   // 歌曲名
@property (copy, nonatomic) NSString *singer;  // 演唱者
@property (copy, nonatomic) NSString *album;   // 专辑
@property (copy, nonatomic) NSString *language;// 语言

@property (strong, nonatomic) NSMutableArray<JYLrcLine *> *lrcLineArray;

- (instancetype)initWithLrcContent:(NSString *)lrcContent; // lrcContent为歌词文件内容
- (instancetype)initWithLrcPath:(NSString *)lrcPath;       // lrcPath为歌词文件路径

@end

NS_ASSUME_NONNULL_END
