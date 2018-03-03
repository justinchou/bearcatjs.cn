title: 使用DAO访问数据库
type: guide
order: 11
---

## 概述

在Bearcat中的数据访问(DAO)支持目的在于提供对mysql, SQLite, PostgresSQL 等数据库的简单方便访问. 它封装了底层细节, 使得开发者无需担心处理连接的申请和释放等问题. 整个数据访问是由[Bearcat-dao](https://github.com/bearcatnode/bearcat-dao)支持的.

### Bearcat-dao -- an O/R mapping dao 框架

Bearcat-dao 是一个 O/R mapping dao 框架, 为[node.js](http://nodejs.org/)提供了 O/R mapping, dao 支持. 它由POJOs编写而成, 可以很方便的在 [Bearcat](https://github.com/bearcatjs/bearcat) 中使用.

### 特性

* O/R mapping
* cacheTemplate
* sqlTemplate
* transaction



## 使用方法

### Domain 定义

Domain 是一个 POJO, 描述了表和对象之间的关系

```js
var simpleDomain = function() {
	this.id = 0;
	this.name = null;
};

module.exports = {
	func: Domain,
	primary: [{
		name: "id",
		type: "Long"
	}],
	fields: ["name"],
	tableName: "test"
};
```

详细说来:

* func: domain object 的构造函数
* primary: 定义主键字段列表的数组
* fields: 定义除主键字段列表的数组
     * field 可以通过有 ***name*** , ***type*** 属性的对象或者简单的就是 ***name*** 字符串
* tableName: 需要映射的ORM对象的表名
* key: 多表联合查询的缓存key


### 添加到项目中

    npm install bearcat-dao --save
    
修改项目中的context.json [placeholds](/guide/consistent-configuration.html) 可以很方便的在不同环境间切换.

```json
{"dependencies": {
    "bearcat-dao": "*"
},
"beans": [{
    "id": "mysqlConnectionManager",
    "func": "node_modules.bearcat-dao.lib.connection.sql.mysqlConnectionManager",
    "props": [{
        "name": "port",
        "value": "${mysql.port}"
    }, {
        "name": "host",
        "value": "${mysql.host}"
    }, {
        "name": "user",
        "value": "${mysql.user}"
    }, {
        "name": "password",
        "value": "${mysql.password}"
    }, {
        "name": "database",
        "value": "${mysql.database}"
    }]
  }, {
    "id": "redisConnectionManager",
    "func": "node_modules.bearcat-dao.lib.connection.cache.redisConnectionManager",
    "props": [{
        "name": "port",
        "value": "${redis.port}"
    }, {
        "name": "host",
        "value": "${redis.host}"
    }]
}]}
```

如果你不需要使用redis, 你可以移除 ***redisConnectionManager*** 定义


### 编写 daos

Bearcat-dao 提供了封装基本sql和cache操作的 domainDaoSupport

通过依赖注入可以很方便的使用, init domainDaoSupport的时候调用 initConfig 方法来进行 domain O/R mapping 的初始化配置

之后你可以使用domainDaoSupport来很方便的封装你自己的daos

simpleDao.js

```js
var SimpleDomain = require('simpleDomain');
var SimpleDao = function() {
	this.domainDaoSupport = null;
};

SimpleDao.prototype.init = function() {
	// init with SimpleDomain to set up O/R mapping
	this.domainDaoSupport.initConfig(SimpleDomain);
};

// query list all
// callback return mapped SimpleDomain array results
SimpleDao.prototype.getList = function(cb) {
	var sql = ' 1 = 1';
	return this.domainDaoSupport.getListByWhere(sql, null, null, cb);
};

module.exports = {
	id: "simpleDao",
	func: SimpleDao,
	props: [{
		name: "domainDaoSupport",
		ref: "domainDaoSupport"
	}],
	"init": "init"
};
```

详细的 api 文档在 [domainDaoSupport](http://bearcatnode.github.io/bearcat-dao/domainDaoSupport.js.html)



## 事务

Bearcat-dao 基于 [Bearcat AOP]() 提供了事务支持. aspect 是 [transactionAspect](https://github.com/bearcatnode/bearcat-dao/blob/master/lib/aspect/transactionAspect.js) , 提供了 around advice, 当目标事务方法调用cb函数的时候传入了 err, rollback 回滚操作就会被触发, 相反如果没有cb(err)的话, 事务就会被提交(commit).

pointcut 定义的是:

```json
{"pointcut": "around:.*?Transaction"}
```

因此, 任何已 ***Transaction*** 结尾的POJO中的方法都会匹配到 transaction 事务
由于transaction必须在同一个connection中, 在 Bearcat-dao 中是通过 ***transactionStatus*** 来保证的, 在同一个事务的 transaction 必须在同一个transactionStatus中

```js
SimpleService.prototype.testMethodTransaction = function(cb, txStatus) {
	var self = this;
	this.simpleDao.transaction(txStatus).addPerson(['aaa'], function(err, results) {
		if (err) {
			return cb(err); // if err occur, rollback will be emited
		}
		self.simpleDao.transaction(txStatus).getList([1, 2], function(err, results) {
			if (err) { 
				return cb(err); // if err occur, rollback will be emited
			}
			cb(null, results); // commit the operations
		});
	});
}
```



## 多表联合查询

当查询的时候, 默认情况下映射的domain对象就是你给[domainDaoSupport.initConfig](http://bearcatnode.github.io/bearcat-dao/domainDaoSupport.js.html#initConfig)方法传入的domain 在[domainDaoSupport.getList](http://bearcatnode.github.io/bearcat-dao/domainDaoSupport.js.html#getList)和[domainDaoSupport.getListByWhere](http://bearcatnode.github.io/bearcat-dao/domainDaoSupport.js.html#getListByWhere)方法中, 你可以在 options 参数中传入多表查询特定的domain来支持多表查询时的O/R mapping. domain 对象和[init domain](https://github.com/bearcatnode/bearcat-dao#domain-definition)几乎一样, 除了 ***key*** 是用来作为domain的缓存key, 并且不想要指定 ***tableName*** .



### 与[pomelo-sync](https://github.com/NetEase/pomelo-sync)结合使用

在 [pomelo](https://github.com/NetEase/pomelo) 里你可以便捷的使用 [pomelo-sync-plugin](https://github.com/NetEase/pomelo-sync-plugin)

更新 package.json

```bash
npm install pomelo-sync-plugin --save
```

更新 app.js

```js
var sync = require('pomelo-sync-plugin');
app.use(sync, {sync: {path:__dirname + '/app/dao/mapping', dbclient: {}}});
```

我们现在使用bearcat-dao来处理数据库操作（缓存操作）, 因此dbclient可以是一个空的对象, 为了与pomelo-sync进行兼容(pomelo-sync里要求dbclient必须存在)

然后在你应用程序的 app/dao/mapping 目录下面, 你可以编写这样的mappings

helloSync.js

```js
var bearcat = require('bearcat');
var helloSync = {};

module.exports = helloSync;

helloSync.hello = function(dbclient, val, cb) {
	var helloService = bearcat.getBean('hello'); // 通过bearcat管理的helloService bean, 拿到它直接调用里面的doHello方法
	return helloService.doHello(val, cb);
}
```

添加 pomelo-sync exec 调用

```js
app.get('sync').exec('helloSync.hello', helloObj.id, helloObj);	
```

参考:

[pomelo-sync](https://github.com/NetEase/pomelo-sync)

[pomelo-sync-plugin](https://github.com/NetEase/pomelo-sync-plugin)



## 启 Debug 模式

跑node应用时带上BEARCAT_DEBUG为true

```bash
BEARCAT_DEBUG=true node xxx.js
```


## 例子

[bearcat-todo](https://github.com/bearcatnode/todo) the tutorial is [bearcat-todo-tutorial](https://github.com/bearcatnode/bearcat/wiki/web-mvc-todo)

