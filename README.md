# MRRouter

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jiaopen/MRRouter/blob/master/LICENSE.md)

## About
MRRouter以block的接口为基础，结合Objective-C的特性，提供了object和URL的映射关系，降低代码耦合。 

## Features
* API的设计很简单，功能相对齐全
* 映射结合了runtime自动映射，代码映射，plist文件配置映射
* 实现逻辑简单，调试方便
* url和object的映射关系做了大小写不敏感匹配

## Usage
###runtime自动映射：

比如创建了一个叫TestViewController的类，不需要注册任何URL，只需要配置好默认的执行block，调用
```objc
    [MRRouter openURL:@"scheme://test"];
```
即可打开对应的页面。默认执行代码需要实现这个属性，之后通过runtime映射的URL就会默认执行这个操作
```objc
    [MRRouter sharedInstance].defaultExecutingBlock = ^(id object, NSDictionary *parameters) {
        [self.navigationController pushViewController:object animated:YES];
    };
```

也可以注册特定的URL来实现特定的操作:
```objc
    [MRRouter registerURL:@"scheme://test2" executingBlock:^(NSString *sourceURL, NSDictionary *parameters) {
        //do sth.
    }];
```

支持参数解析和自定义参数传递，同时在下面这个例子中，对应的实例中如果定义了ccc和ddd名字的属性，将通过KVC自动赋值，实现跨页面参数传递：
```objc
    [MRRouter openURL:@"scheme://test3" parameters:@{@"ccc":@"333",@"ddd":@"444"}];
```

也可以直接获取到URL映射的类：
```objc
    + (Class)matchClassWithURL:(NSString *)URLPattern;
```



## Requirements
iOS 7.0+.

## License
MRRouter is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).
