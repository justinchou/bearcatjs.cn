title: 代码热更新
type: topic
order: 1
---

## 概述

Node.js代码热更新可以带来大量的好处, 例如: 可以在生产环境进行代码的热更新, 修复紧急bug, 改变代码逻辑. 此外在长连接服务情况下, 重启服务器会导致用户退出和连接的断开, 以及断线重连, 用户体验很糟. 然而, Node.js默认是不支持热更新的, 因为热更新时需要在内存维护对象的引用, 这有可能导致内存溢出.
Bearcat提供一种热更新代码的方法, 当然, 这是有前提条件和局限性的, 不是所有代码都会被热更新的.

## 理论

Bearcat热更新依赖Bearcat强大的控制反转容器, 监听一些事件, 当需要热更新的文件改变的时候, Bearcat将动态的替换更新POJO(简单的JS对象)的原形方法. 因为对象共用相同的 ***prototype*** , 当动态更新了这个 ***prototype*** 对象, 所有对象将被动态更新, 然而无需影响对象自身的私有属性.

这就是说, Bearcat热更新的只是 ***prototype*** 方法, 当你需要更新对象的私有属性时, 这是不支持的.

## 开启热更新支持

给 ***bearcat.createApp*** 方法传递参数:

```js
bearcat.createApp([contextPath], {
	BEARCAT_HOT: 'on',
	BEARCAT_HPATH: '设置热更新文件的目录'
})
```

* BEARCAT_HOT: 设置值为'on'开启热更新
* BEARCAT_HPATH: 设置热更新路径, 一般情况就是所有的扫描路径, 默认是app文件夹

注意:

1. 如果单独设置app之外的路径, 切记在context.json中也要scan该路径.
2. BEARCAT_HPATH 路径需要使用 Path.join(__dirname, 'relative/path/to/hot') 进行解析全路径, 否则会报错.


## 监听文件夹
  
Bearcat 默认会监听应用目录下的 ***app*** 文件夹里面的内容, 当里面的内容有更新时, bearcat 就会对更新的文件进行热更新

app/car.js

```js
var Car = function() {
	this.$id = "car";
};

Car.prototype.run = function() {
	console.log('run hot car...');
	return 'car hot';
};

module.exports = Car;
```

因为Bearcat只更新 ***prototype*** , 被更新的文件需要提供对应bean的 ***id*** 和 ***func*** , 用以标记哪一个bean需要被更新, 以及更新哪些方法.

导出module的时候, 一定要使用 `module.exports`, 不能使用 `Bearcat.module()` 方法, 因为后者会从内存根据$id加载该类, 即使检测到文件变动, 重新引入的时候又引用的是内存中的, 失去了热更新的能力和作用.

## $ 注解下代码热更新

如果采用构造函数内 $ 自描述的方式进行配置, 那么就无需 exports 一个 ***id*** ,  ***func*** 的对象, app 的代码和原来已$注解描述的代码一致, 无需修改

bus.js

```js
var Bus = function() {
	this.$id = "bus";
};

Bus.prototype.run = function() {
	return 'bus';
};

module.exports = Bus;
```

app/bus.js

```js
var Bus = function() {
	this.$id = "bus";
};

Bus.prototype.run = function() {
	return 'bus hot';
};

module.exports = Bus;
```

## 重新加载事件

监听Bearcat的 ***reload*** 事件, 当Bearcat观察到文件修改之后, 将会触发这个事件.

```js
bearcat.on('reload', function() {
	console.log('reload occured...');
});
```

## 注解

* 想要更改默认的监听文件夹, 在启动应用的时候, 传递一个 ***hpath*** 参数, 来标记热更新监听文件夹

例如:

```bash
node app hpath=xxx  
```

或者:

```bash
node app --hpath=xxx  
```

* 当前版本的Bearcat使用[chokidar](https://github.com/paulmillr/chokidar)来监听文件的变动, 因此你可以更新监听文件夹内的所有文件.

注意: 官网的几年前的 ~1.0.1 版本的 chokidar 在比较新的node版本下运行会报错, 将其升级到 2.0+ 即可解决该问题.

    (node) v8::ObjectTemplate::Set() with non-primitive values is deprecated
    (node) and will stop working in the next major release.
    
    ==== JS stack trace =========================================
    
    Security context: 0x3624b99cf781 <JS Object>#0#
        1: .node [module.js:597] [pc=0x185f2a1d0184] (this=0x50a08792269 <an Object with map 0x3bc6fd21ba11>#1#,module=0x881458bc8c1 <a Module with map 0x3bc6fd21ce01>#2#,filename=0x881458bb109 <String[99]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/build/Release/fse.node>)
        2: load [module.js:487] [pc=0x185f2a142452] (this=0x881458bc8c1 <a Module with map 0x3bc6fd21ce01>#2#,filename=0x881458bb109 <String[99]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/build/Release/fse.node>)
        3: tryModuleLoad(aka tryModuleLoad) [module.js:446] [pc=0x185f2a141f7d] (this=0x3624b9904381 <undefined>,module=0x881458bc8c1 <a Module with map 0x3bc6fd21ce01>#2#,filename=0x881458bb109 <String[99]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/build/Release/fse.node>)
        4: _load [module.js:438] [pc=0x185f2a136482] (this=0x50a087922e9 <JS Function Module (SharedFunctionInfo 0x50a08738c99)>#3#,request=0x143de17fc4d9 <String[19]: ./build/Release/fse>,parent=0x881458b5219 <a Module with map 0x3bc6fd21ce01>#4#,isMain=0x3624b9904271 <false>)
        5: require [module.js:~494] [pc=0x185f2a1a7d73] (this=0x881458b5219 <a Module with map 0x3bc6fd21ce01>#4#,path=0x143de17fc4d9 <String[19]: ./build/Release/fse>)
        6: require(aka require) [internal/module.js:20] [pc=0x185f2a14bf46] (this=0x3624b9904381 <undefined>,path=0x143de17fc4d9 <String[19]: ./build/Release/fse>)
        7: /* anonymous */ [/Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/fsevents.js:9] [pc=0x185f2a1cfaff] (this=0x881458b5269 <an Object with map 0x1d7792e07959>#5#,exports=0x881458b5269 <an Object with map 0x1d7792e07959>#5#,require=0x881458b95a1 <JS Function require (SharedFunctionInfo 0x50a0876c711)>#6#,module=0x881458b5219 <a Module with map 0x3bc6fd21ce01>#4#,__filename=0x881458b4069 <String[88]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/fsevents.js>,__dirname=0x881458b9539 <String[76]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents>)
        8: _compile [module.js:570] [pc=0x185f2a14b374] (this=0x881458b5219 <a Module with map 0x3bc6fd21ce01>#4#,content=0x881458b5fb9 <Very long string[3059]>#7#,filename=0x881458b4069 <String[88]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/fsevents.js>)
        9: .js [module.js:579] [pc=0x185f2a1439eb] (this=0x50a08792269 <an Object with map 0x3bc6fd21ba11>#1#,module=0x881458b5219 <a Module with map 0x3bc6fd21ce01>#4#,filename=0x881458b4069 <String[88]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/fsevents.js>)
       10: load [module.js:487] [pc=0x185f2a142452] (this=0x881458b5219 <a Module with map 0x3bc6fd21ce01>#4#,filename=0x881458b4069 <String[88]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/fsevents.js>)
       11: tryModuleLoad(aka tryModuleLoad) [module.js:446] [pc=0x185f2a141f7d] (this=0x3624b9904381 <undefined>,module=0x881458b5219 <a Module with map 0x3bc6fd21ce01>#4#,filename=0x881458b4069 <String[88]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/fsevents/fsevents.js>)
       12: _load [module.js:438] [pc=0x185f2a136482] (this=0x50a087922e9 <JS Function Module (SharedFunctionInfo 0x50a08738c99)>#3#,request=0x143de17e9809 <String[8]: fsevents>,parent=0x881458a8079 <a Module with map 0x3bc6fd21ce01>#8#,isMain=0x3624b9904271 <false>)
       13: require [module.js:~494] [pc=0x185f2a1a7d73] (this=0x881458a8079 <a Module with map 0x3bc6fd21ce01>#8#,path=0x143de17e9809 <String[8]: fsevents>)
       14: require(aka require) [internal/module.js:20] [pc=0x185f2a14bf46] (this=0x3624b9904381 <undefined>,path=0x143de17e9809 <String[8]: fsevents>)
       15: /* anonymous */ [/Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/lib/fsevents-handler.js:7] [pc=0x185f2a1cee6a] (this=0x881458a80c9 <an Object with map 0x1d7792e07959>#9#,exports=0x881458a80c9 <an Object with map 0x1d7792e07959>#9#,require=0x881458af289 <JS Function require (SharedFunctionInfo 0x50a0876c711)>#10#,module=0x881458a8079 <a Module with map 0x3bc6fd21ce01>#8#,__filename=0x881458a7039 <String[100]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/lib/fsevents-handler.js>,__dirname=0x881458af221 <String[80]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/lib>)
       16: _compile [module.js:570] [pc=0x185f2a14b374] (this=0x881458a8079 <a Module with map 0x3bc6fd21ce01>#8#,content=0x881458a8e59 <Very long string[12062]>#11#,filename=0x881458a7039 <String[100]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/lib/fsevents-handler.js>)
       17: .js [module.js:579] [pc=0x185f2a1439eb] (this=0x50a08792269 <an Object with map 0x3bc6fd21ba11>#1#,module=0x881458a8079 <a Module with map 0x3bc6fd21ce01>#8#,filename=0x881458a7039 <String[100]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/lib/fsevents-handler.js>)
       18: load [module.js:487] [pc=0x185f2a142452] (this=0x881458a8079 <a Module with map 0x3bc6fd21ce01>#8#,filename=0x881458a7039 <String[100]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/lib/fsevents-handler.js>)
       19: tryModuleLoad(aka tryModuleLoad) [module.js:446] [pc=0x185f2a141f7d] (this=0x3624b9904381 <undefined>,module=0x881458a8079 <a Module with map 0x3bc6fd21ce01>#8#,filename=0x881458a7039 <String[100]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/lib/fsevents-handler.js>)
       20: _load [module.js:438] [pc=0x185f2a136482] (this=0x50a087922e9 <JS Function Module (SharedFunctionInfo 0x50a08738c99)>#3#,request=0x143de17e9c59 <String[22]: ./lib/fsevents-handler>,parent=0x1e549d484341 <a Module with map 0x3bc6fd21ce01>#12#,isMain=0x3624b9904271 <false>)
       21: require [module.js:~494] [pc=0x185f2a1a7d73] (this=0x1e549d484341 <a Module with map 0x3bc6fd21ce01>#12#,path=0x143de17e9c59 <String[22]: ./lib/fsevents-handler>)
       22: require(aka require) [internal/module.js:20] [pc=0x185f2a14bf46] (this=0x3624b9904381 <undefined>,path=0x143de17e9c59 <String[22]: ./lib/fsevents-handler>)
       23: /* anonymous */ [/Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/index.js:13] [pc=0x185f2a1b188c] (this=0x1e549d4845c1 <an Object with map 0x1d7792e07959>#13#,exports=0x1e549d4845c1 <an Object with map 0x1d7792e07959>#13#,require=0x1e549d4843d1 <JS Function require (SharedFunctionInfo 0x50a0876c711)>#14#,module=0x1e549d484341 <a Module with map 0x3bc6fd21ce01>#12#,__filename=0x1e549d484551 <String[85]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/index.js>,__dirname=0x1e549d484529 <String[76]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar>)
       24: _compile [module.js:570] [pc=0x185f2a14b374] (this=0x1e549d484341 <a Module with map 0x3bc6fd21ce01>#12#,content=0x1e549d48c8f9 <Very long string[16671]>#15#,filename=0x1e549d484551 <String[85]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/index.js>)
       25: .js [module.js:579] [pc=0x185f2a1439eb] (this=0x50a08792269 <an Object with map 0x3bc6fd21ba11>#1#,module=0x1e549d484341 <a Module with map 0x3bc6fd21ce01>#12#,filename=0x1e549d484551 <String[85]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/index.js>)
       26: load [module.js:487] [pc=0x185f2a142452] (this=0x1e549d484341 <a Module with map 0x3bc6fd21ce01>#12#,filename=0x1e549d484551 <String[85]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/index.js>)
       27: tryModuleLoad(aka tryModuleLoad) [module.js:446] [pc=0x185f2a141f7d] (this=0x3624b9904381 <undefined>,module=0x1e549d484341 <a Module with map 0x3bc6fd21ce01>#12#,filename=0x1e549d484551 <String[85]: /Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/chokidar/index.js>)
       28: _load [module.js:438] [pc=0x185f2a136482] (this=0x50a087922e9 <JS Function Module (SharedFunctionInfo 0x50a08738c99)>#3#,request=0x50a0876dfa9 <String[8]: chokidar>,parent=0x143de17f4629 <a Module with map 0x3bc6fd21ce01>#16#,isMain=0x3624b9904271 <false>)
       29: require [module.js:~494] [pc=0x185f2a1a7d73] (this=0x143de17f4629 <a Module with map 0x3bc6fd21ce01>#16#,path=0x50a0876dfa9 <String[8]: chokidar>)
       30: require(aka require) [internal/module.js:20] [pc=0x185f2a14bf46] (this=0x3624b9904381 <undefined>,path=0x50a0876dfa9 <String[8]: chokidar>)
       31: hotReloadFileWatch [/Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/bearcat/lib/context/applicationContext.js:485] [pc=0x185f2a1b0fec] (this=0x1e549d494bd1 <an ApplicationContext with map 0x3bc6fd24a509>#17#,hpath=0x1e549d494ba9 <String[69]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/hot>)
       32: prepareRefresh [/Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/bearcat/lib/context/applicationContext.js:349] [pc=0x185f2a1afba4] (this=0x1e549d494bd1 <an ApplicationContext with map 0x3bc6fd24a509>#17#)
       33: refresh [/Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/bearcat/lib/context/applicationContext.js:222] [pc=0x185f2a1ae72d] (this=0x1e549d494bd1 <an ApplicationContext with map 0x3bc6fd24a509>#17#,cb=0x3624b9904381 <undefined>)
       34: arguments adaptor frame: 0->1
       35: start [/Users/justin/Documents/Projects/bearcatjs-lession-one/node_modules/bearcat/lib/bearcat.js:143] [pc=0x185f2a1adf2c] (this=0x1e549d494f21 <an Object with map 0x3bc6fd24aa89>#18#,cb=0x1e549d494ed9 <JS Function (SharedFunctionInfo 0x50a0876c269)>#19#)
       36: /* anonymous */ [/Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/app.js:25] [pc=0x185f2a14ba01] (this=0x50a08792929 <an Object with map 0x1d7792e07959>#20#,exports=0x50a08792929 <an Object with map 0x1d7792e07959>#20#,require=0x50a087927d9 <JS Function require (SharedFunctionInfo 0x50a0876c711)>#21#,module=0x50a08792749 <a Module with map 0x3bc6fd21ce01>#22#,__filename=0x50a087928c9 <String[72]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/app.js>,__dirname=0x50a087928a1 <String[65]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload>)
       37: _compile [module.js:570] [pc=0x185f2a14b374] (this=0x50a08792749 <a Module with map 0x3bc6fd21ce01>#22#,content=0x50a08792cc1 <String[736]\: /**\n * Created by EasyGame.\n * File: app.js\n * User: justin\n * Date: 24/2/2018\n * Time: 14:11\n */\n\n'use strict';\n\nconst Bearcat = require('bearcat');\nconst Path = require('path');\n\nconst contexPath = [require.resolve('./context.json')];\n\nBearcat.createApp(contexPath, {\n    "BEARCAT_HOT": 'on',\n    "BEARCAT_HPATH": Path.join(__dirname, '/hot')\n});\n\nBearcat.on('reload', function () {\n    // console.log('reload occured...');\n});\n\nBearcat.start(function () {\n    let server = Bearcat.getBean('chatServer');\n\n    setInterval(function () {\n        let conn = {"userinfo": {id: Math.floor(Math.random() * 10000)}};\n        server.enterServer(conn);\n    }, 7452);\n\n    setInterval(function () {\n        server.listUsers();\n    }, 2000);\n});>,filename=0x50a087928c9 <String[72]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/app.js>)
       38: .js [module.js:579] [pc=0x185f2a1439eb] (this=0x50a08792269 <an Object with map 0x3bc6fd21ba11>#1#,module=0x50a08792749 <a Module with map 0x3bc6fd21ce01>#22#,filename=0x50a087928c9 <String[72]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/app.js>)
       39: load [module.js:487] [pc=0x185f2a142452] (this=0x50a08792749 <a Module with map 0x3bc6fd21ce01>#22#,filename=0x50a087928c9 <String[72]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/app.js>)
       40: tryModuleLoad(aka tryModuleLoad) [module.js:446] [pc=0x185f2a141f7d] (this=0x3624b9904381 <undefined>,module=0x50a08792749 <a Module with map 0x3bc6fd21ce01>#22#,filename=0x50a087928c9 <String[72]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/app.js>)
       41: _load [module.js:438] [pc=0x185f2a136482] (this=0x50a087922e9 <JS Function Module (SharedFunctionInfo 0x50a08738c99)>#3#,request=0x50a08760401 <String[72]: /Users/justin/Documents/Projects/bearcatjs-lession-one/hot_reload/app.js>,parent=0x3624b9904201 <null>,isMain=0x3624b99043c1 <true>)
       42: /* anonymous */(aka /* anonymous */) [module.js:604] [pc=0x185f2a135f4a] (this=0x3624b9904381 <undefined>)
       43: run(aka run) [bootstrap_node.js:383] [pc=0x185f2a135dd0] (this=0x3624b9904381 <undefined>,entryFunction=0x50a0875edb1 <JS Function Module.runMain (SharedFunctionInfo 0x50a08739ad9)>#23#)
       44: startup(aka startup) [bootstrap_node.js:149] [pc=0x185f2a040c61] (this=0x3624b9904381 <undefined>)
       45: /* anonymous */(aka /* anonymous */) [bootstrap_node.js:496] [pc=0x185f2a03ef02] (this=0x3624b9904201 <null>,process=0x50a08793249 <a process with map 0x1d7792e11619>#24#)
    =====================
    
    
    ==== C stack trace ===============================
    
     1: v8::Template::Set(v8::Local<v8::Name>, v8::Local<v8::Data>, v8::PropertyAttribute)
     2: fse::FSEvents::Initialize(v8::Local<v8::Object>)
     3: node::DLOpen(v8::FunctionCallbackInfo<v8::Value> const&)
     4: v8::internal::FunctionCallbackArguments::Call(void (*)(v8::FunctionCallbackInfo<v8::Value> const&))
     5: v8::internal::(anonymous namespace)::HandleApiCallHelper(v8::internal::Isolate*, v8::internal::(anonymous namespace)::BuiltinArguments<(v8::internal::BuiltinExtraArguments)3>)
     6: v8::internal::Builtin_HandleApiCall(int, v8::internal::Object**, v8::internal::Isolate*)
     7: 0x185f2a0092a7
    (node) v8::ObjectTemplate::Set() with non-primitive values is deprecated
    (node) and will stop working in the next major release.
    
    ==== JS stack trace =========================================

* 当使用热更新时, 尽量避免在文件中使用全局的var/let变量, 也要避免使用相对路径引用, 因为这些都是紧耦合的.

* 一些拷贝方法, 例如 ***bind*** 和 ***concat*** , 将保持引用关系, 这将打断热更新, 为此, 你可以监听 ***reload*** 时间来做处理.

## 例子

* [Bearcat 热更新](https://github.com/bearcatjs/bearcat/tree/master/examples/hot_reload)

## 总结

* 松耦合系统的系统更易于热更新代码, 因为Bearcat使用控制反转(IoC)解耦对象依赖, 对象间不直接依赖在一起, 对象们通过bearcat变成一个统一完整的整体, 这也使得对系统内部分对象动态更新成为了可能.

## 注意

使用 process.env.BEARCAT_HOT = 'off'; 来关闭bearcat热更新功能, 不会对hot reload path进行监控.

