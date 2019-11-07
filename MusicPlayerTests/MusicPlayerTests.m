//
//  MusicPlayerTests.m
//  MusicPlayerTests
//
//  Created by miao yu on 2019/11/7.
//  Copyright © 2019 jerryyum. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JYKrcInfo.h"

@interface MusicPlayerTests : XCTestCase

@end

@implementation MusicPlayerTests

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

- (void)testKrcParser {
    NSURL *krcURL = [[NSBundle mainBundle] URLForResource:@"王菲-平凡最浪漫" withExtension:@"krc" subdirectory:@"Songs"];
    NSError *error = nil;
    NSString *krcContent = [NSString stringWithContentsOfURL:krcURL usedEncoding:nil error:&error];
    XCTAssert(error == nil, @"Get file content error: %@", error);
    
    if (krcContent != nil) {
        JYKrcInfo *krcInfo = [[JYKrcInfo alloc] initWithKrcContent:krcContent];
        NSLog(@"KrcInfo: %@", krcInfo);
    }
}

@end
