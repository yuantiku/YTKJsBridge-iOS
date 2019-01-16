//
//  YTKJsEventHandler.h
//  YTKJsBridge
//
//  Created by lihaichun on 2019/1/15.
//

#import <Foundation/Foundation.h>
#import "YTKJsCommandHandler.h"
#import "YTKJsBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKJsEventHandler : NSObject <YTKJsEventHandler>

/** 向JS注入事件监听处理handler */
- (void)listenJsEvent:(NSString *)event handler:(YTKEventBlock)handler;

/** 移除事件监听 */
- (void)unlistenJsEvent:(NSString *)event;

/** native发起事件通知给JS */
- (void)notifyEvent:(NSString *)event argument:(nullable id)argument;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
