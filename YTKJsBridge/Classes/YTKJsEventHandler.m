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

@property (nonatomic, strong) NSMutableDictionary<NSString *, YTKEventBlock> *eventHandlers;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsEventHandler

@synthesize webView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventHandlers = @{}.mutableCopy;
    }
    return self;
}

- (void)dealloc {
    if (self.isDebug) {
        NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
}

#pragma mark - Public Methods

- (void)listenJsEvent:(NSString *)event handler:(YTKEventBlock)handler {
    if (NO == [event isKindOfClass:[NSString class]] || event.length == 0 || nil == handler) {
        return;
    }

    [self.eventHandlers setObject:handler forKey:event];
}

- (void)unlistenJsEvent:(NSString *)event {
    if (NO == [event isKindOfClass:[NSString class]] || event.length == 0) {
        return;
    }

    [self.eventHandlers  removeObjectForKey:event];
}

- (void)notifyEvent:(NSString *)event argument:(nullable id)argument {
    if (NO == [event isKindOfClass:[NSString class]]) {
        return;
    }
    NSString *json = [YTKJsUtils objToJsonString:@{@"event" : event, @"arg" : argument ?: @""}];
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

    YTKEventBlock eventHandler = [self.eventHandlers objectForKey:event.event];
    if (eventHandler) {
        eventHandler(event.arg);
    } else {
        if (self.isDebug) {
            NSString *error = [NSString stringWithFormat:@"Error! \n event %@ is not invoked, since there is not a handler for it",event.event];
            NSLog(@"%@", error);
        }
    }
}
@end
