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

@protocol YTKWebInterface;
@protocol YTKJsCommandDelegate;

@interface YTKJsCommandManager : NSObject <YTKJsCommandHandler, YTKJsCommandDelegate>

@property (nonatomic, weak, nullable) id<YTKWebInterface> webInterface;

/** 向JS注入命名空间namespace的处理方法类对象数组 */
- (void)addJsCommandHandlers:(NSArray<id> *)handlers
                forNamespace:(nullable NSString *)namespace;

/** 向JS注入带有返回值的同步处理block */
- (void)addSyncJsCommandName:(NSString *)commandName
                    impBlock:(YTKSyncCallback)impBlock;

- (void)addSyncJsCommandName:(NSString *)commandName
                   namespace:(nullable NSString *)namespace
                    impBlock:(YTKSyncCallback)impBlock;

/** 向JS注入无返回值的同步处理block */
- (void)addVoidSyncJsCommandName:(NSString *)commandName
                        impBlock:(YTKVoidSyncCallback)impBlock;

- (void)addVoidSyncJsCommandName:(NSString *)commandName
                       namespace:(nullable NSString *)namespace
                        impBlock:(YTKVoidSyncCallback)impBlock;

/** 向JS注入异步处理block */
- (void)addAsyncJsCommandName:(NSString *)commandName
                     impBlock:(YTKAsyncCallback)impBlock;

- (void)addAsyncJsCommandName:(NSString *)commandName
                    namespace:(nullable NSString *)namespace
                     impBlock:(YTKAsyncCallback)impBlock;

/** 移除命名空间namespace对应的所有方法 */
- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace;

/** 移除命名空间namespace下的commandName方法 */
- (void)removeJsCommandName:(NSString *)commandName
                  namespace:(nullable NSString *)namespace;

/** 调用JS方法 */
- (void)callJsWithDictionary:(NSDictionary *)dictionary;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
