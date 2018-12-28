#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIWebView+JavaScriptContext.h"
#import "YTKBaseCommandHandler.h"
#import "YTKJsBridge.h"
#import "YTKJsCommand.h"
#import "YTKJsCommandHandler.h"
#import "YTKJsCommandManager.h"

FOUNDATION_EXPORT double YTKJsBridgeVersionNumber;
FOUNDATION_EXPORT const unsigned char YTKJsBridgeVersionString[];

