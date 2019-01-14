//
//  YTKJsBridge.h
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YTKJsCommand;

typedef void (^YTKDataBlock) (NSError * __nullable error, id __nullable data);
typedef void (^YTKAsyncBlock) (NSDictionary * __nullable arguments, YTKDataBlock block);
typedef id (^YTKSyncBlock) (NSDictionary * __nullable arguments);
typedef void (^YTKEventBlock) (NSDictionary * __nullable arguments);

NS_ASSUME_NONNULL_BEGIN

@protocol YTKJsCommandHandler;

@interface YTKJsBridge : NSObject

- (instancetype)initWithWebView:(UIWebView *)webView;

/** 注入js方法实现类数组handlers，这些handlers同属于同一个命名空间namespace */
- (void)addJsCommandHandlers:(NSArray *)handlers namespace:(nullable NSString *)namespace;

/** 移除已经注入的js方法方法命名空间namespace的实现类数组 */
- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace;

/** 注入js同步方法commandName，方法实现block */
- (void)addSyncJsCommandName:(NSString *)commandName handler:(YTKSyncBlock)handler;
- (void)addSyncJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace handler:(YTKSyncBlock)handler;

/** 注入js异步方法commandName，方法实现block */
- (void)addAsyncJsCommandName:(NSString *)commandName handler:(YTKAsyncBlock)handler;
- (void)addAsyncJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace handler:(YTKAsyncBlock)handler;

/** 移除命名空间namespace下的注入的js commandName方法 */
- (void)removeJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace;

/** 注册js事件监听处理block */
- (void)listenJsEvent:(NSString *)event handler:(YTKEventBlock)handler;

- (void)unlistenJsEvent:(NSString *)event;

/** 调用js commandName方法 */
- (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(NSArray *)argument;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
