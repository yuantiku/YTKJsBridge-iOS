//
//  YTKBaseCommandHandler.m
//  Pods-YTKJsBridge_Example
//
//  Created by lihaichun on 2018/12/28.
//

#import "YTKBaseCommandHandler.h"

@implementation YTKBaseCommandHandler

@synthesize webView;
@synthesize commandNames;

#pragma mark - YTKJsCommandHandler

- (void)handleJsCommand:(YTKJsCommand *)command inWebView:(UIWebView *)webView {
    NSAssert(NO, @"Sub class must rewrite this method !");
}

- (BOOL)shouldCallDefaultJsCallback {
    return YES;
}

- (NSArray<NSString *> *)commandNames {
    NSAssert(NO, @"Sub class must rewrite this method !");
    return @[];
}

@end
