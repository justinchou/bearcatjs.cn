title: $命名的变量依赖注入
type: guide
order: 7
---

## 概述

通过配置文件描述的依赖注入在使用起来比较繁琐, 开发者在描述依赖关系时, 需要不断的对配置文件进行修改, 当配置文件里面的beans数量增多的时候, 修改起来就比较麻烦了, 而且很容易出现问题.

解决的办法一种就是把配置转移到POJO内部, 比如:

基于代码的元数据配置

car.js

```js
var Car = function() {};

Car.prototype.run = function() {
	console.log('run car...');
	return 'car';
};

// func is the constructor function
module.exports = {
	id: "car",
	func: Car
};
```

这种虽然可以解决维护配置文件的问题, 但是强制要求exports必须是一个配置对象, 间接的就要求与bearcat耦合, 没有bearcat情况下, 这种方式编写的代码就很难跑起来.




## 基于$命名的变量名描述配置


### 快速起步

通过在POJO的构造函数里面以$开头命名的变量作为依赖注入描述, 使用起来就和编写普通对象属性是一样的, 只是前面加了一个 $

car.js

```js
var Car = function($engine) {
	this.$id = "car";
	this.$scope = "prototype";
	this.$engine = $engine;
	this.$wheel = null;
};

Car.prototype.run = function() {
	this.$engine.run();
	var res = this.$wheel.run();
	console.log('run car...');
	return 'car ' + res;
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
    return 'engine';
};

module.exports = Engine;
```

wheel.js

```js
var Wheel = function() {
	this.$id = "wheel";
};

Wheel.prototype.run = function() {
	console.log('run wheel...');
	return 'wheel';
};

module.exports = Wheel;
```

car 通过 ***$engine*** 在构造函数里描述了一个基于构造函数的注入, ***$wheel*** 描述了基于对象属性的依赖注入

$id 描述了POJO在bearcat里的唯一id

$scope 描述了POJO的作用域


### 使用方法

* bean配置直接加上 $ 前缀即可, 可配置的bean属性有:

    id
    order
    init
    destroy
    factoryBean
    factoryMethod
    scope
    async
    abstract
    parent
    lazy
    factoryArgs
    proxy
    aop

详解参见 [JavaScript魔法对象详解](/guide/magic-javaScript-objects-in-details.html

* 基于构造函数的依赖注入描述 在构造函数列表里, 加上了 `$` 前缀的则表示依赖注入一个 ***bean*** , `$` 后面的则是bean的 `id` , 没有 `$` 前缀的则表示注入一个  ***变量*** , 注入一个 ***值*** 是不支持的

    var Car = function($engine, num) {
            
    }
    
* 基于对象属性的依赖注入描述 在构造函数对象属性里面, 加上了 `$` 前缀的则表示依赖注入一个 ***bean***, `$` 后面的则是bean的 `id` , 加上了 ***$V*** 前缀的则表示注入一个值, 没加前缀的则是一个普通的自定义属性

    var Car = function() {
        this.$id = "car";
        this.$engine = null;
    }
    
***注:***

1: 当对象属性里面的 ***$*** 前缀变量已经在构造函数列表里面出现的时候, 则表示是通过构造函数依赖注入的

    var Car = function($engine) {
    	this.$engine = $engine; // 通过构造函数依赖注入
    }
    
2: 需要注入一个namespace的bean, 则使用 ***$N*** 为前缀的命名

    this.$Ncar = "app:car";
    
3. 这时$后面的变量字符串不再代表bean id, 具体ref的bean的id定义在右边的等号后面, 使用namespace:bean id描述

## 参考

[$命名注入配置例子](https://github.com/bearcatnode/bearcat/tree/master/examples/simple_function_annotation)

[bearcat-todo](https://github.com/bearcatnode/todo/tree/funcAnnotation)

## 注意

使用 process.env.BEARCAT_ANNOTATION = 'off'; 关闭bearcat对function $注解的支持

