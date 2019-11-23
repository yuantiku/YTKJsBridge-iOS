//
//  YTKWebBasedUIWebView.h
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/23.
//

#import <Foundation/Foundation.h>
#import "YTKWebInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKWebBasedUIWebView : NSObject <YTKWebInterface>

- (instancetype)initWithWebView:(UIWebView *)webview;

@end

NS_ASSUME_NONNULL_END
