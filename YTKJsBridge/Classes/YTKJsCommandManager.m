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

@interface YTKCommandInfo : NSObject <NSCopying>

@property (nonatomic, copy) NSString *commandName; /** 格式namespace.methodName */

@property (nonatomic, copy) NSArray<NSString *> *argTypes; /** 参数类型编码数组 */

@property (nonatomic, copy) NSString *returnType; /** 返回值类型编码 */

@end

@implementation YTKCommandInfo

- (id)copyWithZone:(nullable NSZone *)zone {
    YTKCommandInfo *command = [[[self class] allocWithZone:zone] init];

    command.commandName = self.commandName;
    command.argTypes = [self.argTypes copyWithZone:zone];
    command.returnType = self.returnType;
    return command;
}

@end

@interface YTKJsCommandManager ()

@property (nonatomic, strong) NSMutableDictionary<YTKCommandInfo *, id> *handlers;

@property (nonatomic, strong) NSMutableArray *objects;

@property (nonatomic, strong) YTKBlockHandler *blockHandler;

@property (nonatomic, strong) NSString *jsCache;

@property (nonatomic) BOOL isDebug;

@end

@implementation YTKJsCommandManager

@synthesize webView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _handlers = @{}.mutableCopy;
        _objects = @[].mutableCopy;
        _jsCache = @"";
        _isDebug = NO;
        _blockHandler = [YTKBlockHandler new];
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

    [self.objects addObjectsFromArray:handlers];
    [handlers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<YTKMethodInfo *> *methodInfos = [YTKJsUtils allMethodFromClass:[obj class]];
        [methodInfos enumerateObjectsUsingBlock:^(YTKMethodInfo * _Nonnull method, NSUInteger idx, BOOL * _Nonnull stop) {
            if (method.argumentNum < 2) {
                return;
            }
            SEL sel = NSSelectorFromString(method.methodName);
            NSInvocation *invocation = [self invocationWithObj:obj sel:sel];
            [self addJsCommandName:method.firstMethodName
                          argTypes:method.argTypes
                        returnType:method.returnType
                         namespace:namespace
                        invocation:invocation];
        }];
    }];
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
    if (namespace == nil) {
        namespace = @"";
    }

    NSDictionary<YTKCommandInfo *, id> *handlers = [self.handlers copy];
    [handlers enumerateKeysAndObjectsUsingBlock:^(YTKCommandInfo * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *arr = [YTKJsUtils parseNamespace:key.commandName];
        NSString *namespace = arr.firstObject;
        if ([namespace isKindOfClass:[NSString class]] && [namespace isEqualToString:namespace]) {
            [self.handlers removeObjectForKey:key];
        }
    }];
    [self.blockHandler removeMethodForNamespace:namespace];
}

- (void)removeJsCommandName:(NSString *)commandName namespace:(NSString *)namespace {
    if (NO == [commandName isKindOfClass:[NSString class]] || commandName.length == 0) {
        return;
    }
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }

    NSDictionary<YTKCommandInfo *, id> *handlers = [self.handlers copy];
    [handlers enumerateKeysAndObjectsUsingBlock:^(YTKCommandInfo * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key.commandName isEqualToString:name]) {
            [self.handlers removeObjectForKey:key];
        }
    }];
    // remove block handler
    [self.blockHandler removeMethod:name];
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

- (NSInvocation *)invocationWithObj:(id)obj sel:(SEL)sel {
    NSMethodSignature *signature = [obj methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:obj];
    [invocation setSelector:sel];

    return invocation;
}

- (void)addJsCommandName:(NSString *)commandName
                argTypes:(NSArray *)argTypes
              returnType:(NSString *)returnType
              invocation:(NSInvocation *)invocation {
    [self addJsCommandName:commandName
                  argTypes:argTypes
                returnType:returnType
                 namespace:nil
                invocation:invocation];
}

- (void)addJsCommandName:(NSString *)commandName
                argTypes:(NSArray *)argTypes
              returnType:(NSString *)returnType
               namespace:(NSString *)namespace
              invocation:(NSInvocation *)invocation {
    if (NO == [commandName isKindOfClass:[NSString class]] || commandName.length == 0 || nil == invocation || [invocation isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *name = commandName;
    if ([namespace isKindOfClass:[NSString class]] && namespace.length > 0) {
        name = [NSString stringWithFormat:@"%@.%@", namespace, commandName];
    }

    YTKCommandInfo *command = [YTKCommandInfo new];
    command.commandName = name;
    command.argTypes = argTypes;
    command.returnType = returnType;
    [self.handlers setObject:invocation forKey:command];
}

- (YTKCommandInfo *)commandInfoWithCommandName:(NSString *)commandName argTypes:(NSArray *)argTypes {
    if (NO == [commandName isKindOfClass:[NSString class]] || commandName.length <= 0) {
        return nil;
    }
    __block YTKCommandInfo *commandInfo = nil;
    [self.handlers enumerateKeysAndObjectsUsingBlock:^(YTKCommandInfo * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        /** 检查方法名与参数个数 */
        if (NO == [key.commandName isEqualToString:commandName] || key.argTypes.count != argTypes.count) {
            return;
        }
        __block BOOL argMatched = YES;
        /** 检查参数类型 */
        [key.argTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull argStop) {
            if (NO == [obj isEqualToString:argTypes[idx]]) {
                argMatched = NO;
                *argStop = YES;
            }
        }];
        if (argMatched) {
            commandInfo = key;
            *stop = YES;
        }
    }];
    return commandInfo;
}

- (NSDictionary *)callCommand:(YTKJsCommand *)command {
    if (self.isDebug) {
        NSLog(@"### receive methodName:%@, args:%@, callId:%@", command.methodName, command.args, command.callId);
    }
    NSString *commandName = command.methodName;
    NSArray *args = command.args;
    NSString *callId = command.callId;
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{@"code" : @-1, @"ret" : @""}];
    NSString *error = [NSString stringWithFormat:@"Error! \n Method %@ is not invoked, since there is not a implementation for it",commandName];
    if (NO == [args isKindOfClass:[NSArray class]] || args == nil) {
        args = @[];
    }

    NSMutableArray *argTypes = @[].mutableCopy;
    [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /** 暂时认为从js传过来的参数数组里面，都是对象类型 */
        [argTypes addObject:@"@"];
    }];
    BOOL isAsync = callId && NO == [callId isEqualToString:@"-1"];
    BOOL founded = NO;
    if (isAsync) {
        [argTypes addObject:@"@"];
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
        [completionHandler copy];

        YTKCommandInfo *commandInfo = [self commandInfoWithCommandName:commandName argTypes:argTypes];
        if (commandInfo) {
            NSInvocation *invocation = [self.handlers objectForKey:commandInfo];
            if (invocation) {
                founded = YES;
                [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [invocation setArgument:&obj atIndex:idx+2];
                }];
                [invocation setArgument:&completionHandler atIndex:args.count+2];
                [invocation invoke];
            }
        }
        if (founded == NO) {
            if ([self.blockHandler canHandleAsyncMethod:commandName]) {
                founded = YES;
                [self.blockHandler performAsyncMethod:commandName arguments:args callback:completionHandler];
            }
        }
    } else {
        /** sync call */
        YTKCommandInfo *commandInfo = [self commandInfoWithCommandName:commandName argTypes:argTypes];
        BOOL hasReturnValue = ![commandInfo.returnType isEqualToString:@"v"];
        if (commandInfo) {
            NSInvocation *invocation = [self.handlers objectForKey:commandInfo];
            if (invocation) {
                founded = YES;
                [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [invocation setArgument:&obj atIndex:idx+2];
                }];
                [invocation invoke];
                void *tempRet = NULL;
                if (hasReturnValue) {
                    [invocation getReturnValue:&tempRet];
                    if (tempRet) {
                        id ret = (__bridge id)tempRet;
                        [result setValue:ret forKey:@"ret"];
                    }
                }
            }
        }
        if (NO == founded) {
            if (hasReturnValue) {
                if ([self.blockHandler canHandleSyncMethod:commandName]) {
                    founded = YES;
                    id ret = [self.blockHandler performSyncMethod:commandName argments:args];
                    if (ret) {
                        [result setValue:ret forKey:@"ret"];
                    }
                }
            } else {
                if ([self.blockHandler canHandleVoidSyncMethod:commandName]) {
                    founded = YES;
                    [self.blockHandler performVoidSyncMethod:commandName arguments:args];
                }
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
