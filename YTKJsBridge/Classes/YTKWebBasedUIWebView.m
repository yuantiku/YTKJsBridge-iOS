//
//  YTKWebBasedUIWebView.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/23.
//

#import "YTKWebBasedUIWebView.h"

@interface YTKWebBasedUIWebView ()

@property (nonatomic, weak, nullable) UIWebView *webView;

@property (nonatomic, strong) NSString *jsCache;

@end

@implementation YTKWebBasedUIWebView

- (instancetype)initWithWebView:(UIWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
        _jsCache = @"";
    }
    return self;
}

#pragma mark - YTKWebInterface

- (void)evaluateJavaScript:(NSString *)js {
    if (![js isKindOfClass:NSString.class] || js.length <= 0) {
        return;
    }
    @synchronized (self) {
        self.jsCache = [self.jsCache stringByAppendingString:js];
        if ([self.jsCache length] == 0) {
            return;
        }
        [self.webView stringByEvaluatingJavaScriptFromString:self.jsCache];
        self.jsCache = @"";
    }
}

@end
