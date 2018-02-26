title: 常见问题
type: guide
order: 15
---

## 为什么命名为熊猫

熊猫这个名字好记, 当然也叫 `panda` , 是中国的国宝, 也寓意人虽小却能做大事.


## Bearcat是创建了一套新的模块系统么

Bearcat提供的是依赖注入, 而不是新的模块系统. 依赖注入其实是基于模块系统的, 但是模块系统使用 `require` , `exports` 这样的语句去管理依赖, 模块可以是任何一个合法的JavaScript.

依赖注入(DI)是一个程序凭借对象自己来定义自己依赖哪些其他对象来完成工作, 实现依赖注入只需要给构造方法或者工厂方法传递参数, 或者在通过构造方法或工厂方法实例化之后设置属性值, 就可以获取到依赖的对象. 容器在创建bean的时候将这些依赖注入其中.

Bearcat的基础核心是bean自身来控制所依赖的对象的位置和初始化流程, 而不再是通过指定文件位置(require)和手动初始化(new)对象, 因此称之为控制反转(IoC).

因此, 可以使用Bearcat于其他模块系统(例如 `browserify` )一起使用.


## 元数据配置 func 疑惑

1，func : bean 的构造函数

我测试发现这个名字必须和bean的文件名一模一样，大小写也一样才行，也就是说这个func其实就替代require('xxx')对吧？同时module.exports导出的必须是函数对吧？我开始看半天不知道这个构造函数是哪里来的。

2，func和factoryBean，factoryMethod 是什么关系？既然func和factoryBean都可以生成bean对象，那区别是什么？

#### 答

1：func 指向的确实是构造函数，在context.json里面配置的是 一个 字符串，因此就需要对应到具体的文件

除了在context.json里面定义之外，还可以直接写在 js 文件里面定义的，这时候的 func 就是一个 构造函数，这点可以参考 bearcat [配置风格](/guide/magic-javaScript-objects-in-details.html)

2：factoryBean factoryMethod 对应的是工厂模式，比如之前有一个非bearcat管理的js对象，那么你可以通过一个工厂方法来进行管理



## bearcat 依赖注入 疑惑

这个东东实际上就是一个存放全局变量（对象）的容器？而且这些全局变量的类型，名字，生成方法都是可以基于json配置的。用这个东西可以更好的管理对象，使用对象，通过配置达到一些解耦的效果。

但是我看了这个官方的例子又疑惑了：

```js
module.exports = function(app) {
    var bearcat = app.get('bearcat');
    return bearcat.getBean({
        id: "gateHandler",
        func: Handler,
        args: [{
            name: "app",
            value: app
        }]
    });
};

var Handler = function(app) {
    this.app = app;
};
```

这段代码是想让这个handler可以复用对吧？但是我觉得其实没有解耦啊。 第一，handler对象的生成依赖于app对象，添加到bearcat中也需要app对象 第二，bearcat对象自己本身如何在多个js文件中共享呢？这个例子是通过放到pomelo的app里面的。如果一个拿不到app对象的js文件里面，如何使用bearcat中已有的bean呢？

#### 答

1：第一个例子这么写，是因为pomelo里面的handler,remote是通过pomelo-loader管理加载的,bearcat要切入进来就需要一个proxy，这里通过bearcat.getBean返回了一个proxy，这个proxy当具体handler被调用时，会去实例化对应的handler，然后调用，这里面依赖的app完全是要兼容之前的代码而已。在这里handler一般是不复用的，当然也可以复用，这里主要复用的是service, util, consts等模块，复杂的例子可以看 [playerHandler](https://github.com/bearcatnode/treasures/blob/master/game-server/app/servers/area/handler/playerHandler.js#L129)

2：bearcat 对象共享可以看 [bearcat](https://github.com/bearcatnode/bearcat/blob/master/lib/bearcat.js#L31) 其实就是一个匿名对象，通过 require('bearcat') 的都是同一份

3：car 确实需要知道依赖的engine的run方法，但是解偶的一个是engine的文件位置，叫什么名字（engine甚至可以是一个remote对象），还有就是engine的实例生成，无需自己再new来进行实例化，这样子其实就是面向接口编程了，你只需要知道依赖的对象里面提供了什么接口即可，至于到底文件在什么位置，叫什么名字（require这两点是必须要知道的），什么时候实例化（有些时候需要单例，有些时候需要多例）都不用关心

这样做的一个比较显著的好处就是便于单元测试，可以方便的mock对象，并且无缝的切换

```js
var userService = require('../service/user-service');

exports.allUsers = function (req, res, next) {
  userService.getUsers(function (err, users) {
    if (err) {
      return next(err);
    }
    res.json(users);
  });
};
```

你这里要对controller进行单元测试，需要userService的一个mock对象，这里你是直接require的，这时你必须要么修改userService的代码，要么就是修改userController的代码，比如这样：

```js
//var userService = require('../service/user-service');
var userService = require('../service/mock-user-service');

exports.allUsers = function (req, res, next) {
  userService.getUsers(function (err, users) {
    if (err) {
      return next(err);
    }
    res.json(users);
  });
};
```

通过ioc的话，你只需要修改下配置，把userController依赖注入的对象换成mock-user-service即可，非常便捷



## POJO 开发与客户端代码贡献 疑惑

没有能直接加载json功能吗, 比如

```js
var code = {OK: 200, FAIL: 500};
module.exports = code;
```

不想按例子里要写成  `var code = function() {this.OK = 200}` , 因为这些code可能在客户端里也要

#### 答

bearcat 里面要求的是有构造函数的，不能直接这样子用匿名对象的

```js
var codeUtil = function() {
  this.code = {
    OK: 200,
    FAIL: 500
  };
};

module.exports = codeUtil;
```

按照你的需求，这样子写应该就行了吧