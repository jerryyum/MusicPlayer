//
//  JYLrcInfo.m
//  MusicPlayer
//
//  Created by miao yu on 2019/11/7.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "JYLrcInfo.h"

@implementation JYLrcLine

@end

@implementation JYLrcInfo

- (instancetype)initWithLrcContent:(NSString *)content {
    self = [super init];
    self.lrcLines = [NSMutableArray array];
    [self parseLrcContent:content];
    return self;
}

- (void)parseLrcContent:(NSString *)content {
    if (content == nil) {
        return;
    }
    
    NSString *patten = @"\\[(\\d{2}:\\d{2}\\.\\d{2})\\]"; // 匹配歌词时间的正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionCaseInsensitive error:nil];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"[mm:ss.SS]";
    NSDate *beginDate = [formatter dateFromString:@"[00:00.00]"];
    
    [content enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        
        if ([line hasPrefix:@"[ti:"]) { // 歌曲名
            self.title = [line substringWithRange:NSMakeRange(4, line.length-5)];
        } else if ([line hasPrefix:@"[ar:"]) { // 艺术家
            self.artist = [line substringWithRange:NSMakeRange(4, line.length-5)];
        } else if ([line hasPrefix:@"[al:"]) { // 专辑
            self.album = [line substringWithRange:NSMakeRange(4, line.length-5)];
        } else if ([line hasPrefix:@"[la:"]) { // 语言
            self.album = [line substringWithRange:NSMakeRange(4, line.length-5)];
        } else if ([line hasPrefix:@"[offset:"]) { // 全局偏移量
            self.offset = [[line substringWithRange:NSMakeRange(8, line.length-9)] intValue];
        } else if (line.length > 0) { // 歌词信息
            
            NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:line options:NSMatchingReportCompletion range:NSMakeRange(0, line.length)];
            
            // 获取歌词内容
            NSTextCheckingResult *lastResult = [matches lastObject];
            NSString *lineText = [line substringFromIndex:lastResult.range.location + lastResult.range.length];
            
            // 获取每一个结果值, 解析成时间间隔, 并与该行的歌词生成 JYLrcLine 对象, 加入到结果数组中
            for (NSTextCheckingResult *match in matches) {
                NSString *timeStr = [line substringWithRange:match.range]; // 歌词的时间
                NSDate *currentDate = [formatter dateFromString:timeStr];
                NSTimeInterval time = [currentDate timeIntervalSinceDate:beginDate];

                JYLrcLine *lrcLine = [[JYLrcLine alloc] init];
                lrcLine.startTime = 1000 * time;
                lrcLine.lineText = lineText;
                [self.lrcLines addObject:lrcLine];
            }
        }
    }];
    
    // 所有数据加载完成之后进行排序
    // sortUsingDescriptors: 可变数组的排序方法, 可以传多个排序条件
    // NSSortDescriptor: 排序描述类, 需要告诉按照那个key, ascending: 是否升序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
    [self.lrcLines sortUsingDescriptors:@[sort]];
}

@end
