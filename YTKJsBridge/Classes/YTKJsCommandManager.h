//
//  YTKJsCommandManager.h
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import <Foundation/Foundation.h>
#import "YTKJsCommandHandler.h"
#import "YTKJsBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKJsCommandManager : NSObject <YTKJsCommandHandler>

/** 向JS注入命名空间namespace的处理方法类对象数组 */
- (void)addJsCommandHandlers:(NSArray<id> *)handlers forNamespace:(nullable NSString *)namespace;

/** 向JS注入同步处理block */
- (void)addSyncJsCommandName:(NSString *)commandName handler:(YTKSyncBlock)handler;

- (void)addSyncJsCommandName:(NSString *)commandName
                   namespace:(nullable NSString *)namespace
                     handler:(YTKSyncBlock)handler;

/** 向JS注入异步处理block */
- (void)addAsyncJsCommandName:(NSString *)commandName handler:(YTKAsyncBlock)handler;

- (void)addAsyncJsCommandName:(NSString *)commandName
                    namespace:(nullable NSString *)namespace
                      handler:(YTKAsyncBlock)handler;

/** 移除命名空间namespace对应的方法类数组 */
- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace;

/** 移除命名空间namespace下的commandName方法 */
- (void)removeJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace;

/** 调用JS方法 */
- (nullable NSString *)callJsWithDictionary:(NSDictionary *)dictionary;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
