title: 熊猫框架API
type: api
order: 1
---

# 声明Bearcat框架环境


## createApp

  `createApp` 是Bearcat框架的核心, 它是一个工厂方法, 用于创建Bearcat实例.

 * @param  {Array}  configLocations **引用的context路径的数组**
 * @param  {Object} opts            **\[可选参数\]**
 * @param  {String} opts.NODE_ENV             ***setup env*** 
 * @param  {String} opts.BEARCAT_ENV          ***setup env*** 
 * @param  {String} opts.NODE_CPATH           ***setup config path*** 
 * @param  {String} opts.BEARCAT_CPATH        ***setup config path*** 
 * @param  {String} opts.BEARCAT_LOGGER       ***设置成'off'关闭Bearcat内部日志*** 
 * @param  {String} opts.BEARCAT_HOT          ***设置成'off'关闭Bearcat的代码热更新*** 
 * @param  {String} opts.BEARCAT_HPATH        ***热更新代码的路径*** 
 * @param  {String} opts.BEARCAT_ANNOTATION   ***设置成'off'关闭bearcat对function $注解的支持*** 
 * @param  {String} opts.BEARCAT_GLOBAL  	  ***将 bearcat 设置成全局变量*** 
 * @return {Object} **bearcat实例**
 * @api public
 
  ***configLocations 需要使用全路径而非相对路径*** 
 
 相对路径转换成全路径的方法:
 
  `require('path').join(__dirname, 'relative/path/to/context.json');` 
 
 或者
 
  `require.resolve('relative/path/to/context.json');` 


## start

 启动Bearcat应用

 * @param  {Function} **启动成功后回调方法**
 * @api public

译者注: 这个cb方法没有参数, 能够进入则说明启动成功, 否则不会进入该方法. 进入该方法后则Bearcat的所有初始化任务均已经完成, 可以直接使用.


## stop

 关闭Bearcat应用, 关闭内部应用上下文, 销毁所有单例对象.

 * @api public


# 前端浏览器使用


ps: 通过 bearcat-bootstrap.js 自动管理, 用到哪个文件加载那个文件


## use

 用于浏览器端加载bean, 声明需要加载到Bearcat中的bean, 通过require直接载入, 一般在启动后一次性载入需要文件列表.

 例子:
  
```js
 bearcat.use(['car']);
 bearcat.use('car');
```

 * @param  {Array|String} **异步加载的bean的ID或者ID数组**
 * @api public


## async

 异步加载bean, 与use类似, 但是一般用于在内部某处需要加载的时候, 加载成功调用回调方法.

 例子:
  
```js
 bearcat.async(['car'], function(car) {
   // car 加载好了
 });
```

 * @param  {Array|String} **异步加载的bean的ID或者ID数组**
 * @return {Function}     **回调函数, 将异步加载好的对象实例通过回调传递回来**
 * @api public


# 前后端通用方法


## 用于定义声明, 并且输出 Bearcat 类文件


### meta (since v1.0.4)

 通过类中的Meta标签(非context中)来将bean模块注册到控制反转(IoC)容器中.
 
 解决原有 module.exports 导出的 meta 无法在浏览器中使用的问题.
 
 在 v1.0.4 版本增加, 开始支持.

 例子:

```js
 function Car () {
     this.engine = null;
     this.licence = null;
 }
 bearcat.meta({
     id: 'car',
     func: Car,
     scope: 'prototype',
     props: [{
         name: 'engine',
         ref: 'engine'
     }, {
         name: 'licence',
         value: '${default.licence}'
     }]
 }, typeof module !== 'undefined' ? module : {});

 // let cat = bearcat.getBean('car');
```

```js
 function Car(engine, licence) {
     this.engine = engine;
     this.licence = licence;
 };
 bearcat.meta({
     id: 'car',
     func: Car,
     scope: 'prototype',
     args: [{
         name: 'engine',
         ref: 'engine'
     }, {
         name: 'licence',
         type: 'String'
     }]
 }, typeof module !== 'undefined' ? module : {});
 
 // let cat = bearcat.getBean('car', '123456');
```

 * @api public
 


### module

 通过自描述的语法糖 `$` 将bean模块注册到控制反转(IoC)容器中.

 例子:

```js
 function Car() {
     this.$id = "car";
     this.$scope = "prototype";
     this.$engine = null;
     this.$licence = '${default.licence}';
 }
 bearcat.module(Car, typeof module !== 'undefined' ? module : {});

 // let cat = bearcat.getBean('car');
```

```js
 function Car($engine, licence) {
     this.$id = 'car';
     this.$scope = 'prototype';
 
     this.engine = $engine;
     this.licence = licence;
 };
 bearcat.module(Car, typeof module !== 'undefined' ? module : {});
 
 // let cat = bearcat.getBean('car', '123456');
```

 * @param {Function} ** `$` 描述属性的方法**
 * @api public


## 用于获取 Bearcat 对象 

ps: 声明定义好类之后, 通过设置context, Bearcat自动管理对象的初始化.


### getBean

 从控制反转(IoC)容器中, 通过bean名/meta标签获取bean.

 例子:

```js
 // 通过bean名
 var car = bearcat.getBean("car");

 // 通过meta标签
 var car = bearcat.getBean({
    id: "car",
    func: Car // Car 是一个Function构造函数
 });

 // 通过含有 `$` 属性的方法
 var car = bearcat.getBean(function() {
    this.$id = "car";
    this.$scope = "prototype";
 });
```

 * @param  {String} **bean名|meta标签| `$` 描述属性的方法**
 * @return {Object} **bean实例**
 * @api public


### getBeanByFunc

 通过含有 `$` 描述属性的方法, 从控制反转(IoC)容器中获取bean实例.

 例子:
   
```js
 bearcat.getBeanByFunc(function() {
    this.$id = "car";
    this.$scope = "prototype";
 });
 ```

 * @param  {Function} ** `$` 描述属性的方法**
 * @api public


### getBeanByMeta

 通过meta标签从控制反转(IoC)容器中获取bean实例.

 例子:
 
```js
 bearcat.getBeanByMeta({
    id: "car",
    func: Car // Car 是一个Function构造函数
 });
 ```

 * @param  {Object} **meta标签**
 * @api public
 
 
 


## 用于获取 Bearcat 类/类方法


### getRoute

 为方便使用MVC框架路由器定制的方法.

 例子:

```js
 // express
 var app = express();
 app.get('/', bearcat.getRoute('bearController', 'index'));
```

 * @param  {String} **bean名**
 * @param  {String} **bean中用于执行的路由名**
 * @api public


### getFunction

 通过bean名从控制反转(IoC)容器中获取bean构造方法.

 例子:
  
```js
 // 通过 Function 的唯一ID
 var Car = bearcat.getFunction("car");
 ```

 * @param  {String}   **bean名**
 * @return {Function} **bean构造方法**
 * @api public
 
 
 
