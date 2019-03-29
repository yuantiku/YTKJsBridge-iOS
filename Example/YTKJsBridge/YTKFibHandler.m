//
//  YTKFibHandler.m
//  YTKJsBridge_Example
//
//  Created by lihaichun on 2019/1/14.
//  Copyright © 2019年 lihc. All rights reserved.
//

#import "YTKFibHandler.h"
#import "YTKJsBridge.h"

@implementation YTKFibHandler

- (NSInteger)fibSequence:(NSInteger)n {
    if (n < 2) {
        return n == 0 ? 0 : 1;
    } else {
        return [self fibSequence:n - 1] + [self fibSequence:n -2];
    }
}

- (NSNumber *)fib:(NSNumber *)num {
    NSInteger fib = [self fibSequence:num.integerValue];
    return @(fib);
}

- (void)asyncFib:(NSNumber *)num completion:(YTKJsCallback)completion {
    NSInteger fib = [self fibSequence:num.integerValue];
    completion(nil, @(fib));
}

@end
