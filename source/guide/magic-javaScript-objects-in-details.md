title: JavaScript魔法对象语法糖详解
type: guide
order: 6
---

## 概览

配置meta数据包含许多配置信息, 包括构造函数参数, 属性值, 以及容器指定的信息 - 例如实例化方法, 静态工厂方法名等等.

## 配置风格

Bearcat中, 建议将配置meta数据写成自描述的JavaScript魔法对象. 然而, 由于一些历史原因, 可以写成像context.json一样的JSON格式的配置文件, 也可以在代码文件中写成简单的JavaScript对象.

唯一的区别在于基于代码的meta标签的 ***func*** 属性, 必须是一个通过bean定义的 ***Function*** 构造方法; 然而配置文件的meta标签的 ***func*** 属性, 是一个包含构造方法js文件的 ***String*** 类型的路径.

### JavaScript魔法对象
  
car.js 
```js
var Car = function() {
    this.$id = "car";  // id car
};
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car';
};

module.exports = Car;
```

context.json

```json
{
    "name": "simple",
    "scan": "app"
}
```

详情请参考[$命名的变量依赖注入](/guide/)

### 基于代码的meta标签

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
    func: Car       // 指向的是 Car 类
};
```

### 基于外部配置的meta标签

car.js  
```js
var Car = function() {}

Car.prototype.run = function() {
    console.log('run car...');
    return 'car';
}

module.exports = Car;
```

context.json
```js
{
    "name": "simple",
    "beans": [{
      "id": "car",
      "func": "car"     // 指向的是 car.js 文件
    }]
}
```

## 配置属性

### Bean 属性

Bean属性被解析成 [BeanDefinition](https://github.com/bearcatjs/bearcat/blob/master/lib/beans/support/beanDefinition.js) 对象.  

* id: 当前容器中bean的唯一标记, 用于容器查找该bean  
* func: bean的构造方法  
* order: 当是单例时, 初始化的顺序(放置单例直接相互依赖产生问题)  
* init: 在构造方法后调用, 可以是异步的  
* destroy: 容器优雅的关闭后调用的方法, 可以在此销毁单例beans  
* factoryBean: bean实例化时用的工厂类  
* factoryMethod: bean实例化时用的工程类中的方法  
* scope: 可以是 [singleton(单例)](/guide/dependency-injection.html#单例_scope) 或 [prototype(原型)](/guide/dependency-injection.html#The_prototype_scope), 默认是单例.  
* async: 指定init方法是否是异步, 默认false同步  
* abstract: 指定本bean是否是抽象的, 不需要被实例化, 默认false非抽象.   
* parent: 指定bean的继承关系, 子bean将继承父bean中子bean没有的prototype方法, 值为父bean的id.   
* lazy: 指定当前bean是否不需要提前初始化, 而是在首次调用时初始化. 默认false表示启动时初始化.  
* args: 依赖注入参数, 是一个数组, 所有的数组元素将被解析成 [BeanWrapper](https://github.com/bearcatjs/bearcat/blob/master/lib/beans/support/beanWrapper.js) 对象, 该对象有如下属性  
  - name: 被依赖注入的元素名  
  - type: 当指定type值时, 标记为属性可以依赖注入该类型值, 可以将属性通过参数传给 ***getBean*** 完成注入, type值为: Object, Number, Array, Boolean, Function, String
  - value: 将被注入的值
  - ref: 当前容器中被注入bean的名字
* props: 依赖注入属性, 与args相同
* factoryArgs: 工厂依赖注入参数, 与args相同    
* proxy: 指定当前bean是否需要被代理, 默认true. 当bean需要被AOP切面拦截的时候, proxy代理是必须的. 当bean是基础构造的则无需设置代理.    
* aop: 指定bean是切面 ***aspect*** , 是一个数组, 数组对象有以下属性  
  - pointcut: 定义切入点表达式
  - advice: 当符合切入点时, 执行的切入函数
  - runtime: 设置为true来指定将被切入函数的参数传入切入函数中

### 使用类语法糖替代 context.json 中定义的 Beans

```js
function Car() {
    this.$id = "";
    this.$order = 1;
    this.$init = "";
    this.$async = true;
    this.$destory = "";
    this.$factoryBean = "";
    this.$factoryMethod = "";
    this.$scope = "prototype";
    this.$abstract = false;
    this.$parent = "";
    this.$lazy = false;
    this.$proxy = true;
    this.$aop = [];
    
    this.$func = []; // 已经没有必要存在了, 就是本方法Car
    this.$args = ""; // 直接以 $T 或者 $V 变量注入
    this.$props = "";
    this.$factoryArgs = "";
}
```