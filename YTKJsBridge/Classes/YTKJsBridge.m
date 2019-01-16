//
//  YTKJsBridge.m
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import "YTKJsBridge.h"
#import "UIWebView+JavaScriptContext.h"
#import "YTKJsCommandHandler.h"
#import "YTKJsCommand.h"
#import "YTKJsCommandManager.h"
#import "YTKJsEventHandler.h"
#import "YTKJsUtils.h"

@interface YTKJsBridge () <YTKWebViewDelegate>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "Wdeprecated-declarations"
@property (nonatomic, weak) UIWebView *webView;
#pragma clang diagnostic pop

/** 方法处理对象 */
@property (nonatomic, strong) YTKJsCommandManager *manager;

/** 事件处理对象 */
@property (nonatomic, strong) YTKJsEventHandler *eventHandler;

@property (nonatomic) UInt64 callId;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsBridge

- (void)dealloc {
    if (self.isDebug) {
        NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
}

#pragma mark - Public Methods

- (instancetype)initWithWebView:(UIWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
        __weak typeof(self) weakSelf = self;
        webView.ytk_delegate = weakSelf;
    }
    return self;
}

#pragma mark - Public Methods

/** command related */
- (void)addJsCommandHandlers:(NSArray *)handlers namespace:(nullable NSString *)namespace {
    [self.manager addJsCommandHandlers:handlers forNamespace:namespace];
}

- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace {
    [self.manager removeJsCommandHandlerForNamespace:namespace];
}

- (void)addSyncJsCommandName:(NSString *)commandName handler:(YTKSyncBlock)handler {
    [self.manager addSyncJsCommandName:commandName handler:handler];
}

- (void)addSyncJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace handler:(YTKSyncBlock)handler {
    [self.manager addSyncJsCommandName:commandName namespace:namespace handler:handler];
}

- (void)addAsyncJsCommandName:(NSString *)commandName handler:(YTKAsyncBlock)handler {
    [self.manager addAsyncJsCommandName:commandName handler:handler];
}

- (void)addAsyncJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace handler:(YTKAsyncBlock)handler {
    [self.manager addAsyncJsCommandName:commandName namespace:namespace handler:handler];
}

- (void)removeJsCommandName:(NSString *)commandName namespace:(nullable NSString *)namespace {
    [self.manager removeJsCommandName:commandName namespace:namespace];
}

- (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(NSArray *)argument {
    if (NO == [commandName isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSDictionary *dict = @{@"methodName" : commandName, @"args" : argument, @"callId" : @(self.callId ++)};
    return [self.manager callJsWithDictionary:dict];
}

/** event related */
- (void)listenJsEvent:(NSString *)event handler:(YTKEventBlock)handler {
    [self.eventHandler listenJsEvent:event handler:handler];
}

- (void)unlistenJsEvent:(NSString *)event {
    [self.eventHandler unlistenJsEvent:event];
}

- (void)notifyEvent:(NSString *)event argument:(id)argument {
    [self.eventHandler notifyEvent:event argument:argument];
}

- (void)setDebugMode:(BOOL)debug {
    self.isDebug = debug;
    [self.manager setDebugMode:debug];
    [self.eventHandler setDebugMode:debug];
}

#pragma mark - Utils

- (void)addJsCommandHandler:(id<YTKJsCommandHandler>)handler forCommandName:(NSString *)commandName toContext:(JSContext *)context {
    if (nil == handler || NO == [commandName isKindOfClass:[NSString class]] || nil == context) {
        return;
    }
    handler.webView = self.webView;
    __weak typeof(self) weakSelf = self;
    context[commandName] = ^id(JSValue *data) {
        if (nil == weakSelf) {
            return nil;
        }
        __strong typeof(self) strongSelf = weakSelf;
        JSValue *ret = nil;
        if ([handler respondsToSelector:@selector(handleJsCommand:inWebView:)]) {
            YTKJsCommand *commamd = [[YTKJsCommand alloc] initWithDictionary:[data toDictionary]];
            NSDictionary *result = [handler handleJsCommand:commamd inWebView:strongSelf.webView];
            if (result) {
                ret = [JSValue valueWithObject:result inContext:[JSContext currentContext]];
            }
        }
        return ret;
    };
}

- (void)addJsEventHandler:(id<YTKJsEventHandler>)handler forEvent:(NSString *)event toContext:(JSContext *)context {
    if (nil == handler || NO == [event isKindOfClass:[NSString class]] || nil == context) {
        return;
    }
    handler.webView = self.webView;
    __weak typeof(self) weakSelf = self;
    context[event] = ^(JSValue *data) {
        if (nil == weakSelf) {
            return;
        }
        __strong typeof(self) strongSelf = weakSelf;
        handler.webView = strongSelf.webView;
        if ([handler respondsToSelector:@selector(handleJsEvent:inWebView:)]) {
            YTKJsEvent *event = [[YTKJsEvent alloc] initWithDictionary:[data toDictionary]];
            [handler handleJsEvent:event inWebView:strongSelf.webView];
        }
    };
}

#pragma mark - YTKWebViewDelegate

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)context {
    /** 向JS注入全局YTKJsBridge函数 */
    __weak typeof(self) weakSelf = self;
    [self addJsCommandHandler:weakSelf.manager forCommandName:self.class.description toContext:context];
    [self addJsCommandHandler:weakSelf.manager forCommandName:@"makeCallback" toContext:context];
    [self addJsEventHandler:weakSelf.eventHandler forEvent:@"sendEvent" toContext:context];
}

#pragma mark - Getter

- (YTKJsCommandManager *)manager {
    if (nil == _manager) {
        _manager = [YTKJsCommandManager new];
    }
    return _manager;
}

- (YTKJsEventHandler *)eventHandler {
    if (nil == _eventHandler) {
        _eventHandler = [YTKJsEventHandler new];
    }
    return _eventHandler;
}

@end
