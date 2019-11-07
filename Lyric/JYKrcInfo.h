//
//  JYKrcInfo.h
//  MusicPlayer
//
//  Created by miao yu on 2019/11/7.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 krc歌词的最小的单元(单个字及时间段), 时间的单位都是ms
 */
@interface JYKrcAtom : NSObject

@property (assign, nonatomic) int startTime;// 单元歌词开始时间, 从该行歌词起点开始计算
@property (assign, nonatomic) int spanTime; // 单元歌词持续时间
@property (assign, nonatomic) int reverse;  // 保留字段
@property (copy, nonatomic) NSString *atomStr;  // 单元歌词的内容

@end

/**
 krc单句歌词模型, 该句开始时间+持续时间+该句逐字显示信息
 */
@interface JYKrcLine : NSObject

@property (assign, nonatomic) int startTime;// 歌词行开始时间, 从歌曲起点开始计算
@property (assign, nonatomic) int spanTime; // 歌词行持续时间
@property (strong, nonatomic) NSMutableArray<JYKrcAtom *> *krcAtomArray;

// 获取该行的歌词字符串
- (NSString *)getKrcLineStr;

// 获取该行歌词中索引为[0,index)的字符串
- (NSString *)getKrcStrToIndex:(NSInteger)index;

@end

/**
 krc格式歌词信息, 与lrc相比, 歌词时间精确到每个字, 弥补了lrc逐字精确显示的不足
 */
@interface JYKrcInfo : NSObject

@property (copy, nonatomic) NSString *title;   // 歌曲名
@property (copy, nonatomic) NSString *singer;  // 演唱者
@property (copy, nonatomic) NSString *album;   // 专辑
@property (copy, nonatomic) NSString *language;// 语言

@property (strong, nonatomic) NSMutableArray<JYKrcLine *> *krcLineArray;

- (instancetype)initWithKrcContent:(NSString *)krcContent; // krcContent为歌词文件内容
- (instancetype)initWithKrcPath:(NSString *)krcPath;       // krcPath为歌词文件路径

@end

NS_ASSUME_NONNULL_END
