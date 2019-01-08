//
//  YTKAlertHandler.m
//  FlyWebView
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import "YTKAlertHandler.h"

@implementation YTKAlertHandler

- (void)sayHello:(nullable NSDictionary *)msg completion:(void(^)(NSError *error, id value))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = [msg objectForKey:@"title"];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle: title
                                                     message: nil
                                                    delegate: nil
                                           cancelButtonTitle: @"OK"
                                           otherButtonTitles: nil];
        [av show];
    });
    if (completion) {
        completion(nil, nil);
    }
}

@end
