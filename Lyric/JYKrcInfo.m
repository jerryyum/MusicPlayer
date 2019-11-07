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

- (NSString *)getKrcLineStr {
    if (_krcAtomArray.count > 0) {
        NSMutableString *krcLineStr = [NSMutableString string];
        for (JYKrcAtom *atomKrc in _krcAtomArray) {
            [krcLineStr appendString:atomKrc.atomStr];
        }
        return krcLineStr;
    } else {
        return nil;
    }
}

- (NSString *)getKrcStrToIndex:(NSInteger)index {
    if (index <= 0) { // 返回空
        return nil;
    } else if (index > _krcAtomArray.count) { // 返回整句歌词
        return [self getKrcLineStr];
    } else { // 返回该句歌词的一部分
        NSMutableString *krcLineStr = [NSMutableString string];
        for (int i = 0; i < index; i++) {
            JYKrcAtom *atomKrc = _krcAtomArray[i];
            [krcLineStr appendString:atomKrc.atomStr];
        }
        return krcLineStr;
    }
}

@end

@implementation JYKrcInfo

- (instancetype)initWithKrcContent:(NSString *)krcContent {
    self = [super init];
    self.krcLineArray = [NSMutableArray array];
    [self parseKrcContent:krcContent];
    return self;
}

- (instancetype)initWithKrcPath:(NSString *)krcPath {
    NSString *krcContent;
    if ([[krcPath substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"http"]) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:krcPath]];
        if (data) {
            krcContent = [NSString stringWithUTF8String:data.bytes];
        }
    } else {
        krcContent = [NSString stringWithContentsOfFile:krcPath usedEncoding:nil error:nil];
    }
    
    return [self initWithKrcContent:krcContent];
}

- (void)parseKrcContent:(NSString *)krcContent {
    if (krcContent == nil) {
        return;
    }
    
    NSRange r4 = {0, 4};
    NSRange r10 = {0, 10};
    NSString *patten1 = @"(\\[\\d+\\,\\d+\\])+"; // 匹配每行歌词时间的正则表达式
    NSString *patten2 = @"(\\<\\d+\\,\\d+\\,\\d+\\>)+"; // 匹配每个字时间的正则表达式
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:patten1 options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:patten2 options:NSRegularExpressionCaseInsensitive error:nil];
    NSCharacterSet *sepCharSet = [NSCharacterSet characterSetWithCharactersInString:@",[]<>"]; // 标识时间及分割的字符集
    
    [krcContent enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {

        if (NSEqualRanges([line rangeOfString:@"[ti:"], r4)) { // 歌曲名信息
            NSRange range = {4, line.length-5};
            _title = [line substringWithRange:range];
        } else if (NSEqualRanges([line rangeOfString:@"[ar:"], r4)) { // 歌手信息
            NSRange range = {4, line.length-5};
            _singer = [line substringWithRange:range];
        } else if (NSEqualRanges([line rangeOfString:@"[al:"], r4)) { // 专辑信息
            NSRange range = {4, line.length-5};
            _album = [line substringWithRange:range];
        } else if (NSEqualRanges([line rangeOfString:@"[language:"], r10)) { // 语言信息
            NSRange range = {10, line.length-11};
            _language = [line substringWithRange:range];
        } else if (line.length > 0) { // 歌词信息
           
            NSArray *matches1 = [regex1 matchesInString:line options:NSMatchingReportCompletion range:NSMakeRange(0, line.length)];
            if (matches1.count > 0) { // matches大于0为歌词行
                NSTextCheckingResult *lastResult = [matches1 lastObject];
                NSString *timeStr = [line substringWithRange:lastResult.range]; // 歌词的时间, 例[16335,4422]
                NSString *krcLine = [line substringFromIndex:lastResult.range.location + lastResult.range.length]; // 歌词的每个字和时间, 例<0,200,0>王<200,250,0>菲
                
                NSArray *strArray = [timeStr componentsSeparatedByCharactersInSet:sepCharSet];
                if (strArray.count > 3) {
                    JYKrcLine *atomKrcLine = [[JYKrcLine alloc] init];
                    atomKrcLine.startTime = [strArray[1] intValue];
                    atomKrcLine.spanTime = [strArray[2] intValue];
                    atomKrcLine.krcAtomArray = [NSMutableArray array];
                    [_krcLineArray addObject:atomKrcLine];
                    
                    NSArray *matches2 = [regex2 matchesInString:krcLine options:NSMatchingReportCompletion range:NSMakeRange(0, krcLine.length)];
                    for (int i = 0; i < matches2.count; i++) {
                        NSTextCheckingResult *match = matches2[i];
                        NSString *atomTime = [krcLine substringWithRange:match.range];
                        NSString *atomStr;
                        if (i < matches2.count-1) {
                            NSTextCheckingResult *nextMatch = matches2[i+1];
                            NSRange range = {match.range.location + match.range.length, nextMatch.range.location-match.range.location - match.range.length};
                            atomStr = [krcLine substringWithRange:range];
                        } else {
                            atomStr = [krcLine substringFromIndex:match.range.location + match.range.length];
                        }
                        
                        NSArray *atomTimes = [atomTime componentsSeparatedByCharactersInSet:sepCharSet];
                        if (atomTimes.count > 4) {
                            JYKrcAtom *atomKrc = [[JYKrcAtom alloc] init];
                            atomKrc.startTime = [atomTimes[1] intValue];
                            atomKrc.spanTime = [atomTimes[2] intValue];
                            atomKrc.reverse = [atomTimes[3] intValue];
                            atomKrc.atomStr = atomStr;
                            [atomKrcLine.krcAtomArray addObject:atomKrc];
                        }
                    }
                }
            }
        }
    }];
}

@end
