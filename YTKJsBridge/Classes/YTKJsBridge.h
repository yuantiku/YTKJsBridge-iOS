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

- (instancetype)initWithWebView:(UIWebView *)webView;

/** 注入js方法实现类数组handlers，这些handlers同属于同一个命名空间namespace */
- (void)addJsCommandHandlers:(NSArray *)handlers namespace:(nullable NSString *)namespace;

/** 移除已经注入的js方法方法命名空间namespace的实现类数组 */
- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace;

/** 调用js commandName方法 */
- (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(NSArray *)argument;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
