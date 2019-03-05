//
//  YTKJsBridgeTests.m
//  YTKJsBridgeTests
//
//  Created by lihc on 12/25/2018.
//  Copyright (c) 2018 lihc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTKJsBridge.h"
#import "YTKAlertHandler.h"

@import XCTest;

@interface Tests : XCTestCase

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) YTKJsBridge *bridge;

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    [self.bridge addJsCommandHandlers:@[[YTKAlertHandler new]] namespace:@"yuantiku"];
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"testWebView"
                                             withExtension:@"htm"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
    XCTAssertTrue(true);
}

- (UIWebView *)webView {
    if (nil == _webView) {
        _webView = [UIWebView new];
    }
    return _webView;
}

- (YTKJsBridge *)bridge {
    if (nil == _bridge) {
        _bridge = [[YTKJsBridge alloc] initWithWebView:self.webView];
        [_bridge setDebugMode:YES];
    }
    return _bridge;
}

@end

