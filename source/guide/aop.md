title: 面向切面编程(AOP)
type: guide
order: 4
---

## 介绍

面向切面编程(AOP)是对面向对象编程(OOP)在另一程序结构上面的补充. OOP 的核心单位是 class, 而AOP的核心单位则是 aspect(切面). 切面使得对于像事务管理这种横切不同类型和对象的逻辑变得模块化.

AOP主要的功能是：日志记录，性能统计，安全控制，事务处理，异常处理等等。主要的意图是：将日志记录，性能统计，安全控制，事务处理，异常处理等代码从业务逻辑代码中划分出来，通过对这些行为的分离，我们希望可以将它们独立到非指导业务逻辑的方法中，进而改变这些行为的时候不影响业务逻辑的代码。

## AOP 概念

* Aspect: 对系统中的横切关注点逻辑进行模块化封装的AOP概念实体. 在Node.js应用程序中, 事务管理是一个很好横切关注逻辑.
* Join point: 一个程序的执行点, 比如方法执行或者处理一个异常.
* Advice: aspect 中对切入点(join point)操作的封装, 相当于OOP中的method. 不同的advice类型包括 "around", "before" 和 "after" advice.
* Pointcut: 代表的是Jointpoint的表述方式, 将横切逻辑织入当前系统的过程中, 需要参照Pointcut规定的Joinpoint信息, 才可以知道应该往系统的哪些Joinpoint上织入横切逻辑.
* Target object: 被一个或多个aspect横切拦截操作的目标对象.
* AOP proxy: 由AOP框架生成的用于实现aspect相关的代理对象.
* Weaving: 织入是把aspects里的横切逻辑连接到目标对象的过程.

advice 的类型:
 
* Before advice: 在切入点(join point)之前执行的advice
* After returning advice: 切入逻辑在切入点完全执行完之后再执行
* After throwing advice: 切入逻辑执行当切入的方法抛出了异常
* Around advice: 横切逻辑在切入点周围执行, 比如在一个方法执行的开始和结束. 这是最强大的一种横切逻辑. around advice 可以完成在方法执行的开始和结束做些自定义操作. 它可以决定是选择执行切入点的逻辑或者直接返回横切逻辑的结果通过return或者抛出异常来.

Bearcat 支持 ***Before advice***, ***After returning advice*** 和 ***Around advice***, 因为抛出异常并不是很好的实践在Node.js中.

## 声明一个aspect

在Bearcat, 一个aspect也是一个简单的POJO, 它同在Bearcat中管理的其它POJOs一样, 因此你可以相当容易的往aspect中注入其它的beans.
在一个aspect中, 你必须定义advices, 可以参考 [声明一个advice](#Declaring_an_advice)  

## 声明一个advice
advice 就是aspect中的一个函数, advice 函数的最后一个参数必须是 ***next*** 回调函数用以告知AOP框架当前advice执行的结束.
在元数据配置中, 你可以使用 advice 属性来表面当前 ***advice*** 中的advice的名字.
   
```
"advice": "doBefore"
```

### Before advice

``` js
Aspect.prototype.doBefore = function(next) {
    console.log('Aspect doBefore');
    next();
}
```

### After advice

after advice 在Bearcat中等同于 after returning advice.
切入点方法执行回调的结果参数会传递给after advice方法.

``` js
Aspect.prototype.doAfter = function(err, r, next) {
    console.log('Aspect doAfter ' + r);
    next();
}
```

### Around advice

在around advice中, target对象和target方法会以参数的方式传递给around advice.

``` js
Aspect.prototype.doAround = function(target, method, next) {
    console.log('Aspect doAround before');
    target[method](function(err, r) {
	    console.log('Aspect doAround after ' + r);
	    next(err, r + 100);
    });
}
```

## 声明一个pointcut

pointcuts 决定了感兴趣的join points切入点, 也因此控制着什么时候advice会被执行. 在Bearcat中, 一个pointcut声明有两个部分: 一个prefix前缀声明advice的类型, 一个pointcut表达式用于描述所感兴趣的目标方法.
在元数据配置中Pointcut通过 ***pointcut*** 属性来进行描述.

```
"pointcut": "before:.*?runBefore"
```

前缀必须是 ***before***, ***after*** 和 ***around***, 对应于before advice, after advice和around advice.

在prefix之后则是一个 ***:*** 分隔符.

在分隔符之后, 则是一个pointcut表达式用于描述匹配目标方法
pointcut 表达式事实上就是一个简单的正则表达式
目标方法有下面这样的唯一特征:
```
id.method
```
***id*** 是目标bean的唯一id 

***method*** 是目标对象的方法名

因此, 如果目标对象以id为 ***car*** 为名, 并且有一个方法名叫 ***runBefore***
下面的pointcut表达式就会匹配到该目标方法:

```
"pointcut": "before:.*?runBefore"
```

## 运行时(runtime)支持

当一个advice被定义为runtime, 目标方法的调用参数就会被传递给该advice.
***before advice*** 和 ***around advice*** 可以被定义成为runtime, 而 ***after advice*** 本身就是runtime的.
要使用这个特性, 你可以通过 ***runtime*** 属性, 并且设置它为true

```
"runtime": true
```

### before advice (runtime)

``` js
Aspect.prototype.doBeforeRuntime = function(num, next) {
    console.log('Aspect doBeforeRuntime ' + num);
    next();
}
``` 

### around advice (runtime)

``` js
Aspect.prototype.doAroundRuntime = function(target, method, num, next) {
    console.log('Aspect doAroundRuntime before ' + num);
    target[method](num, function(err, r) {
        console.log('Aspect doAroundRuntime after ' + r);
	    next(err, r + 100);
    });
}
```

## Aspect $ 注解式声明

关于Aspect的配置除了在context.json里面配置以外, 还可以通过 $ 注解式声明进行配置

Aspect 也是一个bean, 要使得AOP配置支持$注解形式, 需要在构造函数内配置

```
this.$aop = true;
```
  
Aspect 的 prototype 中的每一个方法都可能成为 advice, 成为 advice 则只需要在里面声明

```
var $pointcut = "pointcut expression";
```

除了声明 pointcut 之外, order, runtime 也可以同样的方式声明

```
var $order = 1;
var $runtime = true;
```

一个简单的例子

``` js
var Aspect = function() {
    this.$id = "aspect";
    this.$aop = true;
}
  
Aspect.prototype.doBefore = function(next) {
    var $pointcut = "before:.*?runBefore";
    var $order = 10;

    console.log('Aspect doBefore');
    next();
}
  
module.exports = Aspect;
```

[aop_annoation 例子](https://github.com/bearcatjs/bearcat/tree/master/examples/aop_annotation)