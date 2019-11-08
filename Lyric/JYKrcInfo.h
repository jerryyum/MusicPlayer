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
 krc 歌词的最小的单元[段](单个字及时间段), 时间的单位都是 ms
 示例: <0,200,0>王
 */
@interface JYKrcAtom : NSObject

@property (nonatomic, assign) int startTime;    // 单元歌词开始时间, 从该行歌词起点开始计算
@property (nonatomic, assign) int spanTime;     // 单元歌词持续时间
@property (nonatomic, assign) int reverse;      // 保留字段, 为0
@property (nonatomic, copy) NSString *atomText; // 单元歌词的内容

@end

/**
 krc单句歌词模型, 该句开始时间+持续时间+该句逐字显示信息
 示例: [2635,1750]<0,200,0>王<200,250,0>菲 <450,150,0>- <600,200,0>平<800,200,0>凡<1000,200,0>最<1200,200,0>浪<1400,350,0>漫
 */
@interface JYKrcLine : NSObject

@property (nonatomic, assign) int startTime; // 歌词行开始时间, 从歌曲起点开始计算
@property (nonatomic, assign) int spanTime;  // 歌词行持续时间
@property (nonatomic, strong) NSArray<JYKrcAtom *> *krcAtoms; // 一行歌词包含的基本段

/// 获取该行的歌词字符串
- (NSString *)getKrcLineText;

/// 获取该行歌词中索引为 [0,index) 的字符串
/// @param index 结束位置的索引
- (NSString *)getKrcLineTextToIndex:(NSInteger)index;

@end

/**
 整首歌曲的 krc 格式歌词信息.
 与 lrc 相比, 歌词时间精确到每个字, 弥补了 lrc 逐字精确显示的不足.
 示例:
 [id:$00000000]
 [ar:王菲]
 [ti:平凡最浪漫]
 [by:]
 [hash:d807ade477f451e207aaead21b2ac685]
 [al:]
 [sign:]
 [total:262482]
 [offset:0]
 [2635,1750]<0,200,0>王<200,250,0>菲 <450,150,0>- <600,200,0>平<800,200,0>凡<1000,200,0>最<1200,200,0>浪<1400,350,0>漫
 */
@interface JYKrcInfo : NSObject

@property (nonatomic, copy) NSString *title;   // 歌曲名
@property (nonatomic, copy) NSString *artist;  // 艺术家
@property (nonatomic, copy) NSString *album;   // 专辑
@property (nonatomic, copy) NSString *language;// 语言
@property (nonatomic, assign) int offset;      // 全局偏移量

@property (nonatomic, strong) NSMutableArray<JYKrcLine *> *krcLines; // 整首krc包含的歌词行

/// 根据文件内容构造整个 krc 信息
/// @param content 歌词文件内容
- (instancetype)initWithKrcContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
