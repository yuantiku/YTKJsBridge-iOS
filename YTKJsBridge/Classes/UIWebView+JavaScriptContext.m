//
//  UIWebView+JavaScriptContext.m
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import "UIWebView+JavaScriptContext.h"
#import <objc/runtime.h>

static NSHashTable<UIWebView *> *YTKWebViews = nil;

@interface UIWebView (JavaScriptCore_Private)

- (void)didCreateJavaScriptContext:(JSContext *)context;

@end

@implementation NSObject (WebFrameLoadDelegate)

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(id)frame {
    void (^notifyDidCreateJavaScriptContext)(void) = ^{
        for (UIWebView *webView in YTKWebViews) {
            NSString *cookie = [NSString stringWithFormat: @"ytk_webView_%lud", (unsigned long)webView.hash];

            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"var %@ = '%@'", cookie, cookie]];

            if ([context[cookie].toString isEqualToString:cookie]) {
                [webView didCreateJavaScriptContext:context];
                return;
            }
        }
    };

    if ([NSThread isMainThread]) {
        notifyDidCreateJavaScriptContext();
    } else {
        dispatch_async( dispatch_get_main_queue(), notifyDidCreateJavaScriptContext);
    }
}
@end

@implementation UIWebView (JavaScriptContext)

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YTKWebViews = [NSHashTable weakObjectsHashTable];
    });

    NSAssert([NSThread isMainThread], @"Error, we aren't on the main thread?");

    UIWebView *webView = [super allocWithZone:zone];
    [YTKWebViews addObject:webView];

    return webView;
}

- (void)didCreateJavaScriptContext:(JSContext *)context {
    [self willChangeValueForKey:@"ytk_javaScriptContext"];
    objc_setAssociatedObject(self, @selector(ytk_javaScriptContext), context, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"ytk_javaScriptContext"];

    if ([self.ytk_delegate respondsToSelector: @selector(webView:didCreateJavaScriptContext:)] ) {
        id<YTKWebViewDelegate> delegate = (id<YTKWebViewDelegate>)self.ytk_delegate;
        [delegate webView:self didCreateJavaScriptContext:context];
    }
}

- (JSContext*)ytk_javaScriptContext {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYtk_delegate:(id<YTKWebViewDelegate>)ytk_delegate {
    [self willChangeValueForKey:@"ytk_delegate"];
    objc_setAssociatedObject(self, @selector(ytk_delegate), ytk_delegate, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"ytk_delegate"];
}

- (id<YTKWebViewDelegate>)ytk_delegate {
    return objc_getAssociatedObject(self, _cmd);
}

@end
