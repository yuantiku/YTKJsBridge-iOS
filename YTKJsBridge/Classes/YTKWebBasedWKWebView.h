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

@interface YTKWebBasedWKWebView : NSObject <YTKWebInterface>

- (instancetype)initWithWebView:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
