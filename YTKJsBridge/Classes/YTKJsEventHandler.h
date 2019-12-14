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

@protocol YTKWebInterface;
@protocol YTKJsEventDelegate;

@interface YTKJsEventHandler : NSObject <YTKJsEventHandler, YTKJsEventDelegate>

@property (nonatomic, weak, nullable) id<YTKWebInterface> webInterface;

/** 向JS注入事件监听处理callback */
- (void)listenEvent:(NSString *)event callback:(YTKEventCallback)callback;

/** 移除事件监听 */
- (void)unlistenEvent:(NSString *)event;

/** 监听event */
- (void)addListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event;

- (void)removeListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event;

/** native发起事件通知给JS */
- (void)emit:(NSString *)event argument:(nullable NSArray *)argument;

- (void)setDebugMode:(BOOL)debug;

@end

NS_ASSUME_NONNULL_END
