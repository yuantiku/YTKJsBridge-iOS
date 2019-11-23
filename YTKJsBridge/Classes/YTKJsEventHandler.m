//
//  YTKJsEventHandler.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/1/15.
//

#import "YTKJsEventHandler.h"
#import "YTKJsCommand.h"
#import "YTKJsUtils.h"
#import "YTKWebInterface.h"
#import "YTKWebBasedUIWebView.h"
#import "YTKWebBasedWKWebView.h"
#import <WebKit/WebKit.h>

@interface YTKJsEventHandler ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, YTKEventCallback> *eventHandlers;

@property (nonatomic, strong) NSMapTable<NSString *, NSHashTable *> *eventListeners;

@property (nonatomic) BOOL isDebug;

@property (nonatomic, strong) id<YTKWebInterface> webInterface;

@end

@implementation YTKJsEventHandler

@synthesize webView;

- (void)setWebView:(UIView *)view {
    webView = view;
    if ([view isKindOfClass:[UIWebView class]]) {
        self.webInterface = [[YTKWebBasedUIWebView alloc] initWithWebView:(UIWebView *)view];
    } else if ([view isKindOfClass:[WKWebView class]]) {
        self.webInterface = [[YTKWebBasedWKWebView alloc] initWithWebView:(WKWebView *)view];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventHandlers = [NSMutableDictionary dictionary];
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
    if (![event isKindOfClass:[NSString class]] || event.length == 0 || !callback) {
        return;
    }

    [self.eventHandlers setObject:callback forKey:event];
}

- (void)unlistenEvent:(NSString *)event {
    if (![event isKindOfClass:[NSString class]] || event.length == 0) {
        return;
    }

    [self.eventHandlers removeObjectForKey:event];
}

- (void)addListener:(id<YTKJsEventListener>)listener forEvent:(NSString *)event {
    if (![event isKindOfClass:[NSString class]] || event.length == 0 || !listener || ![listener conformsToProtocol:@protocol(YTKJsEventListener)]) {
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
    if (![event isKindOfClass:[NSString class]] || event.length == 0 || !listener || ![listener conformsToProtocol:@protocol(YTKJsEventListener)]) {
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
    if (![event isKindOfClass:[NSString class]]) {
        return;
    }
    NSString *json = [YTKJsUtils objToJsonString:@{@"event" : event, @"arg" : argument ?: @[]}];
    NSString *js = [NSString stringWithFormat:@"window.dispatchNativeEvent(%@)", json];
    if (self.isDebug) {
        NSLog(@"### send native event: %@", js);
    }
    [self.webInterface evaluateJavaScript:js];
}

- (void)setDebugMode:(BOOL)debug {
    _isDebug = debug;
}

#pragma mark - YTKJsEventHandler

- (void)handleJsEvent:(YTKJsEvent *)event inWebView:(UIView *)webView {
    if (![event.event isKindOfClass:[NSString class]]) {
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
        if (![obj respondsToSelector:@selector(handleJsEventWithArgument:)]) {
            return;
        }
        founded = YES;
        [obj handleJsEventWithArgument:event.arg];
    }];
    if (!founded && self.isDebug) {
        NSString *error = [NSString stringWithFormat:@"Error! \n event %@ is not invoked, since there is not a handler for it",event.event];
        NSLog(@"%@", error);
    }
}
@end
