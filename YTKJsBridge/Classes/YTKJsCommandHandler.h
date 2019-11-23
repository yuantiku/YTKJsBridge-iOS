//
//  YTKJsCommandHandler.h
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YTKJsCommand.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YTKJsCommandHandler <NSObject>

// UIWebView or WKWebView

@property (nonatomic, weak, nullable) UIView *webView;

- (nullable NSDictionary *)handleJsCommand:(YTKJsCommand *)command inWebView:(UIView *)webView;

@end

@protocol YTKJsEventHandler <NSObject>

// UIWebView or WKWebView

@property (nonatomic, weak, nullable) UIView *webView;

- (void)handleJsEvent:(YTKJsEvent *)event inWebView:(UIView *)webView;

@end

@protocol YTKJsEventListener <NSObject>

- (void)handleJsEventWithArgument:(id)argument;

@end

NS_ASSUME_NONNULL_END
