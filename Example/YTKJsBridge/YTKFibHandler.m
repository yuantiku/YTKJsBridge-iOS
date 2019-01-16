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

- (NSNumber *)fib:(NSDictionary *)argument {
    NSInteger n = [[argument objectForKey:@"n"] integerValue];
    return @([self fibSequence:n]);
}

- (void)asyncFib:(NSDictionary *)argument completion:(YTKDataCallback)completion {
    NSInteger n = [[argument objectForKey:@"n"] integerValue];
    completion(nil, @([self fibSequence:n]));
}

@end
