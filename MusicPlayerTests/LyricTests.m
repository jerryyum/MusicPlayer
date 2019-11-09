//
//  LyricTests.m
//  MusicPlayerTests
//
//  Created by miao yu on 2019/11/9.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JYKrcInfo.h"
#import "JYLrcInfo.h"

@interface LyricTests : XCTestCase

@end

@implementation LyricTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

/// 测试 krc 文件解析
- (void)testKrcParser {
    NSURL *krcURL = [[NSBundle mainBundle] URLForResource:@"王菲-平凡最浪漫" withExtension:@"krc" subdirectory:@"Songs"];
    NSError *error = nil;
    NSString *krcContent = [NSString stringWithContentsOfURL:krcURL usedEncoding:nil error:&error];
    XCTAssert(error == nil, @"Get file content error: %@", error);
    
    if (krcContent != nil) {
        JYKrcInfo *krcInfo = [[JYKrcInfo alloc] initWithKrcContent:krcContent];
        NSLog(@"KrcInfo: \n%@", krcInfo);
    }
}

/// 测试 lrc 文件解析
- (void)testLrcParser {
    NSURL *lrcURL = [[NSBundle mainBundle] URLForResource:@"王菲-平凡最浪漫" withExtension:@"lrc" subdirectory:@"Songs"];
    NSError *error = nil;
    NSString *lrcContent = [NSString stringWithContentsOfURL:lrcURL usedEncoding:nil error:&error];
    XCTAssert(error == nil, @"Get file content error: %@", error);
    
    if (lrcContent != nil) {
        JYLrcInfo *lrcInfo = [[JYLrcInfo alloc] initWithLrcContent:lrcContent];
        NSLog(@"LrcInfo: \n%@", lrcInfo);
    }
}

@end
