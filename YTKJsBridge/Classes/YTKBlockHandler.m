//
//  YTKBlockHandler.m
//  YTKJsBridge
//
//  Created by lihaichun on 2019/2/22.
//

#import "YTKBlockHandler.h"

@interface YTKBlockHandler ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *syncBlocks;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *voidSyncBlocks;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *asyncBlocks;

@end

@implementation YTKBlockHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        _syncBlocks = [NSMutableDictionary dictionary];
        _voidSyncBlocks = [NSMutableDictionary dictionary];
        _asyncBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)canHandleSyncMethod:(NSString *)method {
    return [self.syncBlocks objectForKey:method] != nil;
}

- (BOOL)canHandleVoidSyncMethod:(NSString *)method {
    return [self.voidSyncBlocks objectForKey:method] != nil;
}

- (BOOL)canHandleAsyncMethod:(NSString *)method {
    return [self.asyncBlocks objectForKey:method] != nil;
}

- (void)addSyncMethod:(NSString *)method block:(YTKSyncCallback)block {
    if (![method isKindOfClass:[NSString class]] || !block || [block isKindOfClass:[NSNull class]]) {
        return;
    }
    [self.syncBlocks setObject:block forKey:method];
}

- (void)addVoidSyncMethod:(NSString *)method block:(YTKVoidSyncCallback)block {
    if (![method isKindOfClass:[NSString class]] || !block || [block isKindOfClass:[NSNull class]]) {
        return;
    }
    [self.voidSyncBlocks setObject:block forKey:method];
}

- (void)addAsyncMethod:(NSString *)method block:(YTKAsyncCallback)block {
    if (![method isKindOfClass:[NSString class]] || !block || [block isKindOfClass:[NSNull class]]) {
        return;
    }
    [self.asyncBlocks setObject:block forKey:method];
}

- (void)removeMethodForNamespace:(NSString *)namespace {
    if (![namespace isKindOfClass:[NSString class]]) {
        return;
    }
    [self removeMethodForNamespace:namespace inBlocks:self.syncBlocks];
    [self removeMethodForNamespace:namespace inBlocks:self.voidSyncBlocks];
    [self removeMethodForNamespace:namespace inBlocks:self.asyncBlocks];
}

- (void)removeMethodForNamespace:(NSString *)namespace inBlocks:(NSMutableDictionary *)blocks {
    BOOL emptyNamespace = namespace.length == 0;
    NSDictionary *temp = blocks.copy;
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSRange range = [namespace rangeOfString:@"."];
        if (range.location == NSNotFound) {
            if (emptyNamespace) {
                [blocks removeObjectForKey:key];
            }
        } else {
            NSString *ns = [namespace substringToIndex:range.location];
            if ([ns isEqualToString:namespace]) {
                [blocks removeObjectForKey:key];
            }
        }
    }];
}

- (void)removeMethod:(NSString *)method {
    [self removeSyncMethod:method];
    [self removeVoidSyncMethod:method];
    [self removeAsyncMethod:method];
}

- (void)removeSyncMethod:(NSString *)method {
    if (![method isKindOfClass:[NSString class]]) {
        return;
    }
    [self.syncBlocks removeObjectForKey:method];
}

- (void)removeVoidSyncMethod:(NSString *)method {
    if (![method isKindOfClass:[NSString class]]) {
        return;
    }
    [self.voidSyncBlocks removeObjectForKey:method];
}

- (void)removeAsyncMethod:(NSString *)method {
    if (![method isKindOfClass:[NSString class]]) {
        return;
    }
    [self.asyncBlocks removeObjectForKey:method];
}

- (id)performSyncMethod:(NSString *)method argments:(NSArray *)arguments {
    YTKSyncCallback block = [self.syncBlocks objectForKey:method];
    if (block) {
        return block(arguments);
    } else {
        return nil;
    }
}

- (void)performVoidSyncMethod:(NSString *)method arguments:(NSArray *)arguments {
    YTKVoidSyncCallback block = [self.voidSyncBlocks objectForKey:method];
    if (block) {
        block(arguments);
    }
}

- (void)performAsyncMethod:(NSString *)method arguments:(NSArray *)argumets callback:(YTKDataCallback)callback {
    YTKAsyncCallback block = [self.asyncBlocks objectForKey:method];
    if (block) {
        block(argumets, callback);
    } else {
        if (!callback) {
            return;
        }
        NSError *error = [NSError errorWithDomain:@"YTKMethodNotFound" code:0 userInfo:nil];
        callback(error, nil);
    }
}

@end
