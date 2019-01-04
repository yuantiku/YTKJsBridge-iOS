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
    [self.bridge addJsCommandHandler:[YTKAlertHandler new]];
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"testWebView"
                                             withExtension:@"htm"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
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
