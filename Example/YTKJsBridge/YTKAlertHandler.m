//
//  YTKAlertHandler.m
//  FlyWebView
//
//  Created by lihaichun on 2018/12/21.
//  Copyright © 2018年 fenbi. All rights reserved.
//

#import "YTKAlertHandler.h"
#import <UIKit/UIKit.h>

@implementation YTKAlertHandler

@synthesize webView;

- (void)handleJSCommand:(YTKJsCommand *)command inWebView:(UIWebView *)webView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Hello, World!"
                                                     message: nil
                                                    delegate: nil
                                           cancelButtonTitle: @"OK"
                                           otherButtonTitles: nil];
        [av show];
    });
}

@end
