//
//  YTKViewController.m
//  YTKJsBridge
//
//  Created by lihc on 12/25/2018.
//  Copyright (c) 2018 lihc. All rights reserved.
//

#import "YTKViewController.h"
#import "YTKJsBridge.h"
#import "YTKAlertHandler.h"
#import "YTKFibHandler.h"

@interface YTKViewController ()

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) YTKJsBridge *bridge;

@end

@implementation YTKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.webView];
    self.webView.frame = self.view.frame;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.bridge addJsCommandHandlers:@[[YTKAlertHandler new]] namespace:@"yuantiku"];
//    [self.bridge addJsCommandHandlers:@[[YTKFibHandler new]] namespace:@"math"];
    __weak typeof(self)weakSelf = self;
    [self.bridge addSyncJsCommandName:@"fib" namespace:@"math" handler:(id)^(NSDictionary *arguments) {
        NSInteger n = [[arguments objectForKey:@"n"] integerValue];
        return @([weakSelf fibSequence:n]);
    }];
    [self.bridge addAsyncJsCommandName:@"asyncFib" namespace:@"math" handler:^(NSDictionary *arguments, YTKDataBlock block) {
        NSInteger n = [[arguments objectForKey:@"n"] integerValue];
        block(nil, @([weakSelf fibSequence:n]));
    }];
    [self.bridge listenJsEvent:@"resize" handler:^(NSDictionary *arguments) {
        // 客户端监听js页面大小发生变化事件
    }];
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"testWebView"
                                             withExtension:@"htm"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
}

- (NSInteger)fibSequence:(NSInteger)n {
    if (n < 2) {
        return n == 0 ? 0 : 1;
    } else {
        return [self fibSequence:n - 1] + [self fibSequence:n -2];
    }
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
    }
    return _bridge;
}

@end
