# YTKJsBridge

[![CI Status](https://img.shields.io/travis/lihc/YTKJsBridge.svg?style=flat)](https://travis-ci.org/yuantiku/YTKJsBridge-iOS)
[![Version](https://img.shields.io/cocoapods/v/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)
[![License](https://img.shields.io/cocoapods/l/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)
[![Platform](https://img.shields.io/cocoapods/p/YTKJsBridge.svg?style=flat)](https://cocoapods.org/pods/YTKJsBridge)

## YTKJsBridge 是什么

YTKJsBridge是基于OC语言实现的一套客户端与网页JS相互调用的iOS库，其中主要依赖JavaScriptCore、UIWebView来实现的，JavaScriptCore这个framework被广泛使用在JSPatch、RN等上面。

## YTKJsBridge 提供了那些功能

 * 支持客户端向网页动态注入OC实现的方法，并支持命名空间。
 * 支持双向事件监听机制。
 * 支持网页以同步、异步方式调用客户端注入的OC方法。
 * 支持网页调用客户端注入的OC方法的时候，直接以json格式数据作为参数，无需序列化。
 * 支持客户端主动调用网页提供的JavaScript方法。

## 哪些项目适合使用 YTKJsBridge

YTKJsBridge 适合ObjectC实现的项目，并且项目中使用UIWebView作为网页的容器，并且有比较多的客户端与网页直接交互的需求。

如果你的项目中使用了UIwebView，并且有大量的客户端与网页的交互逻辑，使用YTKJsBridge将给你带来很大的帮助，简化客户端与网页交互的实现逻辑，并且交互都是同步的，与本地调用基本一样，提供交互效率。

## YTKJsBridge 的基本思想

YTKJsBridge 的基本思想是把一个或多个JS注入方法的实现放到一个实现了类里面，并且同一个命名空间可以注册多个方法实现类，所以使用YTKJsBridge，你的一个或多个相关的注入方法，可以放到单独的类进行管理，并支持命名空间，也就是说多个注入方法实现类可以有同名方法。

YTKJsBridge 会向网页注入一个名为YTKJsBridge的全局方法，后续所有需要向YTKJsBridge注入的方法，都是通过这个全局方法来调用执行的，后面使用方法中有具体的例子。

同时也支持以block的形式作为方法实现注入JS方法。

把一个或多个注入方法的实现放到一个类里面，有如下好处：
 * 天然将一类相关的注入方法实现都放在一个类中进行管理，可以避免注入方法四散到项目的各个地方又可能出现重复代码的问题。
 * 可以避免将所有的注入方法都放到一个类中实现，导致文件过长逻辑产生交叉，增加后续的维护成本。

YTKJsBridge 提供了事件监听处理的机制，在原有JS方法注入的基础上进行抽象，简化了数据回传处理。

当然，如果说他有什么不好，那就是你的工程以及网页都需要使用YTKJsCommand定义的json结构进行数据传递，但是YTKJsCommand本身就是一个定义比较宽松的结构。

## 安装

你可以在Podfile中加入下面一行代码来使用YTKJsBridge

```ruby
pod 'YTKJsBridge'
```
## 安装要求

   | YTKJsBridge 版本 |  最低 iOS Target | 注意 |
   |:----------------:|:----------------:|:-----:|
   | 0.1.3 | iOS 7 | 要求 Xcode 7 以上 |

## 例子

clone当前repo， 到Example目录下执行`pod install`命令，就可以运行例子工程

## 数据格式说明

JS调用客户端的数据格式如下：

```JavaScript
{
    "methodName": "math.fib" // 方法名，math是命名空间，fib为具体方法名
    "args": {key1: value1, key2: value2, ...} // 参数字典
    "callId": xxx // 同步为-1， 异步为非-1
}
```

客户端通过调用JS的全局方法dispatchCallbackFromNative向JS回传数据，数据以json序列化的字符串传递，数据格式如下：

```JavaScript
{
    "callId": xxx, // 同步调用callId为-1，异步调用不是-1，用以标记回传与调用的对应关系
    "code": 0, // 非0表示失败
    "ret": object, // 回传数据
    "message": "", // 错误描述
}
```

客户端通过调用JS的全局方法dispatchNativeCall调用JS，数据以json序列化的字符串传递，数据格式如下：

```JavaScript
{
    "methodName": "", // js方法名
    "args": [], // 参数数组
    "callId": xxx,
}
```

客户端监听JS的事件，数据以字典形式传递，数据格式如下：

```JavaScript
{
    "event": "", // event名
    "arg": , // 参数，可以是任意格式，字典、数组、字符串、数字、BOOL等
}
```

JS监听客户端的事件，数据以json序列化的字符串传递，json数据格式与JS事件格式一致

## 使用方法

### 向JS注入方法

客户端以block的形式向网页注入方法，例如：注入命名空间math下的同步方法fib和异步方法asyncFib，用来计算斐波那契数列，注意：方法是在异步线程执行的，具体如下:

```objective-c
// 斐波那契数列
- (NSInteger)fibSequence:(NSInteger)n {
    if (n < 2) {
        return n == 0 ? 0 : 1;
    } else {
        return [self fibSequence:n - 1] + [self fibSequence:n -2];
    }
}

UIWebView *webView = [UIWebView new];
// webView加载代码省略...
YTKJsBridge *bridge = [[YTKWebViewJsBridge alloc] initWithWebView:webView];

// 向JS注入在命名空间math之下的同步方法fib
[bridge addSyncJsCommandName:@"fib" namespace:@"math" handler:(id)^(NSDictionary *argument) {
    NSInteger n = [[argument objectForKey:@"n"] integerValue];
    return @([self fibSequence:n]);
}];

// 向JS注入在命名空间math之下的异步方法asyncFib
[bridge addAsyncJsCommandName:@"asyncFib" namespace:@"math" handler:^(NSDictionary *argument, YTKDataBlock block) {
    NSInteger n = [[argument objectForKey:@"n"] integerValue];
    block(nil, @([self fibSequence:n]));
}];

```

为了避免客户端的代码以block的形式注入会比较分散，YTKJsBridge提供以对象的形式向JS注入方法。
首先需要创建一个方法的实现类，下面就是向网页注入在命名空间math下的同步fib以及异步asyncFib的方法例子，方法功能是计算斐波那契数列，如下所示：

```objective-c
@interface YTKFibHandler : NSObject

@end

@implementation YTKFibHandler

// fibSequence的实现忽略，与前面demo代码实现一致
// 同步方法fib
- (NSNumber *)fib:(NSDictionary *)argument {
    NSInteger n = [[argument objectForKey:@"n"] integerValue];
    return @([self fibSequence:n]);
}

// 异步方法asyncFib，带有异步方法回调completion
- (void)asyncFib:(NSDictionary *)argument completion:(YTKDataBlock)completion {
    NSInteger n = [[argument objectForKey:@"n"] integerValue];
    completion(nil, @([self fibSequence:n]));
}
@end
```
然后客户端向网页注入该方法类即可，下面就是向网页注入YTKFibHandler，代码如下：

```objective-c
UIWebView *webView = [UIWebView new];
// webView加载代码省略...
YTKJsBridge *bridge = [[YTKWebViewJsBridge alloc] initWithWebView:webView];
// 向JS注入在命名空间yuantiku之下的sayHello方法
[bridge addJsCommandHandlers:@[[YTKFibHandler new]] namespace:@"math"];
```

### JS调用native注入的方法

下面就是网页调用客户端来异步执行math命名空间下的asyncFib方法的代码，客户端注入的asyncFib方法需要参数n，如下所示：

```JavaScript
// 准备要传给客户端异步方法asyncSayHello的数据，包括指令，数据，回调等，
var data = {
    methodName:"math.asyncFib", // 带有命名空间的方法名
    args:{n: 5},  // 参数
    callId:123  // callId为-1表示同步调用，否则为异步调用
};
// 直接使用这个客户端注入的全局YTKJsBridge方法调用math命名空间下的asyncFib方法执行
YTKJsBridge(data);
// 通过dispatchCallbackFromNative来接收回传数据
```

下面就是网页调用客户端来同步执行math命名空间下的fib方法的代码，客户端注入的fib方法需要参数n，如下所示：

```JavaScript
// 准备要传给客户端同步方法syncSayHello的数据，包括指令，数据，回调等，
var data = {
    methodName:"math.fib", // 带有命名空间的方法名
    args:{n: 8},  // 参数
    callId:-1  // callId为-1表示同步调用，否则为异步调用
};
// 直接使用这个客户端注入的全局YTKJsBridge方法调用math命名空间下的fib方法执行
var dict = YTKJsBridge(data);
var fib = dict["ret"]; // fib就是客户端返回的结果
```

### native调用JS方法

直接调用YTKWebViewJsBridge的对象方法即可，下面就是客户端调用网页执行名为alert的JS方法，带有三个参数message，cancelTitle，confirmTitle，分别代表alert提示的文案、取消按钮文案、确认按钮文案，如下所示：

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

### JS向native发送事件通知

JS发送页面大小发生变化resize事件给客户端，如下所示：

```JavaScript
var event = {
    "event": "resize", // event名
    "arg": {"width": xxx, "height": xxx}, // 参数
};
sendEvent(event); // sendEvent是native注入的全局函数
```

### native监听JS事件

下面例子就是客户端监听JS页面大小发生变化resize事件的例子，如下所示：

```objective-c
UIWebView *webView = [UIWebView new];
// webView加载代码省略...
YTKJsBridge *bridge = [[YTKWebViewJsBridge alloc] initWithWebView:webView];

// 便捷block方式
[bridge listenEvent:@"resize" callback:^(id argument) {
    // 客户端监听js页面大小发生变化事件
}];

// 添加监听者对象id<YTKJsEventListener>的方式
[bridge addListener:self forEvent:@"resize"]
// 实现YTKJsEventListener代理方法
- (void)handleJsEventWithArgument:(id)argument {
    // 客户端监听js页面大小发生变化事件
}
```

### native向JS发送事件通知

下面例子就是客户端发送close事件的例子，如下所示：

```objective-c
UIWebView *webView = [UIWebView new];
// webView加载代码省略...
YTKJsBridge *bridge = [[YTKWebViewJsBridge alloc] initWithWebView:webView];
[bridge notifyEvent:@"close" argument:@"close page event"];
```

### JS监听native事件

下面例子就是JS监听客户端close事件的例子，如下所示：

```JavaScript
// obj是native传入的event事件对象，dispatchNativeEvent是用来处理事件的全局函数
window.dispatchNativeEvent = function(obj) {
    if (obj.event == "close") {
        // 处理close事件，这里通过alert将arg显示出来
        alert(obj.arg);
    }
}
```
## 作者

YTKJsBridge 的主要作者是：

lihc， https://github.com/xiaochun0618

## 协议

YTKJsBridge 被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息。

