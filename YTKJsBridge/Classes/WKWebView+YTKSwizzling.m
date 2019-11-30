//
//  WKWebView+YTKSwizzling.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/30.
//

#import "WKWebView+YTKSwizzling.h"
#import <objc/runtime.h>

NSString * const YTKWKUIDelegateDidChangeNotification = @"YTKDidCallSetUIDelegateNotification";

@implementation WKWebView (YTKSwizzling)

+ (void)load {
    // hook UIWebView
    Method originalMethod = class_getInstanceMethod([WKWebView class], @selector(setUIDelegate:));
    Method swizzledMethod = class_getInstanceMethod([WKWebView class], @selector(ytk_setUIDelegate:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)ytk_setUIDelegate:(id<WKUIDelegate>)UIDelegate {
    // 获得 delegate 的实际调用类
    [self ytk_setUIDelegate:UIDelegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:YTKWKUIDelegateDidChangeNotification object:self];
    });
}


@end
