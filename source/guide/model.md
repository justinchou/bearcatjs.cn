title: 如何使用Model定义数据对象
type: guide
order: 10
---

Bearcat中的Model支持将数据库映射为可操作的对象, 同时做相应的校验(数值, 字符串长度等等), 支持设置自定义约束等.

后期可以配合 bearcat-dao 一起使用, 实现数据库的抽象.

<!--more-->

## 定义 Model

Model 也是 普通的js对象POJO.

* $mid 设置 model 的唯一id
* $table 设置 model 的对应数据表
* $prefix 设置表单前缀, 字段前面自动增加该前缀, 其他表引用的时候可以通过引用字符串的 prefix=xxx 覆盖
* $objId 同样可以根据其他对象$id来注入其他对象

### 支持的一些设置方法:

1. 初始化赋值
2. 定义主键 $primary, 定义使用ddb分库分表基键 $balance
3. 定义 $type:Number|String 类型限制, (不支持Boolean/Null/Undefined...)
4. 支持 $type:Number;default:20 或者 $type:String;default:'' 设置默认值, 中间以;间隔
5. 支持 $max:20 $min:10 设置数字类型范围
6. 支持 $notNull $null 设置是否为空
7. 支持 $pattern(regexp=test) 设置字符串类型的匹配
8. 支持 $size(max=10,min=3) 设置字符串长度范围
9. 支持 $type:Object/Array;ref:xxx 引用其他Model(一对一/一对多结构)
0. 支持 $prefix:xxx 重写引入其他Model的时候的前缀
1. 自定义类型约束

```js
var UserModel = function() {
    this.$mid     = 'userModel';
    this.$table   = 'user';
    this.$prefix  = 'user_';  // 当数据库中表已经有前缀的时候

    this.id       = "$primary;type:Number";
    this.name     = "$type:String;notNull";
    this.gender   = 1;
    this.age      = "$type:Number;max:99;min:18;notNull;default:18";
    this.location = "$pattern(regexp=beijing);size(max=64,min=10)";

    this.games    = "$type:Array;ref:game"
};
UserModel.prototype.checkNum = function(k, v) {
    if (typeof v !== "number") {
        return new Error('invalid number [ %s ]', v);
    }
};
UserModel.prototype.fixAge = function() {
    this.age = Math.floor(this.age);
    if (this.age < 0) {this.age = 0;}
};
UserModel.prototype.log = function() {
    console.log('value changed ready to emit sth.');
};
module.exports = UserModel;
```




### 自定义类型约束 constraint

自定义约束类型 也是 普通的js对象POJO.

* $cid 设置 constraint 唯一ID
* $constraint 设置约束 $notNull
* message 约束不符合的时候返回的内容模板
* max, min... 设置约束的时候设置的变量, 通过validate方法进行判断的时候使用

```js
var Util = require('util');
var SizeConstraint = function() {
    this.$cid = 'userAge';
    this.$constraint = '$notNull';
    this.msg = 'user age invliad %s';
    this.min = null;
    this.max = null;
};
SizeConstraint.prototype.validate = function(key, value) {
    if (value < this.min || value > this.max) {
        return new Error(Util.format(this.msg, value));
    }
};
module.exports = SizeConstraint;
```

使用约束的时候:

```js
this.age = "$type:Number;userAge(min=18,max=99)"
```


## 使用魔术方法

### 如何 $get/$set/$pack/$packResultSet 存取数据

```js
var um = bearcat.getModel('userModel');

um.$set("id", 1);
um.$pack({id: 2, name: "justin"});
um.$packResultSet({id: 2, name: "chow", gender: 0, age: 23, location: "chaoyang, beijing"});
console.log(um.model);

var v = um.$get("name");
console.log(v);
```

* $set 设置单个值

在类型或其他限制不符合的时候设置不成功, 返回错误

* $pack 批量设置多个值

在某一个值的类型或其他限制不符合的时候, 全部值均设置不成功, 返回错误

* $packResultSet 将数据库查询的数据打包生成对应对象

不符合类型或限制的值以及之后的值设置不成功, 前面的已经通过的会设置成功


### 通过 $before/$after 设置操作注入

```js
um.$before(['checkNum']).$after(['fixAge', 'log']).$set('age', 22.5);
um.$after(['fixAge', 'log']).$get('age');
um.$after(['fixAge', 'log']).$pack({'age': 22.5, 'gender': 1});
um.$after(['fixAge', 'log']).$packResultSet({'age': 22.5, 'gender': 1});
```

其中 $set 有 $before 和 $after 两个注入器, $get/$pack/$packResultSet 都只有 $after 注入器.

注入器均为函数名的数组, 如果是只有一个函数名, 那么可以在此函数中返回函数名数组:

```js
$after(['fixAge', 'log']) => $after('after')
```

此时:

```js
UserModel.prototype.after = function() {
    return ['fixAge', 'log'];
}
```

## 获取对象的数据值

```js
um.toJson() === um.model
```


## 捕获异常

无论 $set/$pack/$packResultSet 返回值均为 err|null

```js
var err = um.$set(name, "bearcat");
if (err) { 
    console.log(err.stack); 
}
```







