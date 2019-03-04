//
//  YTKJsCommandManager.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import "YTKJsCommandManager.h"
#import "YTKJsCommandHandler.h"
#import "YTKBlockHandler.h"
#import "YTKJsUtils.h"
#import <objc/message.h>

@interface YTKJsCommandManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray *> *namespaceHandlers;

@property (nonatomic, strong) YTKBlockHandler *blockHandler;

@property (nonatomic, strong) NSString *jsCache;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsCommandManager

@synthesize webView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _namespaceHandlers = [NSMutableDictionary dictionary];
        _jsCache = @"";
        _isDebug = NO;
        _blockHandler = [YTKBlockHandler new];
    }
    return self;
}

- (void)dealloc {
    if (!self.isDebug) {
        return;
    }
    NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - Public Methods

- (void)addJsCommandHandlers:(NSArray<id> *)handlers forNamespace:(nullable NSString *)namespace {
    if (![handlers isKindOfClass:NSArray.class] || handlers.count == 0) {
        if (!self.isDebug) {
            return;
        }
        NSLog(@"ERROR, invalid add parameter");
        return;
    }
    if (![namespace isKindOfClass:[NSString class]]) {
        namespace = @"";
    }
    NSArray *arr = [self.namespaceHandlers objectForKey:namespace];
    if (arr) {
        NSMutableArray *mArr = arr.mutableCopy;
        [mArr addObjectsFromArray:handlers];
        [self.namespaceHandlers setObject:mArr.copy forKey:namespace];
    } else {
        [self.namespaceHandlers setObject:handlers forKey:namespace];
    }
}

- (void)addSyncJsCommandName:(NSString *)commandName impBlock:(YTKSyncCallback)impBlock {
    [self addSyncJsCommandName:commandName namespace:nil impBlock:impBlock];
}

- (void)addSyncJsCommandName:(NSString *)commandName
                   namespace:(NSString *)namespace
                    impBlock:(YTKSyncCallback)impBlock {
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }
    [self.blockHandler addSyncMethod:name block:impBlock];
}

- (void)addVoidSyncJsCommandName:(NSString *)commandName impBlock:(YTKVoidSyncCallback)impBlock {
    [self addVoidSyncJsCommandName:commandName namespace:nil impBlock:impBlock];
}

- (void)addVoidSyncJsCommandName:(NSString *)commandName
                       namespace:(nullable NSString *)namespace
                        impBlock:(YTKVoidSyncCallback)impBlock {
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }
    [self.blockHandler addVoidSyncMethod:name block:impBlock];
}

- (void)addAsyncJsCommandName:(NSString *)commandName impBlock:(YTKAsyncCallback)impBlock {
    [self addAsyncJsCommandName:commandName namespace:nil impBlock:impBlock];
}

- (void)addAsyncJsCommandName:(NSString *)commandName
                    namespace:(NSString *)namespace
                     impBlock:(YTKAsyncCallback)impBlock {
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }
    [self.blockHandler addAsyncMethod:name block:impBlock];
}

- (void)removeJsCommandHandlerForNamespace:(nullable NSString *)namespace {
    if (![namespace isKindOfClass:[NSString class]]) {
        namespace = @"";
    }

    [self.namespaceHandlers removeObjectForKey:namespace];
    [self.blockHandler removeMethodForNamespace:namespace];
}

- (void)removeJsCommandName:(NSString *)commandName namespace:(NSString *)namespace {
    if (![commandName isKindOfClass:[NSString class]] || commandName.length == 0) {
        return;
    }
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }
    // remove block handler
    [self.blockHandler removeMethod:name];
}

- (NSString *)callJsWithDictionary:(NSDictionary *)dictionary {
    if (!self.webView || ![dictionary isKindOfClass:[NSDictionary class]]) {
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
    if (![command.methodName isKindOfClass:[NSString class]] || [command.methodName isEqualToString:@"makeCallback"]) {
        return nil;
    }
    __weak typeof(self)weakSelf = self;
    return [weakSelf callCommand:command];
}

#pragma mark - Utils

- (void)invocationWithMethodName:(NSString *)methodName
                       namespace:(NSString *)namespace
                        argTypes:(NSArray *)argTypes
                      completion:(void(^)(NSInvocation *, YTKMethodInfo *))completion {
    if (![methodName isKindOfClass:[NSString class]]) {
        if (completion) {
            completion(nil, nil);
        }
        return;
    }
    if (![namespace isKindOfClass:[NSString class]]) {
        namespace = @"";
    }
    __block NSInvocation *invocation = nil;
    __block YTKMethodInfo *targetMethod = nil;
    NSArray *handlers = [self.namespaceHandlers objectForKey:namespace];
    [handlers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<YTKMethodInfo *> *methods = [YTKJsUtils allMethodFromClass:[obj class]];
        [methods enumerateObjectsUsingBlock:^(YTKMethodInfo * _Nonnull method, NSUInteger methodIdx, BOOL * _Nonnull methodStop) {
            /** 检查方法名与参数个数 */
            if (![methodName isEqualToString:method.firstMethodName] || method.argTypes.count != argTypes.count) {
                return;
            }
            __block BOOL argMatched = YES;
            /** 检查参数类型 */
            [method.argTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull argType, NSUInteger argIdx, BOOL * _Nonnull argStop) {
                if (![argType isEqualToString:argTypes[argIdx]]) {
                    argMatched = NO;
                    *argStop = YES;
                }
            }];
            if (!argMatched) {
                return;
            }
            targetMethod = method;
            *methodStop = YES;
        }];
        if (!targetMethod) {
            return;
        }
        SEL sel = NSSelectorFromString(targetMethod.methodName);
        invocation = [self invocationWithObj:obj sel:sel];
        *stop = YES;
    }];
    if (completion) {
        completion(invocation, targetMethod);
    }
}

- (NSInvocation *)invocationWithObj:(id)obj sel:(SEL)sel {
    if (self.isDebug) {
        NSLog(@"###### performInvocation to obj: %@, sel: %@", [obj class], NSStringFromSelector(sel));
    }
    if (!obj) {
        return nil;
    }
    NSMethodSignature *signature = [obj methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:obj];
    [invocation setSelector:sel];
    return invocation;
}

- (NSDictionary *)callCommand:(YTKJsCommand *)command {
    if (self.isDebug) {
        NSLog(@"### receive methodName:%@, args:%@, callId:%@", command.methodName, command.args, command.callId);
    }
    NSString *commandName = command.methodName;
    NSString *namespace = [YTKJsUtils parseNamespace:commandName].firstObject;
    NSArray *args = command.args;
    NSString *callId = command.callId;
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{@"code" : @-1, @"ret" : @""}];
    NSString *error = [NSString stringWithFormat:@"Error! \n Method %@ is not invoked, since there is not a implementation for it",commandName];
    if (![args isKindOfClass:[NSArray class]] || !args) {
        args = @[];
    }

    NSMutableArray *argTypes = [NSMutableArray array];
    [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /** 暂时认为从js传过来的参数数组里面，都是对象类型 */
        // TODO: 后续考虑根据obj来获取类型编码
        [argTypes addObject:@"@"];
    }];
    BOOL isAsync = callId && ![callId isEqualToString:@"-1"];
    __block BOOL founded = NO;
    if (isAsync) {
        [argTypes addObject:@"@?"]; /** 如果是异步，增加block参数类型编码 */
        /** async call */
        __weak typeof(self) weakSelf = self;

        YTKDataCallback completionHandler = ^(NSError *error, id value) {
            [result setObject:@0 forKey:@"code"];
            if (value) {
                [result setObject:value forKey:@"ret"];
            }
            NSMutableDictionary *dict = result.mutableCopy;
            [dict setObject:callId forKey:@"callId"];
            NSString *json = [YTKJsUtils objToJsonString:dict];
            NSString *js = [NSString stringWithFormat:@"window.dispatchCallbackFromNative(%@);", json];
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf callJsCallbackWithJsString:js];
        };
        [completionHandler copy];

        [self invocationWithMethodName:commandName namespace:namespace argTypes:argTypes completion:^(NSInvocation *invocation, YTKMethodInfo *method) {
            if (invocation) {
                founded = YES;
                [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [invocation setArgument:&obj atIndex:idx+2];
                }];
                [invocation setArgument:(void *)&completionHandler atIndex:args.count+2];
                [invocation invoke];
            } else {
                if ([self.blockHandler canHandleAsyncMethod:commandName]) {
                    founded = YES;
                    [self.blockHandler performAsyncMethod:commandName arguments:args callback:completionHandler];
                }
            }
        }];
    } else {
        /** sync call */
        [self invocationWithMethodName:commandName namespace:namespace argTypes:argTypes completion:^(NSInvocation *invocation, YTKMethodInfo *method) {
            if (invocation) {
                BOOL hasReturnValue = ![method.returnType isEqualToString:@"v"];
                founded = YES;
                [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [invocation setArgument:&obj atIndex:idx+2];
                }];
                [invocation invoke];
                if (!hasReturnValue) {
                    return;
                }
                void *tempRet = NULL;
                [invocation getReturnValue:&tempRet];
                if (!tempRet) {
                    return;
                }
                id ret = (__bridge id)tempRet;
                [result setValue:ret forKey:@"ret"];
            } else {
                if ([self.blockHandler canHandleSyncMethod:commandName]) {
                    founded = YES;
                    id ret = [self.blockHandler performSyncMethod:commandName argments:args];
                    if (!ret) {
                        return;
                    }
                    [result setValue:ret forKey:@"ret"];
                } else if ([self.blockHandler canHandleVoidSyncMethod:commandName]) {
                    founded = YES;
                    [self.blockHandler performVoidSyncMethod:commandName arguments:args];
                }
            }
        }];
    }

    [result setObject:callId ?: @"" forKey:@"callId"];
    if (!founded) {
        [result setObject:error forKey:@"message"];
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
            if ([self.jsCache length] == 0) {
                return;
            }
            if (self.isDebug) {
                NSLog(@"### send callback JS: %@", self.jsCache);
            }
            [self.webView stringByEvaluatingJavaScriptFromString:self.jsCache];
            self.jsCache = @"";
        }
    });
}

- (void)evaluatingDictionary:(NSDictionary *)result {
    NSString *json = [YTKJsUtils objToJsonString:result];
    NSString *js = [NSString stringWithFormat:@"window.dispatchCallbackFromNative(%@);", json];
    [self callJsCallbackWithJsString:js];
}

@end
