//
//  YTKWebBasedWKWebView.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/23.
//

#import "YTKWebBasedWKWebView.h"
#import <WebKit/WebKit.h>

@interface YTKWebBasedWKWebView ()

@property (nonatomic, weak, nullable) WKWebView *webView;

@end

@implementation YTKWebBasedWKWebView

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
    }
    return self;
}

#pragma mark - YTKWebInterface

- (void)evaluateJavaScript:(NSString *)js {
    if (![js isKindOfClass:NSString.class] || js.length <= 0) {
        return;
    }
    [self.webView evaluateJavaScript:js completionHandler:nil];
}

@end
