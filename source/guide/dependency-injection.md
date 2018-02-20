title: 控制反转(IoC)容器与依赖注入(DI)
type: guide
order: 3
---

## 容器概览

控制反转(IoC)是一个设计模式, 记录组件的依赖、配置与生命周期. 控制反转是好莱坞原则'别找我, 直到我找你'的最佳实践. Bearcat中IoC的实现基于依赖注入(DI), 组件依赖不是通过查找实现, 而是在容器中通过简单的配置来解析依赖. 容器为组织组件全权负责, 向JavaScript对象属性值或者构造方法提供构造好的依赖对象. Bearcat使用基础的 ***beanFactory*** 和高级的 ***applicationContext*** 来实现容器.

## 配置标记

Configuration metadata is the key point for developers to tell the Bearcat container to instantiate, configure, and assemble the objects in your application.  
In bearcat, configuration metadata is embeded into javaScript objects with some syntax sugars as showed below.   

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

``` html
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

In Bearcat, instantiation with a constructor is quite easy, with self-described configuration metadata you can specify your bean class as follows:  

```js
var Bean = function() {
    this.$id = "beanId";
};
  
module.exports = Bean;
```

### 使用工厂方法实例化

To use this mechanism, add the ***factoryBean*** attribute, specify the name of a bean in the current container and the instance method that is to be invoked to create the Object. 
Set the name of the factory method itself with the ***factoryMethod*** attribute.  

使用此装置, 增加 ***factoryBean*** 属性, 指定当前容器中一个单例bean的名字, 增加 ***factoryMethod*** 属性, 指定该单例中的方法, 作为创建此对象时的回调方法. 

```js
var Car = function() {
    this.$id = "car";
    this.$factoryBean = "carFactory";
    this.$factoryMethod = "createCar";
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

## 依赖

Dependency injection (DI) is a process whereby objects define their dependencies, that is, the other objects they work with, only through constructor arguments, arguments to a factory method, or properties that are set on the object instance after it is constructed or returned from a factory method. The container then injects those dependencies when it creates the bean. This process is fundamentally the inverse, hence the name Inversion of Control (IoC), of the bean itself controlling the instantiation or location of its dependencies on its own by using direct construction of classes, or the Service Locator pattern.  
Code is cleaner with the DI principle and decoupling is more effective when objects are provided with their dependencies. The object does not look up its dependencies, and does not know the location or class of the dependencies. As such, your classes become easier to test, in particular when the dependencies are on interfaces or abstract base classes, which allow for stub or mock implementations to be used in unit tests.  

依赖注入(DI) 

DI exists in two major variants, [Constructor-based dependency injection](#Constructor-based_dependency_injection) and [Properties-based dependency injection](#Properties-based_dependency_injection).  

### Constructor-based dependency injection
Constructor-based DI is accomplished by the container invoking a constructor with a number of arguments, each representing a dependency.  
car.js
```js
// the Car has a dependency on an Engine
// a constructor so that the Bearcat container can inject an Engine
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

Besides inject a bean into the constructor, you can specify to inject ***variable*** into the constructor.  

inject ***variable*** example:  

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

main.js
```js
var car = bearcat.getBean('car', 100);
car.run(); // car 100
``` 

use the attribute with the prefix ***$T*** to specify the ***variable*** to be injected into the constructor with the argument named ***num***  

main.js
```js
var car = bearcat.getBean('car', 100);
car.run(); // car 100
``` 

### Properties-based dependency injection
Properties-based DI is accomplished by the container setting properties dynamicly.  
car.js
```js
// the Car has a dependency on an Engine
// in constructor specify the engine properties to null for V8 optimization
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

you can also specify to inject ***value*** into the properties from configuration files for example.  

inject value example:  
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
```js
{
    "car.num": 100
}
```

main.js
```js
var car = bearcat.getBean('car');
car.run(); // car 100
``` 

Note: there is no need for Properties-based dependency injection to inject ***variable*** type into the properties  

## Bean scopes
When you create a bean definition, you create a recipe for creating actual instances of the class defined by that bean definition. The idea that a bean definition is a recipe is important, because it means that, as with a class, you can create many object instances from a single recipe.  

You can control not only the various dependencies and configuration values that are to be plugged into an object that is created from a particular bean definition, but also the scope of the objects created from a particular bean definition.  

You can use ***scope*** attribute to specify the scope of the bean.  

### The singleton scope
Only one shared instance of a singleton bean is managed, and all requests for beans with an id or ids matching that bean definition result in that one specific bean instance being returned by the Bearcat container. The singleton beans will preInstantiate by default.  

By default, scope is singleton  
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

### The prototype scope
The non-singleton, prototype scope of bean deployment results in the creation of a new bean instance every time a request for that specific bean is made. That is, the bean is injected into another bean or you request it through a `getBean()` method call on the container. As a rule, use the prototype scope for all stateful beans and the singleton scope for stateless beans.  

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

## Customizing the nature of a bean
### Lifecycle callbacks
To interact with the container management of the bean lifecycle, you can add ***init*** and ***destroy*** method with the attribute ***init*** and  ***destroy*** .  

#### Initialization method
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

when car is requested by ***getBean*** invoke, init method will be called to do some init actions  

#### Destruction method
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

when the container is ready to stop, beans in the container will call ***destroy*** method if setted.  

#### Async Initialization method
In nodejs, almost everything is async, so async initialization is quite common.  
When async initialization is required, use the ***async*** attribute to specify a async initialization method and in the function method, call ***cb*** callback function to end the async init action.  
When multiple async initializations are required, use the ***order*** attribute to specify the order of the bean initialization.  

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

in this example, wheel has an async initialization method and must be init before car, so besides set the ***async*** attribute to true, should set the ***order*** attribute to to smaller than the car.  

## Bean definition inheritance
A bean definition can contain a lot of configuration information, including constructor arguments, property values, and container-specific information such as initialization method, static factory method name, and so on. A child bean definition inherits configuration data from a parent definition. The child definition can override some values, or add others, as needed. Using parent and child bean definitions can save a lot of typing. Effectively, this is a form of templating.  

In Bearcat, use the ***parent*** to specify the parent bean to inherit the bean definition.  
Besides bean definition inheritance, child bean will inherit methods from parent bean prototype which it does not have  

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

in this example, bus has a parent bean car, and it will inherit the bean definition from car, therefore, bus has the num with value of 100 which is inherited from car.  

## Abstract bean
When a bean is marked as an abstract bean, it is usable only as a pure template bean definition that servers as a parent definition for child definitions. It is abstract and can not be initialized by ***getBean*** method, you can get the abstract bean constructor function by ***bearcat.getFunction*** method to handle child inherition. Similarly, the container’s internal preInstantiateSingletons() method ignores bean definitions that are defined as abstract.  

## Bean namespace
bean can have `namespace` , by default the namespace is null, all beans can be requested through unique  `id` , when some beans specify to have a  `namespace` , it must be requested by  `namespace:id`  

the magic attribute for namespace is
  
```js
this.$Nid = "namespace:id";
```

in `context.json` , specify the  `namespace` attribute to set up namespace, and in `beans` attribute, set up which beans have the namespace  
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
you can refer to [context_namespace example](https://github.com/bearcatjs/bearcat/tree/master/examples/context_namespace) for more details

## Note
you can write $ based syntax sugars as you like, so the following is also ok  

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

a full example can be found on [complex_function_annotation](https://github.com/bearcatjs/bearcat/tree/master/examples/complex_function_annotation)