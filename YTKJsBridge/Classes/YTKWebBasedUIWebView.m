//
//  YTKWebBasedUIWebView.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/23.
//

#import "YTKWebBasedUIWebView.h"

@interface YTKWebBasedUIWebView ()

@property (nonatomic, strong) NSString *jsCache;

@end

@implementation YTKWebBasedUIWebView

@synthesize webView;

- (instancetype)initWithWebView:(UIWebView *)webView {
    self = [super init];
    if (self) {
        self.webView = webView;
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
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:self.jsCache];
        self.jsCache = @"";
    }
}

@end
