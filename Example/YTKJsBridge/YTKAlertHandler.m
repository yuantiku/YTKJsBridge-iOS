//
//  YTKAlertHandler.m
//  FlyWebView
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import "YTKAlertHandler.h"

@implementation YTKAlertHandler

- (void)syncSayHello:(nullable NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *av = [[UIAlertView alloc] initWithTitle: title
                                                     message: nil
                                                    delegate: nil
                                           cancelButtonTitle: @"OK"
                                           otherButtonTitles: nil];
        [av show];
#pragma clang diagnostic pop
    });
}

- (void)asyncSayHello:(nullable NSString *)title completion:(void(^)(NSError *error, id value))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *av = [[UIAlertView alloc] initWithTitle: title
                                                     message: nil
                                                    delegate: nil
                                           cancelButtonTitle: @"OK"
                                           otherButtonTitles: nil];
        [av show];
#pragma clang diagnostic pop
        if (completion) {
            completion(nil, nil);
        }
    });
}

- (void)alert:(nullable NSString *)title completion:(void(^)(NSError *error, id value))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *av = [[UIAlertView alloc] initWithTitle: title
                                                     message: nil
                                                    delegate: nil
                                           cancelButtonTitle: @"OK"
                                           otherButtonTitles: nil];
        [av show];
#pragma clang diagnostic pop
        if (completion) {
            completion(nil, nil);
        }
    });
}

@end
