//
//  YTKWebBasedWKWebView.h
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/23.
//

#import <Foundation/Foundation.h>
#import "YTKWebInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class WKWebView;
@class YTKWebBasedWKWebView;
@class YTKJsCommand;
@class YTKJsEvent;

@protocol YTKJsCommandDelegate <NSObject>

- (nullable NSDictionary *)webView:(id<YTKWebInterface>)webview didReceiveCommand:(YTKJsCommand *)command;


@end

@protocol YTKJsEventDelegate <NSObject>

- (void)webView:(id<YTKWebInterface>)webview didReceiveEvent:(YTKJsEvent *)event;

@end

@interface YTKWebBasedWKWebView : NSObject <YTKWebInterface>

@property (nonatomic, weak, nullable) id<YTKJsCommandDelegate> delegate;

@property (nonatomic, weak, nullable) id<YTKJsEventDelegate> eventDelegate;

- (instancetype)initWithWebView:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
