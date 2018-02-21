title: 控制反转(IoC)容器与依赖注入(DI)
type: guide
order: 3
---

## 容器概览

控制反转(IoC)是一个设计模式, 记录组件的依赖、配置与生命周期. 控制反转是好莱坞原则'别找我, 直到我找你'的最佳实践. Bearcat中IoC的实现基于依赖注入(DI), 组件依赖不是通过查找实现, 而是在容器中通过简单的配置来解析依赖. 容器为组织组件全权负责, 向JavaScript对象属性值或者构造方法提供构造好的依赖对象. Bearcat使用基础的 ***beanFactory*** 和高级的 ***applicationContext*** 来实现容器.

## 配置meta标记

配置meta标记是开发者告诉Bearcat容器如何初始化、配置以及组装对象到应用程序的关键点. Bearcat允许配置标记以语法糖出现在JavaScript对象属性中, 如下所示: 

```js
var JsObject = function() {
    this.$id = "jsObject";
};
  
bearcat.module(JsObject, typeof module !== 'undefined' ? module : {});
```

这样的JavaScript对象也被称为 ***bean*** .

属性值"jsObject"(首字母小写)为字符串的 ***$id*** 属性, 用于标记 bean 的唯一性.  ***JsObject*** (首字母大写) 将作为该bean的构造方法通过bearcat的api(前端浏览器)或'module.exports'(后端nodejs服务器)注册到bearcat中. 
  
```js
bearcat.module(JsObject, typeof module !== 'undefined' ? module : {});
```

代码在前后端通用

```js
bearcat.module(Function, Module);
```

```js
var JsObject = function() {
    this.$id = "jsObject";
};
  
module.exports = JsObject;
```

## 初始化容器

初始化容器很简单, 直接定义好的 ***context.json*** 路径传递给工厂方法 ***bearcat.createApp*** (后端nodejs服务器)或者使用自动生成的 ***bearcat-bootstrap.js*** 文件(前端浏览器)异步加载.

### 前端浏览器

```html
<script src="./lib/bearcat.js"></script>
<script src="./bearcat-bootstrap.js"></script>
<script type="text/javascript">
bearcat.createApp();
bearcat.start(function() {
    console.log('bearcat 控制反转容器启动了!');
});
```

### 后端nodejs服务器

```js
var bearcat = require('bearcat');
var configPaths = ['path/to/context.json'];

bearcat.createApp(configPaths);
bearcat.start(function() {
    console.log('bearcat 控制反转容器启动了!');
});
```

## 如何使用容器

当容器启动后, 只需使用 ***getBean*** 方法即可获取bean的实例

```js
var bearcat = require('bearcat');
var configPaths = [require.resolve('relative/path/to/context.json')];

bearcat.createApp(configPaths);
bearcat.start(function() {
    console.log('bearcat 控制反转容器启动');
    var dog = bearcat.getBean('dog');
    dog.bite(); // 调用 bite 方法
});
```

## Bean 概览

Bearcat的控制反转中维护的JavaScript对象称之为  ***Beans*** . bean依据提供给容器的配置标记而创建.

## 实例化beans

bean本质上就是定义好的创建对象的配方, 当需求一个对象时, 容器依据提供的名称依据配方查找类, 然后依据类定义的配置标记去创建/引用实际的对象.

### 使用constructor实例化

使用构造方法来实例化对象很简单, 通过自描述的语法糖meta标记来定义bean即可.

```js
var Bean = function() {
    this.$id = "beanId";
};
  
module.exports = Bean;
```

### 使用工厂方法实例化

使用此装置, 增加 ***factoryBean*** 属性, 指定当前容器中一个单例bean的名字, 增加 ***factoryMethod*** 属性, 指定该单例中的方法, 作为创建此对象时的回调方法. 

```js
var Car = function() {
    this.$id = "car";
    this.$factoryBean = "carFactory";       // 工厂类id
    this.$factoryMethod = "createCar";      // 工厂类中, 用于创建本对象的方法名
};
  
module.exports = Car;
```

carFactory.js

```js
var Car = require('./car');

var CarFactory = function() {
    this.$id = "carFactory";
};
  
CarFactory.prototype.createCar = function() {
    console.log('CarFactory createCar...');
    return new Car();
};
  
module.exports = CarFactory;
```

### 延迟实例化
  
默认情况下, 项目进程初始化的时候将创建和配置所有的单例bean, 一般情况下, 这种提前初始化是必要的, 因为配置或周遭环境的问题将被及时的发现, 而不是几小时后或者几天后才被发现. 当你不需要此特性的时候, 你可以通过 `$lazy` 指定该bean不在运行时就初始化, 而在该bean首次被引用的时候初始化. 

修改 ***$lazy*** 属性以达到延迟初始化的目的:  

```js
var Car = function() {
    this.$id = "car";
    this.$lazy = true;
};
  
module.exports = Car;
```

或者定义 context.json

```json
{
"name": "simple_lazy_init",
"beans": [{
    "id": "car",
    "func": "car",
    "lazy": true
}]
}
```


## 依赖

依赖注入(DI), 是这样一个过程: 对象定义好自己的依赖关系, 也就是那些所需要依赖的对象, 通过构造函数参数, 工厂方法, 或者是对象创建好后的属性. 然后, 容器根据对象的依赖定义, 把对象所依赖的对象一一注入到对象中去. 这整个过程与一般的处理方式相反, 对象对于依赖并不是主动的去创建, 而是把这一责任交给了容器来完成, 通过容器来完成了控制的反转(IoC), 对象本身不负责依赖的创建工作, 它只是向容器描述清楚自己所需要的依赖, 之后的事情, 就全交给容器来完成了.
通过DI代码会变得更加清晰明了, 代码之间的耦合也会更加松散. 对象不必要自己去寻找依赖, 把依赖先require进来, 然后实例化, 也就无需要知道依赖所处的位置(require的时候, 数好文件夹有几层, 文件叫什么名字).

DI 有两种方式, [基于构造函数的依赖注入](#基于构造函数的依赖注入) 和 [基于对象属性的依赖注入](#基于对象属性的依赖注入)

### 基于构造函数的依赖注入

#### 注入一个bean对象的例子:

基于构造函数的依赖注入, 容器通过构造函数所表达的依赖关系, 调用构造函数来完成的.

car.js

```js
// Car 的$engine属性依赖于 Engine
// Car 有一个$engine参数, 以便于Bearcat容器注入一个Engine
var Car = function($engine) {
    this.$id = "car";
    this.$engine = $engine;
};
  
Car.prototype.run = function() {
    console.log('run car...');
    this.$engine.run();
};
  
module.exports = Car;
```

engine.js

```js
var Engine = function() {
    this.$id = "engine";
};
  
Engine.prototype.run = function() {
    console.log('run engine...');
};
  
module.exports = Engine;
```


#### 注入 ***value*** 例子:

car.js

```js
var Car = function(num) {
	this.num = num;
};

Car.prototype.run = function() {
	console.log('run car...');
	return 'car ' + this.num;
};

module.exports = Car;
```

context.json

```json
{
	"name": "simple_args_value",
	"beans": [{
		"id": "car",
		"func": "car",
		"args": [{
			"name": "num",
			"value": 100
		}]
	}]
}
```

main.js

```js
var car = bearcat.getBean('car');
car.run(); // car 100
```


#### 注入 ***variable*** 例子:

除了可以通过构造函数注入另一个bean对象之外, 还可以在构造函数中注入 ***variable*** (变量, getBean 调用时可以传入具体参数)

car.js  

```js
var Car = function(num) {
    this.$id = "car";
    this.$Tnum = num;
};
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.$Tnum;
};
  
module.exports = Car;
```

使用 ***$T*** 开头的变量指定 ***variable*** 是可以通过给构造函数传递 ***num*** 参数被注入的.

main.js

```js
var car = bearcat.getBean('car', 100);
car.run(); // car 100
```



### 基于对象属性的依赖注入

#### 注入一个bean对象的例子:

基于对象属性的依赖注入是通过容器动态的对象属性进行设置来完成(这在node.js中非常容易).

car.js

```js
// Car 的$engine属性依赖于 Engine
// 在构造方法中给$engine属性赋值为null, 让V8引擎对其自动优化
var Car = function() {
    this.$id = "car";
    this.$engine = null;
};
  
Car.prototype.run = function() {
    console.log('run car...');
    this.$engine.run();
};
  
module.exports = Car;
```

engine.js

```js
var Engine = function() {
    this.$id = "engine";
};
  
Engine.prototype.run = function() {
    console.log('run engine...');
};
  
module.exports = Engine;
```


#### 注入 ***value*** 例子:

同 [基于构造函数的依赖注入](#基于构造函数的依赖注入) 一样, 你可以从配置文件中注入 ***value*** 到 properties 中.

car.js

```js
var Car = function() {
    this.$id = "car";
    this.$Vnum = "{car.num}";
};
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.$Vnum;
};
  
module.exports = Car;
```

car.json

```json
{"car.num": 100}
```

main.js

```js
var car = bearcat.getBean('car');
car.run(); // car 100
```

注: 对于基于 Properties 的依赖注入来说, 注入 ***variable*** 就没什么必要了, 因为variable注入必然要通过构造函数的参数形式传入其中.

## 个人理解

[基于构造函数的依赖注入](#基于构造函数的依赖注入): 就是在构造函数上面增加参数, 以$开头的参数为Bean注入, 非$开头的可以是value注入(在context.json中配置value值), 也可以是variable注入(调用getBean的时候传进去).

[基于对象属性的依赖注入](#基于对象属性的依赖注入): 构造函数上不加参数, 使用构造函数内属性$语法糖. 除了保留字之外, $开头的将解析为对象的实例; 还可以使用占位符直接将值注入到对象中.


## Bean 的 scopes

创建Bean类时, 实际是创建了一个能实例化类的途径. 在脑海中强化bean是一个能实例化类的途径这个概念非常重要, 因为这意味着可以通过一个定义好的与类一一对应的bean创建很多对象.

你不仅可以控制依赖和配置的多样性(这些依赖和配置可以被注入到一个由特殊bean定义来创建的对象), 也可以控制由特殊bean定义创建的对象的范围.

通过bean的定义, 不仅仅可以定义不同的依赖和配置信息, 还可以定义bean的作用范围(scope).

可以通过 ***scope*** 属性来定义bean的作用范围

### 单例 Scope

仅仅只有一份单例bean的实例, 所有的对名叫id的bean的请求都返回同一个bean实例. 单例的bean默认会预创建在容器启动的时候.

默认情况下, 作用范围就是 singleton(单例)

```js
var Car = function() {
    this.$id = "car";
    this.$scope = "singleton"; // default, no need to set it up
};
  
module.exports = Car;
```

main.js

```js
var car1 = bearcat.getBean('car');
var car2 = bearcat.getBean('car');
// car2 is exactly the same instance as car1
```

### 原型 Scope

原型(prototype)意味着每次对名叫id的bean的请求, 容器都会创建一个新的bean实例. 作为经验, `原型 Scope` 的bean适用于有状态的beans, 而`单例 Scope`适用于无状态的beans.

有人也称 prototype scope 为 `多例 Scope`.

```js
var Car = function() {
    this.$id = "car";
    this.$scope = "prototype";
};
  
module.exports = Car;
```

main.js
```js
var car1 = bearcat.getBean('car');
var car2 = bearcat.getBean('car');
// car2 is not the same instance as car1
```

## 定制Bean的生成与消亡逻辑

### 声明周期回调

添加对容器所管理的bean的生命周期回调, 可以通过使用 ***$init*** 和 ***$destroy*** 属性来添加 ***init*** 和 ***destroy*** 方法

#### 初始化init方法

car.js
```js
var Car = function() {
    this.$id = "car";
    this.$init = "init";
    
    this.num = 0;
};
  
Car.prototype.init = function() {
    console.log('init car...');
    this.num = 1;
    return 'init car';
};
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.num;
};
  
module.exports = Car;
```

当car被 ***getBean*** 调用请求时, ***$init*** 指定的方法(本例中为init方法)会被调用来做一些初始化的事情. 

#### 析构destroy方法

car.js

```js
var Car = function() {
    this.$id = "car";
    this.$destroy = "destroy";
};
  
Car.prototype.destroy = function() {
    console.log('destroy car...');
    return 'destroy car';
};
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car';
};
  
module.exports = Car;
```

当容器准备停止的时候, 如果bean设置了 ***$destroy*** 属性, 会在停止之前调用所有bean的 ***$destroy*** 指定的方法(本例中为destroy方法).

#### 异步初始化init方法

在Node中, 几乎都是异步的, 所以, 异步的init也是相当的普遍.

当异步init的时候, 使用 async 属性来标识该init方法是异步的, 并且在init方法里面, 调用 cb 回调函数来表示异步init方法的结束.

当有多个异步init方法的时候, 使用 order 属性来标识bean实例化的顺序, order 越小的越早实例化, 没有order属性的则实例化越晚.

car.js

```js
var Car = function() {
    this.$id = "car";
    this.$init = "init";
    this.$order = 2;
    this.num = 0;
};
  
Car.prototype.init = function() {
    console.log('init car...');
    this.num = 1;
    return 'init car';
};
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.num;
};
  
module.exports = Car;
```

wheel.js

```js
var Wheel = function() {
    this.$id = "wheel";
    this.$init = "init";
    this.$async = true;
    this.$order = 1;
};
  
Wheel.prototype.init = function(cb) {
    console.log('init wheel...');
    setTimeout(function() {
	    console.log('asyncInit setTimeout');
	    cb();
    }, 1000);
};
  
Wheel.prototype.run = function() {
    console.log('run wheel...');
    return 'wheel';
};
  
module.exports = Wheel;
```

在这个例子中, wheel 有一个异步init方法, 而且必须在 car 之前实例化, 因此除了要设置 async 属性为true之外, 还需要设置 order 属性比 car 的 order 的值要小.

## Bean 定义继承

bean 定义包含很多配置信息, 包含构造函数参数, 对象属性的值, 容器特定属性比如初始化init方法, 工厂方法等等. 一个子bean定义可以继承在父bean中的定义, 也可以覆盖一些值, 添加另外一些值. 使用bean定义继承可以节省很多事情, 这其实是模板的一种方式.

在Bearcat中, 使用 ***$parent*** 来指定父bean是谁, 以便继承bean定义(属性/方法/注入的内容...).

除了bean定义的继承, 子bean还会从父bean的prototype里面继承子bean所没有的方法.

bus.js

```js
var Bus = function(engine, wheel, num) {
    this.engine = engine;
    this.wheel = wheel;
    this.num = num;
}
  
Bus.prototype.run = function() {
    return 'bus ' + this.num;
}
  
module.exports = {
    func: Bus,
    id: "bus",
    parent: "car",
    args: [{
   	    name: "engine",
	    ref: "engine"
    }, {
	    name: "wheel",
	    ref: "wheel"
    }]
};
```

car.js

```js
var n = 1;

var Car = function(engine, wheel, num) {
    this.engine = engine;
    this.wheel = wheel;
    this.num = num;
    n++;
};
  
Car.prototype.run = function() {
    this.engine.start();
    this.wheel.run();
    console.log(this.num);
};

Car.prototype.stop = function() {
    this.engine.stop();
    this.wheel.stop();
    console.log("car stop...");
};

module.exports = {
    func: Car,
    id: "car",
    args: [{
	    name: "engine",
	    ref: "engine"
    }, {
	    name: "num",
	    value: 100
    }, {
	    name: "wheel",
	    ref: "wheel"
    }],
    order: 1
};
```

在这个例子中, bus 有一个父亲bean car, bus 会继承 car 的 bean 定义, 因此, bus 的 num 的值是100, 这个是从 car 继承而来的.

bus 也会拥有一个 从 car 继承过来的 stop 方法, 只不过这个方法还是会输出 'car stop...'; 

## 抽象 bean

当一个bean被标记为是抽象的, 意味着该bean的定义被作为子bean们的模板. 它是抽象的, 不能够被 ***getBean*** 方法调用得到bean实例, 你可以通过 ***bearcat.getFunction*** 方法得到bean的构造函数来处理子bean继承的问题. 类似的, 容器在通过内部 preInstantiateSingletons() 启动的时候也会忽略抽象的bean.

## Bean 命名空间

Bean可以有自己的命名空间, 默认是 `null`, 所有的bean都可以直接只用唯一的 `id` 来获取; 当给bean指定了 `namespace` 命名空间之后, 访问bean就必须使用 `namespace:id` 了.

注入其他命名空间中某个对象的到本类中的魔术语法糖为: 
  
```js
this.$Nxxx = "namespace:id";
```

其中 `$N` 为命名空间语法糖; xxxx为本类中自定义的变量名, 用于访问注入的对象; namespace为要注入的对象所在的命名空间名; id为要注入的对象在在对应命名空间中的$id.

在 `context.json` 中指定 `namespace` 属性来设置整个scan目录的命名空间; 在 `beans` 属性中指定 `namespace` 来设置bean的命名空间  

context.json

```json
{
    "name": "beans",
    "namespace": "app",
    "scan": "",
    "beans": [{
        "id": "car",
        "func": "car"
    }]
}
```

可以参考 [上下文中定义的命名空间](https://github.com/bearcatjs/bearcat/tree/master/examples/context_namespace) 具体了解命名空间.

## 写在后面

当使用 $ 语法糖属性的时候, 下面的写法均有效:  

```js
var Car = function() {
    this.$id = "car";
    
    this["$engine"] = null; // use []
    var wheelName = "$wheel";
    this[wheelName] = null; // use variable
};
  
Car.prototype["$light"] = null; // use variable in prototype
  
Car.prototype.run = function() {
    this.$engine.run();
    this.$light.shine();
    this.$wheel.run();
    console.log('car run...');
}
  
module.exports = Car;
```

具体可以参考 [复杂的语法糖属性](https://github.com/bearcatjs/bearcat/tree/master/examples/complex_function_annotation)