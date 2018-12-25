//
//  YTKJsCommand.m
//  YTKWebViewJsBridge
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import "YTKJsCommand.h"

@implementation YTKJsCommand

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSString *name = [dictionary objectForKey:@"name"];
        if ([name isKindOfClass:[NSString class]]) {
            _name = name;
        }
        NSString *callback = [dictionary objectForKey:@"callback"];
        if ([callback isKindOfClass:[NSString class]]) {
            _callback = callback;
        }
        NSDictionary *arguments = [dictionary objectForKey:@"arguments"];
        if ([arguments isKindOfClass:[NSDictionary class]]) {
            _arguments = arguments;
        }
    }
    return self;
}

@end
