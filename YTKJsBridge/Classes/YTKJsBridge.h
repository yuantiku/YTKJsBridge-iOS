//
//  YTKJsBridge.h
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YTKJsCommandHandler;

@interface YTKJsBridge : NSObject

/** 调用js commandName方法 */
+ (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(nullable NSArray *)argument
                   errorMessage:(nullable NSString *)errorMessage
                      inWebView:(UIWebView *)webView;

- (instancetype)initWithWebView:(UIWebView *)webView;

/** 注入js方法实现类handler */
- (void)addJsCommandHandler:(id<YTKJsCommandHandler>)handler;

/** 移除已经注入的js方法commandName */
- (void)removeJsCommandHandlerForCommandName:(NSString *)commandName;

@end

NS_ASSUME_NONNULL_END
