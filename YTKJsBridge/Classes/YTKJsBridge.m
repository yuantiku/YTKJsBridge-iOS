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

@interface YTKJsBridge () <YTKWebViewDelegate>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "Wdeprecated-declarations"
@property (nonatomic, strong) UIWebView *webView;
#pragma clang diagnostic pop

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<YTKJsCommandHandler>> *pendingJsHandlers;

@property (nonatomic, strong) YTKJsCommandManager *manager;

@end

@implementation YTKJsBridge

+ (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(NSArray *)argument
                   errorMessage:(NSString *)errorMessage
                      inWebView:(UIWebView *)webView {
    if (webView == nil || NO == [commandName isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSMutableArray *args = [NSMutableArray array];
    // put error message
    if (errorMessage != nil) {
        [args addObject:errorMessage];
    } else {
        [args addObject:[NSNull null]];
    }
    // put result
    if (argument.count > 0) {
        [args addObjectsFromArray:argument];
    }

    NSString *js = [NSString stringWithFormat:@"%@('%@')", commandName, [self jsonString:args]];
    return [webView stringByEvaluatingJavaScriptFromString:js];
}

+ (NSString *)jsonString:(NSArray *)array {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    if (error) {
        NSLog(@"ERROR, faild to get json data");
        return nil;
    }
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return json;
}

#pragma mark - Public Methods

- (instancetype)initWithWebView:(UIWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
        _pendingJsHandlers = @{}.mutableCopy;
        webView.ytk_delegate = self;
    }
    return self;
}

- (void)addJsCommandHandler:(id<YTKJsCommandHandler>)handler forCommandName:(NSString *)commandName {
    [self.manager addJsCommandHandler:handler forCommandName:commandName];
}

- (void)removeJsCommandHandlerForCommandName:(NSString *)commandName {
    [self.manager removeJsCommandHandlerForCommandName:commandName];
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
}

#pragma mark - Getter

- (YTKJsCommandManager *)manager {
    if (nil == _manager) {
        _manager = [YTKJsCommandManager new];
    }
    return _manager;
}

@end
