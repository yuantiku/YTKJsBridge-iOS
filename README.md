# YTKJsBridge

[![CI Status](https://img.shields.io/travis/lihc/YTKJsBridge.svg?style=flat)](https://travis-ci.org/yuantiku/YTKJsBridge-iOS)
[![Version](https://img.shields.io/cocoapods/v/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)
[![License](https://img.shields.io/cocoapods/l/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)
[![Platform](https://img.shields.io/cocoapods/p/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)

## YTKJsBridge 是什么

YTKJsBridge是基于OC语言实现的一套客户端与网页JS相互调用的iOS库，其中主要依赖JavaScriptCore、UIWebView来实现的，JavaScriptCore这个framework被广泛使用在JSPatch、RN等上面。

## YTKJsBridge 提供了那些功能

 * 支持客户端向网页动态注入OC实现的方法，并支持命名空间。
 * 支持网页以同步、异步方式调用客户端注入的OC方法。
 * 支持网页调用客户端注入的OC方法的时候，直接以json格式数据作为参数，无需序列化。
 * 支持客户端主动调用网页提供的JavaScript方法。

## 哪些项目适合使用 YTKJsBridge

YTKJsBridge 适合ObjectC实现的项目，并且项目中使用UIWebView作为网页的容器，并且有比较多的客户端与网页直接交互的需求。

如果你的项目中使用了UIwebView，并且有大量的客户端与网页的交互逻辑，使用YTKJsBridge将给你带来很大的帮助，简化客户端与网页交互的实现逻辑，并且交互都是同步的，与本地调用基本一样，提供交互效率。

## YTKJsBridge 的基本思想

YTKJsBridge 的基本思想是把一个或多个JS注入方法的实现放到一个实现了类里面，并且同一个命名空间可以注册多个方法实现类，所以使用YTKJsBridge，你的一个或多个相关的注入方法，可以放到单独的类进行管理，并支持命名空间，也就是说多个注入方法实现类可以有同名方法。

YTKJsBridge 会向网页注入一个名为YTKJsBridge的全局方法，后续所有需要向YTKJsBridge注入的方法，都是通过这个全局方法来调用执行的，后面使用方法中有具体的例子。

把一个或多个注入方法的实现放到一个类里面，有如下好处：
 * 天然将一类相关的注入方法实现都放在一个类中进行管理，可以避免注入方法四散到项目的各个地方又可能出现重复代码的问题。
 * 可以避免将所有的注入方法都放到一个类中实现，导致文件过长逻辑产生交叉，增加后续的维护成本。

当然，如果说他有什么不好，那就是你的工程以及网页都需要使用YTKJsCommand定义的json结构进行数据传递，但是YTKJsCommand本身就是一个定义比较宽松的结构。

## 安装

你可以在Podfile中加入下面一行代码来使用YTKJsBridge

```ruby
pod 'YTKJsBridge'
```
## 安装要求

   | YTKJsBridge 版本 |  最低 iOS Target | 注意 |
   |:----------------:|:----------------:|:-----|
   | 0.1.0 | iOS 7 | 要求 Xcode 7 以上 |

## 例子

clone当前repo， 到Example目录下执行`pod install`命令，就可以运行例子工程

## 使用方法

客户端向网页注入方法，首先需要创建一个方法的实现类，下面就是向网页注入名为sayHello的方法，方法功能是弹出alert，标题通过网页指定，注意：sayHello方法是在异步线程执行的，如下所示：

```objective-c
@interface YTKAlertHandler : NSObject

@end

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
```
然后客户端向网页注入该方法类即可，下面就是向网页注入YTKAlertHandler，代码如下：

```objective-c
UIWebView *webView = [UIWebView new];
// webView加载代码省略...
YTKJsBridge *bridge = [[YTKWebViewJsBridge alloc] initWithWebView:webView];
// 向JS注入在命名空间yuantiku之下的sayHello方法
[bridge addJsCommandHandlers:@[[YTKAlertHandler new]] namespace:@"yuantiku"];
```

网页调用客户端注入的方法，下面就是网页调用客户端来异步执行yuantiku命名空间下的sayHello方法的代码，客户端注入的sayHello方法需要title参数，如下所示：

```JavaScript
// 准备要传给客户端的数据，包括指令，数据，回调等，
var data = {
    methodName:"yuantiku.sayHello", // 带有命名空间的方法名
    args:{title:"hello world"},  // 参数
    callId:123  // callId为-1表示同步调用，否则为异步调用
};
// 直接使用这个客户端注入的全局YTKJsBridge方法调用yuantiku命名空间下的sayHello方法执行
YTKJsBridge(data);
```
客户端调用网页JS方法，直接调用YTKWebViewJsBridge的对象方法即可，下面就是客户端调用网页执行名为alert的JS方法，带有三个参数message，cancelTitle，confirmTitle，分别代表alert提示的文案、取消按钮文案、确认按钮文案，如下所示：

```objective-c
UIWebView *webView = [UIWebView new];
// webView加载代码省略...
YTKJsBridge *bridge = [[YTKWebViewJsBridge alloc] initWithWebView:webView];
// 准备传入JS的数据，包括指令，数据等
NSDictionary *parameter = @{@"message" : @"hello, world",
                        @"cancelTitle" : @"cancel",
                       @"confirmTitle" : @"confirm"};
// 客户端调用网页的alert方法，弹出alert弹窗
[bridge callJsCommandName:@"alert" argument:@[parameter]];
```

## 作者

YTKJsBridge 的主要作者是：

lihc， https://github.com/xiaochun0618

## 协议

YTKJsBridge 被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息。

