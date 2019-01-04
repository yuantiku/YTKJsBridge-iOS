//
//  YTKBaseCommandHandler.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import "YTKBaseCommandHandler.h"

@implementation YTKBaseCommandHandler

@synthesize webView;

#pragma mark - YTKJsCommandHandler

- (void)handleJsCommand:(YTKJsCommand *)command inWebView:(UIWebView *)webView {
    NSAssert(NO, @"Sub class must rewrite this method !");
}

- (BOOL)shouldCallDefaultJsCallback {
    return YES;
}

@end
