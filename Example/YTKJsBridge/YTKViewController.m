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
#import "YTKIsLastHandler.h"
#import "YTKFibHandler.h"
#import "YTKJsCommandHandler.h"
#import <WebKit/WebKit.h>

const static BOOL UseWK = YES;

@interface YTKViewController () <YTKJsEventListener, WKUIDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) YTKJsBridge *bridge;

@end

@implementation YTKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.webView];
    self.webView.frame = self.view.frame;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if (UseWK) {
        [self.view addSubview:self.wkWebView];
        self.wkWebView.frame = self.view.frame;
        self.wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    [self.bridge addJsCommandHandlers:@[[YTKAlertHandler new]] namespace:@"yuantiku"];
//    [self.bridge addJsCommandHandlers:@[[YTKFibHandler new]] namespace:@"math"];
    __weak typeof(self)weakSelf = self;
    [self.bridge addSyncJsCommandName:@"fib" namespace:@"math" impBlock:^id(NSArray * _Nullable argument) {
        NSInteger n = [argument.firstObject integerValue];
        return @([weakSelf fibSequence:n]);
    }];
    [self.bridge addAsyncJsCommandName:@"asyncFib" namespace:@"math" impBlock:^(NSArray * _Nullable argument, YTKJsCallback block) {
        NSInteger n = [argument.firstObject integerValue];
        block(nil, @([weakSelf fibSequence:n]));
    }];
    [self.bridge addVoidSyncJsCommandName:@"voidSyncCall" namespace:@"math" impBlock:^(NSArray * _Nullable argument) {
        NSLog(@"js call native voidSyncCall method");
    }];
    [self.bridge listenEvent:@"resize" callback:^(NSArray *argument) {
        // 客户端监听js页面大小发生变化事件
        NSLog(@"block %@", argument);
    }];
    [self.bridge addListener:self forEvent:@"resize"];
    if (UseWK) {
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"wkTestWebView"
                                          withExtension:@"htm"];
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
    } else {
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"testWebView"
                                                 withExtension:@"htm"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
    }

    UIButton *btn = [UIButton new];
    [btn setBackgroundColor:UIColor.grayColor];
    [btn setTitle:@"Notify Native Click Event" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(63, 500, 250, 100);
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];

    // test
    self.wkWebView.UIDelegate = self;
}

- (void)handleJsEventWithArgument:(NSArray *)argument {
    NSLog(@"listener %@", argument);
}

- (void)btnPressed:(UIButton *)btn {
    [self.bridge emit:@"click" argument:@[@"click event"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSInteger)fibSequence:(NSInteger)n {
    if (n < 2) {
        return n == 0 ? 0 : 1;
    } else {
        return [self fibSequence:n - 1] + [self fibSequence:n -2];
    }
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    completionHandler(nil);
}

#pragma mark - Properties

- (UIWebView *)webView {
    if (nil == _webView) {
        _webView = [UIWebView new];
    }
    return _webView;
}

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = YES;
        if (@available(iOS 9.0, *)) {
            configuration.requiresUserActionForMediaPlayback = NO;
        } else {
            // Fallback on earlier versions
        }
        [configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        _wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];

        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _wkWebView;
}


- (YTKJsBridge *)bridge {
    if (nil == _bridge) {
        if (UseWK) {
            _bridge = [[YTKJsBridge alloc] initWithWebView:self.wkWebView];
        } else {
            _bridge = [[YTKJsBridge alloc] initWithWebView:self.webView];
        }
        [_bridge setDebugMode:YES];
    }
    return _bridge;
}

@end
