//
//  YTKJsCommandManager.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import "YTKJsCommandManager.h"
#import "YTKJsCommandHandler.h"
#import "YTKJsBridge.h"

@interface YTKJsCommandManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<YTKJsCommandHandler>> *commandHandlers;

@end

@implementation YTKJsCommandManager

@synthesize webView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _commandHandlers = @{}.mutableCopy;
    }
    return self;
}

- (void)addJsCommandHandler:(id<YTKJsCommandHandler>)handler forCommandName:(NSString *)commandName {
    if (NO == [commandName isKindOfClass:[NSString class]] || nil == handler) {
        NSLog(@"ERROR, invalid add parameter");
        return;
    }

    [self.commandHandlers setObject:handler forKey:commandName];
}

- (void)removeJsCommandHandlerForCommandName:(NSString *)commandName {
    if (NO == [commandName isKindOfClass:[NSString class]]) {
        NSLog(@"ERROR, invalid remove parameter");
        return;
    }

    [self.commandHandlers removeObjectForKey:commandName];
}

- (id<YTKJsCommandHandler>)handlerForCommandName:(NSString *)commandName {
    if (NO == [commandName isKindOfClass:[NSString class]]) {
        NSLog(@"ERROR, invalid get parameter");
        return nil;
    }

    return [self.commandHandlers objectForKey:commandName];
}

#pragma mark - YTKJsCommandHandler

- (void)handleJsCommand:(YTKJsCommand *)command inWebView:(UIWebView *)webView {
    if (NO ==[command.name isKindOfClass:[NSString class]]) {
        return;
    }
    id<YTKJsCommandHandler> handler = [self.commandHandlers objectForKey:command.name];
    if ([handler respondsToSelector:@selector(handleJsCommand:inWebView:)]) {
        handler.webView = webView;
        [handler handleJsCommand:command inWebView:webView];
        if ([handler respondsToSelector:@selector(shouldCallDefaultJsCallback)]) {
            if ([handler shouldCallDefaultJsCallback]) {
                [YTKJsBridge callJsCommandName:command.callback argument:@[] errorMessage:nil inWebView:webView];
            }
        } else {
            [YTKJsBridge callJsCommandName:command.callback argument:@[] errorMessage:nil inWebView:webView];
        }
    } else {
        [YTKJsBridge callJsCommandName:command.callback argument:@[] errorMessage:@"Error, handler not founded" inWebView:webView];
    }
}

- (BOOL)shouldCallDefaultJsCallback {
    return NO;
}

@end
