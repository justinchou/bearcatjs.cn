title: 笨拙的小鸟 clumsy-bird
type: examples
order: 2
---

<iframe width="100%" height="500" src="bearcat-examples/clumsy-bird/index.html" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

相信你一定对 flappy-bird 并不陌生, 这与 `笨拙的小鸟 clumsy-bird` 游戏玩法如出一辙, 尽情的让小鸟存活更长时间吧!

游戏比普通的网页应用更为复杂, 更需要模块化的代码来保持简洁和可维护.

这个游戏Demo使用 [melonjs](https://github.com/melonjs/melonJS) 作为游戏引擎, 官方的代码写在多个分开的文件中, 需要构建一个bundle才能在浏览器中运行.
 
 `melonjs`  为开发者提供了丰富的可用基类,  `melonjs` 库中, 你会经常看到类似如下的代码:

pipeEntity.js
```js
var PipeEntity = me.ObjectEntity.extend({
    init: function(x, y) {
       // ...
	},
    update: function(dt) {
	   // ...
    }
});
```

该类继承自 `melonjs` 提供的基类, 重写你需要的部分. 尽管代码分散的写在多个文件当中, 其实最终是打包在一个文件当中. 所有的变量都是全局的, 你需要注意使用这些变量. 此外, 编辑和调试就显得不那么吸引人了, 因为每次更改代码都需要打包bundle文件.   

使用Bearcat怎么样? 你可以编写模块化的代码, 在真正分开的文件中, 而且无需打包成bundle文件, Bearcat将异步加载这些代码..

想要开始使用Bearcat, 只需要将上面的代码放在bean工厂中, 无论谁需要使用 `PipeEntity` 的时候, 只需要通过工厂构造方法就可以获取实例. bean工厂直接连接Bearcat强大的依赖注入实现功能.

PipeEntityFactory.js
```js
var PipeEntityFactory = function() {
    this.$id = "pipeEntity";
    this.$init = "init";
    this.ctor = null;
};

PipeEntityFactory.prototype.init = function() {
    this.ctor = me.ObjectEntity.extend({
	    init: function(x, y) {
		// ...
	    },
	    update: function(dt) {
		// ...
	    },
    });
};

PipeEntityFactory.prototype.get = function(x, y) {
    return new this.ctor(x, y);
};

bearcat.module(PipeEntityFactory, typeof module !== 'undefined' ? module : {});
```

然后你需要创建一个pipe实例? 只需要将pipe工厂注入其中:

game.js

```js
var Game = function() {
    this.$id = "game";
    this.$pipeEntity = null;
};
  
Game.prototype.loaded = function() {
    var pipeEntity = this.$pipeEntity;
    me.pool.register("pipe", pipeEntity.ctor, true); // register pipeEntity construstor
};
  
bearcat.module(Game, typeof module !== 'undefined' ? module : {});
```

完整的代码在 [bearcat clumsy-bird](https://github.com/bearcatjs/bearcat-examples/tree/master/clumsy-bird)

例子的原工程来自于 [ellisonleao clumsy-bird](https://github.com/ellisonleao/clumsy-bird), 你可以下载下来对比一下.
