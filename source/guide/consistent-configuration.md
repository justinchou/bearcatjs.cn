title: 一致的配置文件
type: guide
order: 5
---

## 概览

在Nodejs开发过程中, 一般都会有多个环境, 例如development, test, production等等. 不同环境是根据配置文件的不同实现的. 因此有必要保持这些配置文件一致.

## 使用占位符
  
占位符是一个变量代表该位置将被指定环境下的某值所替代. Bearcat中, 占位符这样定义: 

```js
${car.num}
```

配置文件config.json中, 给 ***car.num*** 赋值.

```json
{"car.num": 100}
```

## 环境配置

在Bearcat中, 可以用以下格式编写不同环境的配置文件:
![directory structure](/images/configuration-structure.png)

在 ***config*** 文件夹中, 放置 ***dev*** 和 ***prod*** 子文件夹, 文件夹名即为对应的环境名, 然后在文件夹下编写对应环境下的配置.  

## 切换环境

Bearcat中, 使用如下方法切换环境:

* 启动时指定 ***env*** 或者 ***--env*** 参数

```bash
node app.js env=prod
```

* 或者指定环境变量 NODE_ENV
  
```bash
NODE_ENV=prod node app.js
```

默认情况下, env环境变量值为  ***dev*** 
