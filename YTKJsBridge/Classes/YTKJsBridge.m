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

@interface YTKJsBridge () <YTKWebViewDelegate>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "Wdeprecated-declarations"
@property (nonatomic, strong) UIWebView *webView;
#pragma clang diagnostic pop

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<YTKJsCommandHandler>> *pendingJsHandlers;

@end

@implementation YTKJsBridge

+ (NSString *)callJsCommandName:(NSString *)commandName
                       argument:(NSArray *)argument
                   errorMessage:(NSString *)errorMessage
                      inWebView:(UIWebView *)webView {
    if (webView == nil || commandName == nil) {
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
    if (nil == handler || NO == [commandName isKindOfClass:[NSString class]]) {
        NSLog(@"ERROR, invalid parameter");
        return;
    }
    if (self.webView.ytk_javaScriptContext) {
        [self addJsCommandHandler:handler forCommandName:commandName toContext:self.webView.ytk_javaScriptContext];
    } else {
        [self.pendingJsHandlers setObject:handler forKey:commandName];
    }
}

- (void)addJsCommandHandler:(id<YTKJsCommandHandler>)handler forCommandName:(NSString *)commandName toContext:(JSContext *)context {
    if (nil == handler || NO == [commandName isKindOfClass:[NSString class]] || nil == context) {
        return;
    }
    context[commandName] = ^(JSValue *data) {
        handler.webView = self.webView;
        if ([handler respondsToSelector:@selector(handleJSCommand:inWebView:)]) {
            YTKJsCommand *commamd = [[YTKJsCommand alloc] initWithDictionary:[data toObjectOfClass:[YTKJsCommand class]]];
            [handler handleJSCommand:commamd inWebView:self.webView];
        }
    };
}

#pragma mark - YTKWebViewDelegate

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)context {
    [self.pendingJsHandlers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<YTKJsCommandHandler>  _Nonnull obj, BOOL * _Nonnull stop) {
        [self addJsCommandHandler:obj forCommandName:key toContext:context];
    }];
}

@end
