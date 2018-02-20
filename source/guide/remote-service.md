title: Remote 服务
type: guide
order: 11
---

## 概述

Bearcat 提供了remote支持用于处理rpc remote服务, 它由 [Bearcat-remote](https://github.com/bearcatnode/bearcat-remote) 支持

## Bearcat-remote

Bearcat-remote 提供了 rpc remote 支持, 封装了 Bearcat and rpc 库比如 [dnode](https://github.com/substack/dnode). 使得在node.js中使用rpc remote非常容易.

## 安装

```
npm install bearcat-remote --save
```

## 添加 context.json 元数据配置

```
{
	"name": "bearcat-remote",
	"dependencies": {
	    "bearcat-remote": "*"
	}
}
```

## rpc remote

### 使用dnode暴露remote服务

* 使用 ***dnodeServiceExporter*** 导出remote服务 当然, 首先我们需要在Bearcat IoC容器中定义自己的service:

remoteService.js

```
var remoteService = function() {

}
remoteService.prototype.remotePing = function(ping, cb) {
	console.log(ping);
	cb('pong');
}
module.exports = remoteService;
```

```
{
	"id": "remoteService",
	"func": "remoteService"
}
```

* 接下来, 我们通过 dnodeServiceExporter 来导出service为remote

```
{
	"id": "dnodeServiceExporter",
	"func": "node_modules.bearcat-remote.lib.remote.dnode.dnodeServiceExporter",
	"props": [{
		"name": "service",
		"ref": "remoteService"
	}, {
		"name": "port",
		"value": 8003 
	}, {
		"name": "host",
		"value": "localhost" 
	}]
}
```

* 客户端连接remote service 使用dnodeDynamicProxy设置客户端代理来连接remote service:

```
{
	"id": "dnodeClient",
	"func": "node_modules.bearcat-remote.lib.remote.dnode.dnodeDynamicProxy",
	"init": "dyInit",
	"async": true,
	"destroy": "dyDestroy",
	"props": [{
		"name": "serviceHost",
		"value": "localhost"
	}, {
		"name": "servicePort",
		"value": 8003
	}, {
		"name": "serviceInterface",
		"value": ["remotePing"]
	}]
}
```

### 启动 Bearcat 跑起来

```
var Bearcat = require('bearcat');

var simplepath = require.resolve('./context.json');
var paths = [simplepath];
var bearcat = Bearcat.createApp(paths);

bearcat.start(function() {
	var dnodeClient = bearcat.getBean('dnodeClient');
	dnodeClient.remotePing('ping', function(msg) {
		console.log(msg); // pong
	});
});
```
