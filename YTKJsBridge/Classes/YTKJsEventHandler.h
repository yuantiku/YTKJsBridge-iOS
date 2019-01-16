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

/** 向JS注入事件监听处理callback */
- (void)listenEvent:(NSString *)event callback:(YTKEventCallback)callback;

/** 移除事件监听 */
- (void)unlistenEvent:(NSString *)event;

/** 监听event */
- (void)addListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event;

- (void)removeListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event;

/** native发起事件通知给JS */
- (void)emit:(NSString *)event argument:(nullable id)argument;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
