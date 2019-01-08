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
#import "YTKJsUtils.h"

@interface YTKJsBridge () <YTKWebViewDelegate>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "Wdeprecated-declarations"
@property (nonatomic, strong) UIWebView *webView;
#pragma clang diagnostic pop

@property (nonatomic, strong) YTKJsCommandManager *manager;

@property (nonatomic) UInt64 callId;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsBridge

#pragma mark - Public Methods

- (instancetype)initWithWebView:(UIWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
        webView.ytk_delegate = self;
    }
    return self;
}

- (void)addJsCommandHandlers:(NSArray *)handlers namespace:(nullable NSString *)namespace {
    [self.manager addJsCommandHandlers:handlers forNamespace:namespace];
}

- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace {
    [self.manager removeJsCommandHandlerForNamespace:namespace];
}

- (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(NSArray *)argument {
    if (self.webView == nil || NO == [commandName isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSString *json = [YTKJsUtils objToJsonString:@{@"methodName" : commandName, @"args" : argument, @"callId" : @(self.callId ++)}];
    NSString *js = [NSString stringWithFormat:@"window.dispatchNativeCall(%@)", json];
    if (self.isDebug) {
        NSLog(@"### native call: %@", js);
    }
    return [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setDebugMode:(BOOL)debug {
    self.isDebug = debug;
    [self.manager setDebugMode:debug];
}

#pragma mark - Utils

- (void)addJsCommandHandler:(id<YTKJsCommandHandler>)handler forCommandName:(NSString *)commandName toContext:(JSContext *)context {
    if (nil == handler || NO == [commandName isKindOfClass:[NSString class]] || nil == context) {
        return;
    }
    context[commandName] = ^(JSValue *data) {
        handler.webView = self.webView;
        if ([handler respondsToSelector:@selector(handleJsCommand:inWebView:)]) {
            YTKJsCommand *commamd = [[YTKJsCommand alloc] initWithDictionary:[data toDictionary]];
            [handler handleJsCommand:commamd inWebView:self.webView];
        }
    };
}

#pragma mark - YTKWebViewDelegate

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)context {
    /** 向JS注入全局YTKJsBridge函数 */
    [self addJsCommandHandler:self.manager forCommandName:self.class.description toContext:context];
    [self addJsCommandHandler:self.manager forCommandName:@"makeCallback" toContext:context];
}

#pragma mark - Getter

- (YTKJsCommandManager *)manager {
    if (nil == _manager) {
        _manager = [YTKJsCommandManager new];
    }
    return _manager;
}

@end
