//
//  YTKWebInterface.h
//  YTKJsBridge
//
//  Created by lihaichun on 2019/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YTKWebInterface <NSObject>

@property (nonatomic, weak, nullable) UIView *webView;

// webview 执行js脚本接口
- (void)evaluateJavaScript:(NSString *)js;

@end

NS_ASSUME_NONNULL_END
