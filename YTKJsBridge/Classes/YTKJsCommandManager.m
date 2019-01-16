//
//  YTKJsCommandManager.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import "YTKJsCommandManager.h"
#import "YTKJsCommandHandler.h"
#import "YTKJsUtils.h"
#import <objc/message.h>

@interface YTKJsCommandManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, YTKAsyncCallback> *asyncHandlers;

@property (nonatomic, strong) NSMutableDictionary<NSString *, YTKSyncCallback> *syncHandlers;

@property (nonatomic, strong) NSString *jsCache;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsCommandManager

@synthesize webView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _asyncHandlers = @{}.mutableCopy;
        _syncHandlers = @{}.mutableCopy;
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

#pragma mark - Public Methods

- (void)addJsCommandHandlers:(NSArray<id> *)handlers forNamespace:(nullable NSString *)namespace {
    if (NO == [handlers isKindOfClass:NSArray.class] || handlers.count == 0) {
        if (self.isDebug) {
            NSLog(@"ERROR, invalid add parameter");
        }
        return;
    }

    [handlers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> *allMethods = [YTKJsUtils allMethodFromClass:[obj class]];
        [allMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull method, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *tmpArr = [method componentsSeparatedByString:@":"];
            NSRange range = [method rangeOfString:@":"];
            if (range.length > 0) {
                SEL sel = NSSelectorFromString(method);
                NSString *commandName = [method substringWithRange:NSMakeRange(0, range.location)];
                if (tmpArr.count == 2) {
                    /** sync */
                    id(*action)(id, SEL, id) = (id(*)(id, SEL, id))objc_msgSend;

                    YTKSyncCallback block = (id)^(NSDictionary *argument) {
                        id ret = action(obj, sel, argument);
                        return ret;
                    };
                    [self addSyncJsCommandName:commandName namespace:namespace handler:block];
                } else if (tmpArr.count == 3) {
                    /** async */
                    void(*action)(id, SEL, id, id) = (void(*)(id, SEL, id, id))objc_msgSend;

                    YTKAsyncCallback block = ^(NSDictionary *argument, YTKDataCallback dataBlock) {
                        action(obj, sel, argument, dataBlock);
                    };
                    [self addAsyncJsCommandName:commandName namespace:namespace handler:block];
                }
            }
        }];
    }];
}

- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace {
    if (namespace == nil) {
        namespace = @"";
    }

    NSDictionary<NSString *, YTKSyncCallback> *syncHandlers = [self.syncHandlers copy];
    [syncHandlers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, YTKSyncCallback  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *arr = [YTKJsUtils parseNamespace:key];
        NSString *namespace = arr.firstObject;
        if ([namespace isKindOfClass:[NSString class]] && [namespace isEqualToString:namespace]) {
            [self.syncHandlers removeObjectForKey:key];
        }
    }];

    NSDictionary<NSString *, YTKAsyncCallback> *asyncHandlers = [self.asyncHandlers copy];
    [asyncHandlers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, YTKAsyncCallback  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *arr = [YTKJsUtils parseNamespace:key];
        NSString *namespace = arr.firstObject;
        if ([namespace isKindOfClass:[NSString class]] && [namespace isEqualToString:namespace]) {
            [self.asyncHandlers removeObjectForKey:key];
        }
    }];
}

- (void)addSyncJsCommandName:(NSString *)commandName handler:(YTKSyncCallback)handler {
    [self addSyncJsCommandName:commandName namespace:nil handler:handler];
}

- (void)addSyncJsCommandName:(NSString *)commandName namespace:(NSString *)namespace handler:(YTKSyncCallback)handler {
    if (NO == [commandName isKindOfClass:[NSString class]] || commandName.length == 0 || nil == handler) {
        return;
    }
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }

    [self.syncHandlers setObject:handler forKey:name];
}

- (void)addAsyncJsCommandName:(NSString *)commandName handler:(YTKAsyncCallback)handler {
    [self addAsyncJsCommandName:commandName namespace:nil handler:handler];
}

- (void)addAsyncJsCommandName:(NSString *)commandName namespace:(NSString *)namespace handler:(YTKAsyncCallback)handler {
    if (NO == [commandName isKindOfClass:[NSString class]] || commandName.length == 0 || nil == handler) {
        return;
    }
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }

    [self.asyncHandlers setObject:handler forKey:name];
}

- (void)removeJsCommandName:(NSString *)commandName namespace:(NSString *)namespace {
    if (NO == [commandName isKindOfClass:[NSString class]] || commandName.length == 0) {
        return;
    }
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }

    [self.asyncHandlers removeObjectForKey:name];
    [self.syncHandlers removeObjectForKey:name];
}

- (NSString *)callJsWithDictionary:(NSDictionary *)dictionary {
    if (self.webView == nil || NO == [dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *json = [YTKJsUtils objToJsonString:dictionary];
    NSString *js = [NSString stringWithFormat:@"window.dispatchNativeCall(%@)", json];
    if (self.isDebug) {
        NSLog(@"### send native call: %@", js);
    }
    return [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setDebugMode:(BOOL)debug {
    _isDebug = debug;
}

#pragma mark - YTKJsCommandHandler

- (NSDictionary *)handleJsCommand:(YTKJsCommand *)command inWebView:(UIWebView *)webView {
    if (NO == [command.methodName isKindOfClass:[NSString class]] || [command.methodName isEqualToString:@"makeCallback"]) {
        return nil;
    }
    __weak typeof(self)weakSelf = self;
    return [weakSelf callCommand:command];
}

#pragma mark - Utils

- (NSDictionary *)callCommand:(YTKJsCommand *)command {
    if (self.isDebug) {
        NSLog(@"### receive methodName:%@, args:%@, callId:%@", command.methodName, command.args, command.callId);
    }
    NSString *commandName = command.methodName;
    NSDictionary *args = command.args;
    NSString *callId = command.callId;
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{@"code" : @-1, @"ret" : @""}];
    NSString *error = [NSString stringWithFormat:@"Error! \n Method %@ is not invoked, since there is not a implementation for it",commandName];
    if (NO == [args isKindOfClass:[NSDictionary class]] || args == nil) {
        args = @{};
    }

    BOOL isAsync = callId && NO == [callId isEqualToString:@"-1"];
    BOOL founded = NO;
    if (isAsync) {
        /** async call */
        __weak typeof(self) weakSelf = self;

        YTKDataCallback completionHandler = ^(NSError *error, id value) {
            [result setObject:@0 forKey:@"code"];
            if (value != nil) {
                [result setObject:value forKey:@"ret"];
            }
            NSMutableDictionary *dict = result.mutableCopy;
            [dict setObject:callId forKey:@"callId"];
            NSString *json = [YTKJsUtils objToJsonString:dict];
            NSString *js = [NSString stringWithFormat:@"window.dispatchCallbackFromNative(%@);", json];
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf callJsCallbackWithJsString:js];
        };

        YTKAsyncCallback action = [self.asyncHandlers objectForKey:commandName];
        if (action) {
            founded = YES;
            action(args, completionHandler);
        }
    } else {
        /** sync call */
        YTKSyncCallback action = [self.syncHandlers objectForKey:commandName];
        if (action) {
            founded = YES;
            id ret = action(args);
            if (ret != nil) {
                [result setValue:ret forKey:@"ret"];
            }
        }
    }

    [result setObject:callId ?: @"" forKey:@"callId"];
    if (NO == founded) {
        NSString *js = error;
        if (self.isDebug) {
            js = [NSString stringWithFormat:@"window.alert(decodeURIComponent(\"%@\"));", js];
            [self callJsCallbackWithJsString:js];
            NSLog(@"%@", error);
        }
        if (isAsync) {
            [self evaluatingDictionary:result];
        }
    } else {
        [result setObject:@0 forKey:@"code"];
    }
    return result;
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
