title: context.json文件
type: guide
order: 8
---

context.json是Bearcat需要的唯一的配置文件

### 上下文属性

上下文属性使用json文件来定义, 包含以下属性:

* name: 定义工程或者库的名字  
* scan: bearcat自动扫描的bean目录, 可以是简单的字符串或者是多个路径的数组
* imports: 数组, 循环嵌套的引用其他子 context.json 路径  
* namespace: 一个字符串标记命名空间.

所有本context.json自动加载路径下的bean, 都将包含在本namespace下面.

Bearcat中, 指定了namespace之后, 使用依赖注入或者getBean方法时, 需要加上namespace属性: 

```json
{"namespace": "namespace name"}
```

* beans: 指定beans的meta数据, 定义容器中被管理的bean, 是一个[bean meta数据](/guide/magic-javaScript-objects-in-details.html#Bean_attribute)组成的数组.
* dependencies: 标识在依赖的子模块中有需要被容器管理的beans  



### 举个🌰

{
    "name": "bean-context-example",
    "scan": "app",
    "imports": ["classes/context.json", "model/context.json"],
    "namespace": "App",
    "beans": [{
        "id": "car",
        "func": "car",
        "scope": "prototype",
        "args": [{
            "name": "num",
            "type": "Number"
        }]
    }],
    "dependencies": []
}