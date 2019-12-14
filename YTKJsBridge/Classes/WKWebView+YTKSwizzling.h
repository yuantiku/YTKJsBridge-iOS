//
//  WKWebView+YTKSwizzling.h
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/30.
//

#import <WebKit/WebKit.h>

FOUNDATION_EXPORT NSString * const YTKWKUIDelegateDidChangeNotification;

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (YTKSwizzling)

- (void)ytk_setUIDelegate:(id<WKUIDelegate>)UIDelegate;

@end

NS_ASSUME_NONNULL_END
