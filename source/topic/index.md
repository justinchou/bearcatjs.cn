title: 代码热更新
type: topic
order: 1
---

## 概述

Node.js代码热更新可以带来大量的好处, 例如: 可以在生产环境进行代码的热更新, 修复紧急bug, 改变代码逻辑. 此外在长连接服务情况下, 重启服务器会导致用户退出和连接的断开, 以及断线重连, 用户体验很糟. 然而, Node.js默认是不支持热更新的, 因为热更新时需要在内存维护对象的引用, 这有可能导致内存溢出.
Bearcat提供一种热更新代码的方法, 当然, 这是有前提条件和局限性的, 不是所有代码都会被热更新的.

## 理论

Bearcat热更新依赖Bearcat强大的控制反转容器, 监听一些事件, 当需要热更新的文件改变的时候, Bearcat将动态的替换更新POJO(简单的JS对象)的原形方法. 因为对象共用相同的***prototype***, 当动态更新了这个***prototype***对象, 所有对象将被动态更新, 然而无需影响对象自身的私有属性.

这就是说, Bearcat热更新的只是***prototype***方法, 当你需要更新对象的私有属性时, 这是不支持的.

## 开启热更新支持

给 ***bearcat.createApp*** 方法传递参数:

```
bearcat.createApp([contextPath], {
	BEARCAT_HOT: 'on',
	BEARCAT_HPATH: 'setup your hot reload source path'
})
```

* BEARCAT_HOT: 设置值为'on'开启热更新
* BEARCAT_HPATH: 设置热更新路径, 一般情况就是所有的扫描路径, 默认是app文件夹

## 观察路径
  
Bearcat将自动默认观察应用源码目录***app***, 当其中文件修改之后, Bearcat将对修改的文件执行热更新.

app/car.js

```
var Car = function() {
	this.$id = "car";
}

Car.prototype.run = function() {
	console.log('run hot car...');
	return 'car hot';
}

module.exports = Car;
```

因为Bearcat只更新***prototype***, 被更新的文件需要提供对应bean的***id***和***func***, 用以标记哪一个bean需要被更新, 以及更新哪些方法.    

## 重新加载事件

监听Bearcat的***reload***事件, 当Bearcat观察到文件修改之后, 将会触发这个事件.

```
bearcat.on('reload', function() {
	console.log('reload occured...');
});
```

## 注解

* 想要更改默认的监听文件夹, 在启动应用的时候, 传递一个***hpath***参数, 来标记热更新监听文件夹

例如:

```  
node app hpath=xxx  
```

或者:

```
node app --hpath=xxx  
```

* 当前版本的Bearcat使用[chokidar](https://github.com/paulmillr/chokidar)来监听文件的变动, 因此你可以更新监听文件夹内的所有文件.

* 当使用热更新时, 尽量避免在文件中使用全局的var/let变量, 也要避免使用相对路径引用, 因为这些都是紧耦合的.

* 一些拷贝方法, 例如***bind***和***concat***, 将保持引用关系, 这将打断热更新, 为此, 你可以监听***reload***时间来做处理.

## 例子

* [Bearcat 热更新](https://github.com/bearcatjs/bearcat/tree/master/examples/hot_reload)

## 总结

* 松耦合系统的系统更易于热更新代码, 因为Bearcat使用控制反转(IoC)解耦对象依赖.