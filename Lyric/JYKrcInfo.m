//
//  JYKrcInfo.m
//  MusicPlayer
//
//  Created by miao yu on 2019/11/7.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import "JYKrcInfo.h"

@implementation JYKrcAtom

@end


@implementation JYKrcLine

- (NSString *)getKrcLineText {
    NSMutableString *lineText = [NSMutableString stringWithCapacity:_krcAtoms.count<<1];
    [_krcAtoms enumerateObjectsUsingBlock:^(JYKrcAtom * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [lineText appendString:obj.atomText];
    }];
    return [lineText copy];
}

- (NSString *)getKrcLineTextToIndex:(NSInteger)index {
    if (index <= 0) { // 返回空
        return nil;
    }
    
    NSMutableString *lineText = [NSMutableString stringWithCapacity:index<<1];
    [_krcAtoms enumerateObjectsUsingBlock:^(JYKrcAtom * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [lineText appendString:obj.atomText];
        *stop = idx == index-1;
    }];
    return [lineText copy];
}

@end


@implementation JYKrcInfo

- (instancetype)initWithKrcContent:(NSString *)content {
    self = [super init];
    _krcLines = [NSMutableArray arrayWithCapacity:32];
    [self parseKrcContent:content];
    return self;
}

- (void)parseKrcContent:(NSString *)content {
    if (content == nil) {
        return;
    }
    
    NSString *pattenLine = @"(\\[\\d+\\,\\d+\\])+"; // 匹配每行歌词时间的正则表达式
    NSString *pattenAtom = @"(\\<\\d+\\,\\d+\\,\\d+\\>)+"; // 匹配段的时间的正则表达式
    NSRegularExpression *regexLine = [NSRegularExpression regularExpressionWithPattern:pattenLine options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *regexAtom = [NSRegularExpression regularExpressionWithPattern:pattenAtom options:NSRegularExpressionCaseInsensitive error:nil];
    NSCharacterSet *sepCharSet = [NSCharacterSet characterSetWithCharactersInString:@",[]<>"]; // 标识时间及分割的字符集
    
    // 内容按一行一行来遍历
    [content enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {

        if ([line hasPrefix:@"[ti:"]) { // 歌曲名
            self.title = [line substringWithRange:NSMakeRange(4, line.length-5)];
        } else if ([line hasPrefix:@"[ar:"]) { // 艺术家
            self.artist = [line substringWithRange:NSMakeRange(4, line.length-5)];
        } else if ([line hasPrefix:@"[al:"]) { // 专辑
            self.album = [line substringWithRange:NSMakeRange(4, line.length-5)];
        } else if ([line hasPrefix:@"[language:"]) { // 语言
            self.album = [line substringWithRange:NSMakeRange(10, line.length-11)];
        } else if ([line hasPrefix:@"[offset:"]) { // 全局偏移量
            self.offset = [[line substringWithRange:NSMakeRange(8, line.length-9)] intValue];
        } else if (line.length > 0) { // 歌词信息
            
            NSTextCheckingResult *matches1 = [regexLine firstMatchInString:line options:NSMatchingReportCompletion range:NSMakeRange(0, line.length)];
            if (matches1 != nil) { // 不为空则为歌词行
                NSString *linePrefix = [line substringToIndex:matches1.range.length]; // 歌词的时间, 例[16335,4422]
                NSString *lineSuffix = [line substringFromIndex:matches1.range.location + matches1.range.length]; // 歌词的每个字和时间, 例<0,200,0>王<200,250,0>菲
                
                NSArray<NSString *> *strArray = [linePrefix componentsSeparatedByCharactersInSet:sepCharSet];
                if (strArray.count > 3) {
                    JYKrcLine *krcLine = [[JYKrcLine alloc] init];
                    krcLine.startTime = [strArray[1] intValue];
                    krcLine.spanTime = [strArray[2] intValue];
                    krcLine.krcAtoms = [NSMutableArray arrayWithCapacity:20];
                    [self.krcLines addObject:krcLine];
                    
                    NSArray<NSTextCheckingResult *> *matches2 = [regexAtom matchesInString:lineSuffix options:NSMatchingReportCompletion range:NSMakeRange(0, lineSuffix.length)];
                    for (int i = 0; i < matches2.count; i++) {
                        NSTextCheckingResult *match = matches2[i];
                        NSString *atomTime = [lineSuffix substringWithRange:match.range];
                        NSString *atomStr;
                        if (i < matches2.count-1) {
                            NSTextCheckingResult *nextMatch = matches2[i+1];
                            NSRange range = {match.range.location + match.range.length, nextMatch.range.location-match.range.location - match.range.length};
                            atomStr = [lineSuffix substringWithRange:range];
                        } else {
                            atomStr = [lineSuffix substringFromIndex:match.range.location + match.range.length];
                        }

                        NSArray *atomTimes = [atomTime componentsSeparatedByCharactersInSet:sepCharSet];
                        if (atomTimes.count > 4) {
                            JYKrcAtom *atomKrc = [[JYKrcAtom alloc] init];
                            atomKrc.startTime = [atomTimes[1] intValue];
                            atomKrc.spanTime = [atomTimes[2] intValue];
                            atomKrc.reverse = [atomTimes[3] intValue];
                            atomKrc.atomText = atomStr;
                            [krcLine.krcAtoms addObject:atomKrc];
                        }
                    }
                }
            }
        }
    }];
}

@end
