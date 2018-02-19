title: 熊猫框架API
type: api
order: 1
---


## createApp

 `createApp`是Bearcat框架的核心, 它是一个工厂方法, 用于创建Bearcat实例.

 * @param  {Array}  configLocations **引用的context路径的数组**
 * @param  {Object} opts            **\[可选参数\]**
 * @param  {String} opts.NODE_ENV            ***setup env***
 * @param  {String} opts.BEARCAT_ENV         ***setup env***
 * @param  {String} opts.NODE_CPATH          ***setup config path***
 * @param  {String} opts.BEARCAT_CPATH       ***setup config path***
 * @param  {String} opts.BEARCAT_LOGGER      ***设置成'off'关闭Bearcat内部日志***
 * @param  {String} opts.BEARCAT_HOT         ***设置成'off'关闭Bearcat的代码热更新***
 * @param  {String} opts.BEARCAT_ANNOTATION  ***setup 'off' to turn off bearcat $ based annotation***
 * @param  {String} opts.BEARCAT_GLOBAL  	 ***将 bearcat 设置成全局变量***
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


## use

 增加异步加载bean, 声明需要加载到Bearcat中的bean, (译者注)但暂时不加载.

 例子:
  
 ```
 bearcat.use(['car']);
 bearcat.use('car');
 ```

 * @param  {Array|String} **异步加载的bean的ID或者ID数组**
 * @api public


## async

 异步加载bean, (译者注)需要前面使用use声明后, 才能使用此方法异步加载

 例子:
  
 ```js
 bearcat.async(['car'], function(car) {
   // car 加载好了
 });
 ```

 * @param  {Array|String} **异步加载的bean的ID或者ID数组**
 * @return {Function}     **回调函数, 将异步加载好的对象实例通过回调传递回来**
 * @api public


## module

 通过自描述的语法糖`$`将bean模块注册到控制反转(IoC)容器中.

 例子:

 ``` js
 bearcat.module(function() {
     this.$id = "car";
     this.$scope = "prototype";
 });
 ```

 * @param  {Function} **`$`描述属性的方法**
 * @api public


## getBean

 从控制反转(IoC)容器中, 通过bean名/meta标签获取bean.

 例子:

 ``` js
 // 通过bean名
 var car = bearcat.getBean("car");

 // 通过meta标签
 var car = bearcat.getBean({
    id: "car",
    func: Car // Car is a function constructor
 });

 // 通过含有 `$` 属性的方法
 var car = bearcat.getBean(function() {
    this.$id = "car";
    this.$scope = "prototype";
 });
 ```

 * @param  {String} **bean名|meta标签|`$`描述属性的方法**
 * @return {Object} **bean实例**
 * @api public


## getRoute

 为方便使用MVC框架路由器定制的方法.

 例子:

 ``` js
 // express
 var app = express();
 app.get('/', bearcat.getRoute('bearController', 'index'));
 ```

 * @param  {String} **bean名**
 * @param  {String} **bean中用于执行的路由名**
 * @api public


## getFunction

 通过bean名从控制反转(IoC)容器中获取bean构造方法.

 例子:
  
 ``` js
 // through beanName
 var Car = bearcat.getFunction("car");
 ```

 * @param  {String}   **bean名**
 * @return {Function} **bean构造方法**
 * @api public
 
 
## getBeanByFunc

 通过含有`$`描述属性的方法, 从控制反转(IoC)容器中获取bean实例.

 例子:
   
 ``` js
 bearcat.getBeanByFunc(function() {
    this.$id = "car";
    this.$scope = "prototype";
 });
 ```

 * @param  {Function} **`$`描述属性的方法**
 * @api public


## getBeanByMeta

 通过meta标签从控制反转(IoC)容器中获取bean实例.

 examples:  
 ``` js
 bearcat.getBeanByMeta({
    id: "car",
    func: Car // Car is a function constructor
 });
 ```

 * @param  {Object} **meta标签**
 * @api public