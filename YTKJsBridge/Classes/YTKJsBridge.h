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

typedef void (^YTKDataCallback) (NSError * __nullable error, id __nullable data);
typedef void (^YTKAsyncCallback) (NSDictionary * __nullable argument, YTKDataCallback block);
typedef id (^YTKSyncCallback) (NSDictionary * __nullable argument);
typedef void (^YTKEventCallback) (id __nullable argument);

NS_ASSUME_NONNULL_BEGIN

@protocol YTKJsCommandHandler;
@protocol YTKJsEventListener;

@interface YTKJsBridge : NSObject

- (instancetype)initWithWebView:(UIWebView *)webView;

/** 注入js方法实现类数组handlers，这些handlers同属于同一个命名空间namespace */
- (void)addJsCommandHandlers:(NSArray *)handlers namespace:(nullable NSString *)namespace;

/** 移除已经注入的js方法方法命名空间namespace的实现类数组 */
- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace;

/** 注入js同步方法commandName，方法实现block */
- (void)addSyncJsCommandName:(NSString *)commandName handler:(YTKSyncCallback)handler;
- (void)addSyncJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace handler:(YTKSyncCallback)handler;

/** 注入js异步方法commandName，方法实现block */
- (void)addAsyncJsCommandName:(NSString *)commandName handler:(YTKAsyncCallback)handler;
- (void)addAsyncJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace handler:(YTKAsyncCallback)handler;

/** 移除命名空间namespace下的注入的js commandName方法 */
- (void)removeJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace;

/** 调用js commandName方法 */
- (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(NSArray *)argument;

/** 注册js事件监听处理block */
- (void)listenEvent:(NSString *)event callback:(YTKEventCallback)callback;

/** 移除事件监听 */
- (void)unlistenEvent:(NSString *)event;

- (void)addListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event;

- (void)removeListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event;

/** native发起事件通知给JS */
- (void)emit:(NSString *)event argument:(nullable id)argument;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
