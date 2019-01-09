//
//  YTKJsCommandManager.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import "YTKJsCommandManager.h"
#import "YTKJsCommandHandler.h"
#import "YTKJsBridge.h"
#import "YTKJsUtils.h"
#import <objc/message.h>

@interface YTKJsCommandManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<id> *> *commandHandlers;

@property (nonatomic, strong) NSString *jsCache;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsCommandManager

@synthesize webView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _commandHandlers = @{}.mutableCopy;
        _jsCache = @"";
        _isDebug = NO;
    }
    return self;
}

- (void)dealloc {
    if (self.isDebug) {
        NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
}

- (void)addJsCommandHandlers:(NSArray<id> *)handlers forNamespace:(nullable NSString *)namespace {
    if (NO == [handlers isKindOfClass:NSArray.class] || handlers.count == 0) {
        if (self.isDebug) {
            NSLog(@"ERROR, invalid add parameter");
        }
        return;
    }
    if (namespace == nil) {
        namespace = @"";
    }

    NSMutableArray *arr = [self.commandHandlers objectForKey:namespace].mutableCopy;
    if (arr) {
        [arr addObjectsFromArray:handlers];
    } else {
        arr = handlers.mutableCopy;
    }
    [self.commandHandlers setObject:handlers forKey:namespace];
}

- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace {
    if (namespace == nil) {
        namespace = @"";
    }

    [self.commandHandlers removeObjectForKey:namespace];
}

- (NSArray<id> *)handlersForNamespace:(nullable NSString *)namespace {
    if (namespace == nil) {
        namespace = @"";
    }

    return [self.commandHandlers objectForKey:namespace];
}

- (void)setDebugMode:(BOOL)debug {
    _isDebug = debug;
}

#pragma mark - YTKJsCommandHandler

- (void)handleJsCommand:(YTKJsCommand *)command inWebView:(UIWebView *)webView {
    if (NO ==[command.methodName isKindOfClass:[NSString class]] || [command.methodName isEqualToString:@"makeCallback"]) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    [weakSelf callCommand:command];
}

#pragma mark - Utils

- (void)callCommand:(YTKJsCommand *)command {
    if (self.isDebug) {
        NSLog(@"### receive methodName:%@, args:%@, callId:%@", command.methodName, command.args, command.callId);
    }
    NSString *commandName = command.methodName;
    NSDictionary *args = command.args;
    NSString *callId = command.callId;
    NSArray *nameStr = [YTKJsUtils parseNamespace:[commandName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    NSArray<id> *handlers = [self handlersForNamespace:nameStr[0]];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{@"code" : @-1, @"ret" : @""}];

    if (nil == handlers || handlers.count == 0) {
        if (self.isDebug) {
            NSLog(@"js call not implemented method");
        }
        NSMutableDictionary *dict = result.mutableCopy;
        [dict setObject:callId ?: @"" forKey:@"callId"];
        [self evaluatingDictionary:dict];
        return;
    }
    NSString *error = [NSString stringWithFormat:@"Error! \n Method %@ is not invoked, since there is not a implementation for it",commandName];
    commandName = nameStr[1];
    if (NO == [args isKindOfClass:[NSDictionary class]] || args == nil) {
        args = @{};
    }

    __block BOOL founded = NO;
    [handlers enumerateObjectsUsingBlock:^(id  _Nonnull handler, NSUInteger idx, BOOL * _Nonnull stop) {
        /** callId为-1代表是同步调用，否则为异步调用 */
        BOOL isAsync = callId && NO == [callId isEqualToString:@"-1"];
        NSInteger argCount = isAsync ? 2 : 1;
        NSString *method = [YTKJsUtils methodByNameArg:argCount selName:commandName class:[handler class]];
        SEL sel = NSSelectorFromString(method);
        if ([handler respondsToSelector:sel]) {
            founded = YES;
            if (callId && NO == [callId isEqualToString:@"-1"]) {
                /** async call */
                __weak typeof(self) weakSelf = self;
                void(^completionHandler)(NSError *, id) = ^(NSError *error, id value) {
                    result[@"code"] = @0;
                    if (value != nil) {
                        result[@"ret"] = value;
                    }
                    NSMutableDictionary *dict = result.mutableCopy;
                    [dict setObject:callId forKey:@"callId"];
                    NSString *json = [YTKJsUtils objToJsonString:dict];
                    NSString *js = [NSString stringWithFormat:@"window.dispatchCallbackFromNative(%@);", json];
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf callJsCallbackWithJsString:js];
                };

                void(*action)(id, SEL, id, id) = (void(*)(id, SEL, id, id))objc_msgSend;
                action(handler, sel, args, completionHandler);
            } else {
                /** sync call */
                id ret;
                id(*action)(id, SEL, id) = (id(*)(id, SEL, id))objc_msgSend;
                ret = action(handler, sel, args);
                [result setValue:@0 forKey:@"code"];
                if (ret != nil) {
                    [result setValue:ret forKey:@"ret"];
                }
                NSMutableDictionary *dict = result.mutableCopy;
                [dict setObject:callId ?: @"" forKey:@"callId"];
                [self evaluatingDictionary:dict];
            }
            *stop = YES;
        }
    }];
    if (NO == founded) {
        NSString *js = error;
        if (self.isDebug) {
            js = [NSString stringWithFormat:@"window.alert(decodeURIComponent(\"%@\"));",js];
            [self callJsCallbackWithJsString:js];
        } else {
            NSMutableDictionary *dict = result.mutableCopy;
            [dict setObject:callId ?: @"" forKey:@"callId"];
            [self evaluatingDictionary:dict];
        }
        if (self.isDebug) {
            NSLog(@"%@", error);
        }
    }
}

- (void)callJsCallbackWithJsString:(NSString *)js {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (self) {
            self.jsCache = [self.jsCache stringByAppendingString:js];
            if ([self.jsCache length] != 0) {
                [self.webView stringByEvaluatingJavaScriptFromString:self.jsCache];
                if (self.isDebug) {
                    NSLog(@"### send callback JS: %@", self.jsCache);
                }
                self.jsCache = @"";
            }
        }
    });
}

- (void)evaluatingDictionary:(NSDictionary *)result {
    NSString *json = [YTKJsUtils objToJsonString:result];
    NSString *js = [NSString stringWithFormat:@"window.dispatchCallbackFromNative(%@);", json];
    [self callJsCallbackWithJsString:js];
}

@end
