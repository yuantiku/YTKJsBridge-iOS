//
//  YTKJsCommand.m
//  YTKJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import "YTKJsCommand.h"

@implementation YTKJsCommand

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSString *methodName = [dictionary objectForKey:@"methodName"];
        if ([methodName isKindOfClass:[NSString class]]) {
            _methodName = methodName;
        }
        id callId = [dictionary objectForKey:@"callId"];
        if ([callId isKindOfClass:[NSString class]]) {
            _callId = (NSString *)callId;
        } else if ([callId respondsToSelector:@selector(stringValue)]) {
            _callId = [callId stringValue];
        }
        NSArray *args = [dictionary objectForKey:@"args"];
        if ([args isKindOfClass:[NSArray class]]) {
            _args = args;
        }
    }
    return self;
}

@end

@implementation YTKJsEvent

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSString *event = [dictionary objectForKey:@"event"];
        if ([event isKindOfClass:[NSString class]]) {
            _event = event;
        }
        id arg = [dictionary objectForKey:@"arg"];
        if (arg) {
            _arg = arg;
        }
    }
    return self;
}

@end
