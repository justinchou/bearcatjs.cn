title: 多页面依赖
type: examples
order: 0
---

<iframe width="100%" height="300" src="bearcat-examples/example-multipage/car_BMW.html" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

本例子展示两个页面, 每个页面均异步加载不同的脚本文件

BMW页面, 使用  `bmwCarController` , 依赖  `bmwCar` 

bmwCarController.js

```js
var BmwCarController = function() {
    this.$id = "bmwCarController";
    this.$bmwCar = null;
};
  
BmwCarController.prototype.run = function() {
    this.$bmwCar.run();
};
  
bearcat.module(BmwCarController, typeof module !== 'undefined' ? module : {});
```

 `bmwCar`  依赖 `bmwEngine` 和 `bmwWheel`  

bmwCar.js

```js
var BmwCar = function() {
    this.$id = "bmwCar";
    this.$bmwEngine = null;
    this.$bmwWheel = null;
    this.$printUtil = null;
};
  
BmwCar.prototype.run = function() {
    this.$bmwEngine.start();
    this.$bmwWheel.run();
    var msg = 'bmwCar run...';
    console.log(msg);
    this.$printUtil.printResult(msg);
};
  
bearcat.module(BmwCar, typeof module !== 'undefined' ? module : {});
```
 
将这些统统使用Bearcat打包 
```html
<script src="./lib/bearcat.js"></script>
<script src="./bearcat-bootstrap.js"></script>
<script type="text/javascript">
bearcat.createApp();
bearcat.use(['bmwCarController']);
bearcat.start(function() {
    var bmwCarController = bearcat.getBean('bmwCarController');
    bmwCarController.run()
})
</script>
```

完整源代码在 [example-multipage](https://github.com/bearcatjs/bearcat-examples/tree/master/example-multipage)

