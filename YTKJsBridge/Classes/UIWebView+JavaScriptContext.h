//
//  UIWebView+JavaScriptContext.h
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YTKWebViewDelegate <NSObject>

@optional

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)context;

@end

@interface UIWebView (JavaScriptContext)

@property (nonatomic, weak, nullable) id<YTKWebViewDelegate> ytk_delegate;

@property (nonatomic, readonly) JSContext *ytk_javaScriptContext;

@end

NS_ASSUME_NONNULL_END
