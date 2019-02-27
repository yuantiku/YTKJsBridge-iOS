//
//  YTKJsEventHandler.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/1/15.
//

#import "YTKJsEventHandler.h"
#import "YTKJsCommand.h"
#import "YTKJsUtils.h"

@interface YTKJsEventHandler ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, YTKEventCallback> *eventHandlers;

@property (nonatomic, strong) NSMapTable<NSString *, NSHashTable *> *eventListeners;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsEventHandler

@synthesize webView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventHandlers = @{}.mutableCopy;
        _eventListeners = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)dealloc {
    if (self.isDebug) {
        NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
}

#pragma mark - Public Methods

- (void)listenEvent:(NSString *)event callback:(YTKEventCallback)callback {
    if (NO == [event isKindOfClass:[NSString class]] || event.length == 0 || nil == callback) {
        return;
    }

    [self.eventHandlers setObject:callback forKey:event];
}

- (void)unlistenEvent:(NSString *)event {
    if (NO == [event isKindOfClass:[NSString class]] || event.length == 0) {
        return;
    }

    [self.eventHandlers removeObjectForKey:event];
}

- (void)addListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event {
    if (NO == [event isKindOfClass:[NSString class]] || event.length == 0 || !listener || NO == [listener conformsToProtocol:@protocol(YTKJsEventListener)]) {
        return;
    }
    NSHashTable *listeners = [self.eventListeners objectForKey:event];
    if (!listeners) {
        listeners = [NSHashTable weakObjectsHashTable];
    }
    [listeners addObject:listener];
    [self.eventListeners setObject:listeners forKey:event];
}

- (void)removeListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event {
    if (NO == [event isKindOfClass:[NSString class]] || event.length == 0 || !listener || NO == [listener conformsToProtocol:@protocol(YTKJsEventListener)]) {
        return;
    }
    NSHashTable *listeners = [self.eventListeners objectForKey:event];
    if (!listeners) {
        return;
    }
    [listeners removeObject:listener];
    [self.eventListeners setObject:listeners forKey:event];
}

- (void)emit:(NSString *)event argument:(NSArray *)argument {
    if (NO == [event isKindOfClass:[NSString class]]) {
        return;
    }
    NSString *json = [YTKJsUtils objToJsonString:@{@"event" : event, @"arg" : argument ?: @[]}];
    NSString *js = [NSString stringWithFormat:@"window.dispatchNativeEvent(%@)", json];
    if (self.isDebug) {
        NSLog(@"### send native event: %@", js);
    }
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setDebugMode:(BOOL)debug {
    _isDebug = debug;
}

#pragma mark - YTKJsEventHandler

- (void)handleJsEvent:(YTKJsEvent *)event inWebView:(UIWebView *)webView {
    if (NO == [event.event isKindOfClass:[NSString class]]) {
        return;
    }
    if (self.isDebug) {
        NSLog(@"### receive event:%@, arg:%@", event.event, event.arg);
    }

    YTKEventCallback eventHandler = [self.eventHandlers objectForKey:event.event];
    __block BOOL founded = NO;
    if (eventHandler) {
        founded = YES;
        eventHandler(event.arg);
    }
    NSHashTable *listeners = [self.eventListeners objectForKey:event.event];
    [listeners.allObjects enumerateObjectsUsingBlock:^(id<YTKJsEventListener>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(handleJsEventWithArgument:)]) {
            founded = YES;
            [obj handleJsEventWithArgument:event.arg];
        }
    }];
    if (NO == founded && self.isDebug) {
        NSString *error = [NSString stringWithFormat:@"Error! \n event %@ is not invoked, since there is not a handler for it",event.event];
        NSLog(@"%@", error);
    }
}
@end
