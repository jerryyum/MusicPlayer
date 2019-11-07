//
//  JYLrcInfo.m
//  MusicPlayer
//
//  Created by miao yu on 2019/11/7.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "JYLrcInfo.h"

@implementation JYLrcLine

- (instancetype)initWithStartTime:(int)startTime lrcLineStr:(NSString *)lrcLineStr {
    self = [super init];
    self.startTime = startTime;
    self.lrcLineStr = lrcLineStr;
    return self;
}

@end

@implementation JYLrcInfo

- (instancetype)initWithLrcContent:(NSString *)lrcContent {
    self = [super init];
    self.lrcLineArray = [NSMutableArray array];
    [self parseLrcContent:lrcContent];
    return self;
}

- (instancetype)initWithLrcPath:(NSString *)lrcPath {
    NSString *lrcContent;
    if ([[lrcPath substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"http"]) { // 网络歌词
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:lrcPath]];
        if (data) {
            lrcContent = [NSString stringWithUTF8String:data.bytes];
        }
    } else {
        lrcContent = [NSString stringWithContentsOfFile:lrcPath usedEncoding:nil error:nil];
    }
    
    return [self initWithLrcContent:lrcContent];
}

- (void)parseLrcContent:(NSString *)lrcContent {
    if (lrcContent == nil) {
        return;
    }
    
    NSRange r4 = {0, 4}; // 头部标记的Range
    NSString *patten = @"\\[(\\d{2}:\\d{2}\\.\\d{2})\\]"; // 匹配歌词时间的正则表达式
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"[mm:ss.SS]";
    NSDate *beginDate = [formatter dateFromString:@"[00:00.00]"];
    
    [lrcContent enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        
        if (NSEqualRanges([line rangeOfString:@"[ti:"], r4)) { // 歌曲名信息
            NSRange range = {4, line.length-5};
            _title = [line substringWithRange:range];
        } else if (NSEqualRanges([line rangeOfString:@"[ar:"], r4)) { // 歌手信息
            NSRange range = {4, line.length-5};
            _singer = [line substringWithRange:range];
        } else if (NSEqualRanges([line rangeOfString:@"[al:"], r4)) { // 专辑信息
            NSRange range = {4, line.length-5};
            _album = [line substringWithRange:range];
        } else if (NSEqualRanges([line rangeOfString:@"[la:"], r4)) { // 语言信息
            NSRange range = {4, line.length-5};
            _language = [line substringWithRange:range];
        } else if (line.length > 0) { // 歌词信息

            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patten
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            NSArray *matches = [regex matchesInString:line
                                              options:NSMatchingReportCompletion
                                                range:NSMakeRange(0, line.length)];
            
            // 获取歌词内容
            NSTextCheckingResult *lastResult = [matches lastObject];
            NSString *lrcLineStr = [line substringFromIndex:lastResult.range.location + lastResult.range.length];
            
            // 获取每一个结果值, 解析成时间间隔, 并与该行的歌词生成KtvAtomLyric对象, 加入到结果数组中
            for (NSTextCheckingResult *match in matches) {
                
                NSString *timeStr = [line substringWithRange:match.range]; // 歌词的时间
                NSDate *currentDate = [formatter dateFromString:timeStr];
                NSTimeInterval time = [currentDate timeIntervalSinceDate:beginDate];

                JYLrcLine *atomLyric = [[JYLrcLine alloc] initWithStartTime:time*1000 lrcLineStr:lrcLineStr];
                [self.lrcLineArray addObject:atomLyric];
            }
        }
    }];
    
    // 所有数据加载完成之后进行排序
    // sortUsingDescriptors: 可变数组的排序方法, 可以传多个排序条件
    // NSSortDescriptor: 排序描述类, 需要告诉按照那个key, ascending: 是否升序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
    [self.lrcLineArray sortUsingDescriptors:@[sort]];
}

@end
