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

- (void)addJsCommandHandler:(id<YTKJsCommandHandler>)handler forCommandName:(NSString *)commandName;

- (void)removeJsCommandHandlerForCommandName:(NSString *)commandName;

- (id<YTKJsCommandHandler>)handlerForCommandName:(NSString *)commandName;

@end

NS_ASSUME_NONNULL_END
