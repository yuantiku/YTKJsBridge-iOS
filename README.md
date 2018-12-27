# YTKJsBridge

[![CI Status](https://img.shields.io/travis/lihc/YTKJsBridge.svg?style=flat)](https://travis-ci.org/yuantiku/YTKJsBridge)
[![Version](https://img.shields.io/cocoapods/v/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)
[![License](https://img.shields.io/cocoapods/l/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)
[![Platform](https://img.shields.io/cocoapods/p/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)

## YTKJsBridge 是什么

YTKJsBridge是基于OC语言实现的一套客户端与网页JS相互调用的iOS库，其中主要依赖JavaScriptCore、UIWebView来实现的，JavaScriptCore这个framework被广泛使用在JSPatch、RN等上面。

## YTKJsBridge 提供了那些功能

 * 支持客户端向网页动态注入OC实现的方法。
 * 支持网页以同步方式调用客户端注入的OC方法。
 * 支持网页调用客户端注入的OC方法的时候，直接以json格式数据作为参数，无需序列化。
 * 支持客户端主动调用网页的JavaScript方法。

## 哪些项目适合使用 YTKJsBridge

YTKJsBridge 适合ObjectC实现的项目，并且项目中使用UIWebView作为网页的容器，并且有比较多的客户端与网页直接交互的需求。

如果你的项目中使用了UIwebView，并且有大量的客户端与网页的交互逻辑，使用YTKJsBridge将给你带来很大的帮助，简化客户端与网页交互的实现逻辑，并且交互都是同步的，与本地调用基本一样。

## YTKJsBridge 的基本思想

YTKJsBridge 的基本思想是把一个或多个JS注入方法的实现放到一个实现了YTKJsCommandHandler协议的类里面，所以使用YTKJsBridge，你的一个或多个相关的注入方法，可以通过实现YTKJsCommandHandler来放到单独的类进行管理。

把一个或多个注入方法的实现放到一个实现YTKJsCommandHandler的类里面，有如下好处：
 * 天然将一类相关的注入方法实现都放在一个类中进行管理，可以避免注入方法四散到项目的各个地方又可能出现重复代码的问题。
 * 可以避免将所有的注入方法都放到一个类中实现，导致文件过长逻辑产生交叉，增加后续的维护成本。

当然，如果说他有什么不好，那就是你的工程以及网页都需要使用YTKJSCommand定义的json结构进行数据传递，但是YTKJSCommand本身就是一个定义比较宽松的结构。

## 安装

你可以在Podfile中加入下面一行代码来使用YTKJsBridge

```ruby
pod 'YTKJsBridge'
```

## 安装要求

   | YTKNetwork 版本 |  最低 iOS Target | 注意 |
   |:----------------:|:----------------:|:-----|
   | 0.1.0 | iOS 7 | 要求 Xcode 7 以上 |

## 例子

clone当前repo， 到Example目录下执行`pod install`命令，就可以运行例子工程

## 使用方法

客户端向网页注入方法，首先需要创建一个实现了YTKJsCommandHandler协议的类，下面就是向网页注入弹出alert的方法的类实现，如下所示：

```objectivec
@interface YTKAlertHandler : NSObject <YTKJsCommandHandler>

@end

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
```

客户端调用网页JS方法，直接调用YTKWebViewJsBridge的类方法即可。

## 作者

YTKJsBridgede 的主要作者是：

lihc， https://github.com/xiaochun0618

## 协议

YTKJsBridgede 被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息。


