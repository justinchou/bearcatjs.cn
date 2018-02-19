title: 开始
type: guide
order: 2
---

## 简介

Bearcat是一个前后端通用JavaScript框架, 便于开发者编写魔术对象, 构建弹性、可维护的前后端JavaScript应用。框架提供基础的核心结构来管理对象，让开发者更专注于应用层逻辑内容。

Bearcat致力于使用更少的代码来构建复杂的世界。世界中物体以bearcat强大的依赖注入和切面编程的方式紧密连接在一起。

此外仅仅需要很少或者根本不需要配置就能运行。更神奇的是，配置内容也是基于JavaScript对象自己实现的。

Bearcat与其他前后端框架管理依赖的方式也不太一样，它不使用'define', 'require', 'exports'来解析依赖，仅仅只是原生的JavaScript对象自身就行。因此，代码可以在前端（浏览器）与后端（nodejs服务器）之间高度共享，而不需要任何代码的修改，也不需要任何中间件来解析。

Bearcat的前端依赖管理是异步加载的，AMD将使你着迷，每个页面使用不同的脚本，这使开发变得十分有趣，因为所见即所得，无需编译bundle，并且在出错的时候翻阅打包好的代码。

继续阅读并尽情尝试吧，相信你会在使用bearcat开发过程中找到乐趣。  

## 概念概览

### JavaScript 魔法对象

JavaScript对象可以魔法化，不仅仅包含属性和方法，还可以包含DSL或者句法糖。Bearcat中，使用'$'定义句法糖。

```js
    var MagicJsObject = function() {
      this.$id = "magicJsObject";
    };
      
    MagicJsObject.prototype.doMethod = function() {};
```

这就是一个含有'$'开头属性的简单的对象.

```js
this.$id = "magicJsObject";
```

这段代码描述了类自己拥有名为'magicJsObject'的id, bearcat用此id来标记该类, 当其他人需要依赖该类的时候, bearcat将自动替你生成对象.

### 依赖注入

控制反转(IoC)是一个设计模式, 记录组件的依赖、配置与生命周期. 控制反转是好莱坞原则'别找我,直到我找你'的最佳实践. Bearcat中IoC的实现基于依赖注入(DI), 组件依赖不是通过查找实现, 而是在容器中通过简单的配置来解析依赖. 容器为组织组件全权负责, 向JavaScript对象属性值或者构造方法提供构造好的依赖对象. 

### 面向切面编程

面向切面编程(AOP)提供一种完全不同的程序架构来实现面向对象编程(OOP). OOP编程的核心模块单元是基于class类实现的, 但是AOP中模块单元是aspect切面. Aspects enable the modularization of concerns such as transaction management that cut across multiple types and objects. (Such concerns are often termed crosscutting concerns in AOP literature.)

### 一致配置  

Node.js开发中, 设置不同的环境是很普遍的事情, 比如development, test, production等等. 不同环境的实现是这些配置文件内容不同. 然而有必要让这些配置文件保持一致.

## 一个栗子🌰

编写简单的JavaScript对象, 将这些对象的文件放在文件夹`app`中, 用于被bearcat扫描.

car.js  
``` js
var Car = function() {
  this.$id = "car";
  this.$wheel = null;
  this.$engine = null;
}  
  
Car.prototype.run = function() {
  this.$wheel.run();
  this.$engine.run();
  console.log('run car...');
}  
  
bearcat.module(Car, typeof module !== 'undefined' ? module : {});
```

engine.js
``` js
var Engine = function() {
  this.$id = "engine";
}  
  
Engine.prototype.run = function() {
  console.log('run engine...');
}  
  
bearcat.module(Engine, typeof module !== 'undefined' ? module : {});
```

wheel.js
``` js
var Wheel = function() {
  this.$id = "wheel";
}  
  
Wheel.prototype.run = function() {
  console.log('run wheel...');
}  
  
bearcat.module(Wheel, typeof module !== 'undefined' ? module : {});
```

上面的代码car依赖于engine和wheel, car使用`this.$wheel`来依赖wheel, `this.$engine`来依赖engine.

使用`bearcat.module`将以上所有代码注册到bearcat中, 前后端通用.

然后添加简单的`context.json`文件来指定bearcat的扫码目录:

context.json  
``` json
{
  "name": "bearcat-simple-example",
  "scan": ["app"]
}
```

将程序打包, 运行起来吧!

### 在前段浏览器使用
index.html
```
<!DOCTYPE html>
<html lang="en-us">
  <head>
    <title>bearcat browser examples</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body>
    <h2>bearcat simple example</h2>
    <script src="./lib/bearcat.js"></script>
    <script src="./bearcat-bootstrap.js"></script>
    <script type="text/javascript">
    bearcat.createApp();   // 创建bearcat对象
    bearcat.use(['car']);  // 需要用到的对象
    bearcat.start(function() {
        // 当进入这个回调时候, 所有需要加载的一切已经就绪
        var car = bearcat.getBean('car');
        car.run(); 
    });
    </script>
  </body>
</html>
```

`bearcat-bootstrap.js`是自动生成的, 这个文件自动异步加载需要加载的JavaScript代码, 更详尽的内容请参考 [bearcat-bootstrap.js 部分](/guide/bearcat-bootstrap.html)

### 在后端nodejs服务器使用

app.js
```
var bearcat = require('bearcat');

var contextPath = require.resolve('./context.json');

global.bearcat = bearcat; // make bearcat global, for `bearcat.module()`
bearcat.createApp([contextPath]);

bearcat.start(function() {
  var car = bearcat.getBean('car'); // 获取一辆车
  car.run(); // 调用车的奔跑方法
});
```

正如所见, nodejs本身就是异步加载文件, 所以无需bearcat-bootstrap.js文件, 只需要配置'context.json'即可令bearcat自动分析, 完成依赖注入, 将JavaScript对象为你自动准备好.

完整的代码可以在 [这里](https://github.com/bearcatjs/bearcat-examples) 找到, 尽情玩耍吧!
