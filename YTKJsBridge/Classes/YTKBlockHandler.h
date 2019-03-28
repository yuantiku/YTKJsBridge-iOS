//
//  YTKBlockHandler.h
//  YTKJsBridge
//
//  Created by lihaichun on 2019/2/22.
//

#import <Foundation/Foundation.h>
#import "YTKJsBlockHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKBlockHandler : NSObject

/** 判断是否可以处理js方法调用 */
- (BOOL)canHandleSyncMethod:(NSString *)method;

- (BOOL)canHandleVoidSyncMethod:(NSString *)method;

- (BOOL)canHandleAsyncMethod:(NSString *)method;

/** 添加js方法实现block */
- (void)addSyncMethod:(NSString *)method
                block:(YTKSyncCallback)block;

- (void)addVoidSyncMethod:(NSString *)method
                    block:(YTKVoidSyncCallback)block;

- (void)addAsyncMethod:(NSString *)method
                 block:(YTKAsyncCallback)block;

/** 删除js方法对应的实现block记录 */
- (void)removeMethodForNamespace:(NSString *)namespace;

- (void)removeMethod:(NSString *)method;

- (void)removeSyncMethod:(NSString *)method;

- (void)removeVoidSyncMethod:(NSString *)method;

- (void)removeAsyncMethod:(NSString *)method;

/** 调用js主任方法实现block */
- (id)performSyncMethod:(NSString *)method
               argments:(NSArray *)arguments;

- (void)performVoidSyncMethod:(NSString *)method
                    arguments:(NSArray *)arguments;

- (void)performAsyncMethod:(NSString *)method
                 arguments:(NSArray *)argumets
                  callback:(YTKDataCallback)callback;

@end

NS_ASSUME_NONNULL_END
