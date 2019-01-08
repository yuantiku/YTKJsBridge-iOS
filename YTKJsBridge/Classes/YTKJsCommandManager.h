//
//  YTKJsCommandManager.h
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import <Foundation/Foundation.h>
#import "YTKJsCommandHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKJsCommandManager : NSObject <YTKJsCommandHandler>


- (void)addJsCommandHandlers:(NSArray<id> *)handlers forNamespace:(nullable NSString *)namespace;

- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace;

- (NSArray<id> *)handlersForNamespace:(nullable NSString *)namespace;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
