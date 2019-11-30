//
//  YTKWebBasedWKWebView.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/23.
//

#import "YTKWebBasedWKWebView.h"
#import <WebKit/WebKit.h>
#import "YTKJsUtils.h"
#import "YTKJsCommand.h"
#import "WKWebView+YTKSwizzling.h"

@interface YTKWebBasedWKWebView () <WKUIDelegate>

@property (nonatomic, weak, nullable) id<WKUIDelegate> uiDelegate;

@end

@implementation YTKWebBasedWKWebView

@synthesize webView;

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        if (webView.UIDelegate) {
            _uiDelegate = webView.UIDelegate;
        }
        [webView ytk_setUIDelegate:self];
        self.webView = webView;
        [self registerNotifications];
    }
    return self;
}

- (void)dealloc {
    [self unregisterNotifications];
}

#pragma mark - Notifications

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIDelegateChangeNotification:) name:YTKWKUIDelegateDidChangeNotification object:nil];
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleUIDelegateChangeNotification:(NSNotification *)notification {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    WKWebView *web = notification.object;
    if (web == self.webView && web.UIDelegate != self) {
        self.uiDelegate = web.UIDelegate;
        [web ytk_setUIDelegate:self];
    }
}

#pragma mark - YTKWebInterface

- (void)evaluateJavaScript:(NSString *)js {
    if (![js isKindOfClass:NSString.class] || js.length <= 0) {
        return;
    }
    [(WKWebView *)self.webView evaluateJavaScript:js completionHandler:nil];
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if ([self.uiDelegate respondsToSelector:@selector(webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)]) {
        return [self.uiDelegate webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
    }
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(ios(9.0)) {
    if (@available(iOS 9.0, *)) {
        if ([self.uiDelegate respondsToSelector:@selector(webViewDidClose:)]) {
            [self.uiDelegate webViewDidClose:webView];
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if ([self.uiDelegate respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.uiDelegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        completionHandler();
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    if ([self.uiDelegate respondsToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.uiDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        completionHandler(YES);
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    NSDictionary *dict = [YTKJsUtils jsonStringToObject:prompt];
    if (dict) {
        // js command
        if (dict[@"event"] && [self.eventDelegate respondsToSelector:@selector(webView:didReceiveEvent:)]) {
            YTKJsEvent *event = [[YTKJsEvent alloc] initWithDictionary:dict];
            [self.eventDelegate webView:self didReceiveEvent:event];
            completionHandler(nil);
        } else if (dict[@"methodName"] && [self.delegate respondsToSelector:@selector(webView:didReceiveCommand:)]) {
            YTKJsCommand *command = [[YTKJsCommand alloc] initWithDictionary:dict];
            NSDictionary *result = [self.delegate webView:self didReceiveCommand:command];
            if (result) {
                completionHandler([YTKJsUtils objToJsonString:result]);
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    } else {
        if ([self.uiDelegate respondsToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]) {
            [self.uiDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        } else {
            completionHandler(nil);
        }
    }
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)) {
    if (@available(iOS 10.0, *)) {
        if ([self.uiDelegate respondsToSelector:@selector(webView:shouldPreviewElement:)]) {
            return [self.uiDelegate webView:webView shouldPreviewElement:elementInfo];
        }
    }
    return NO;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0)) {
    if (@available(iOS 10.0, *)) {
        if ([self.uiDelegate respondsToSelector:@selector(webView:previewingViewControllerForElement:defaultActions:)]) {
            return [self.uiDelegate webView:webView previewingViewControllerForElement:elementInfo defaultActions:previewActions];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0)) {
    if (@available(iOS 10.0, *)) {
        if ([self.uiDelegate respondsToSelector:@selector(webView:commitPreviewingViewController:)]) {
            [self.uiDelegate webView:webView commitPreviewingViewController:previewingViewController];
        }
    }
}

@end
