title: markdown编辑器
type: examples
order: 1
---

<iframe width="100%" height="500" src="bearcat-examples/browserify-markdown-editor/index.html" allowfullscreen="allowfullscreen" frameborder="0"></iframe> 

Browserify通过将所有依赖打包的方式, 让你可以简单的使用require('modules')来加载一个模块. 因此, 使用browserify加载一个库只需要 `require('library')` 即可. 

然而, browserify将左右代码打包, 编辑与调试就略显得繁琐. 任何情况下代码的更新都需要重新构建bundle, 此外当出现错误的时候, 错误将在浏览器中打印出来, 提示开发者. 有经验的开发者知道如何借助 [source-map](http://thlorenz.com/blog/browserify-sourcemaps)

使用Bearcat, browserify将仅作为库依赖的解析功能存在, 开发者书写神奇的JavaScript对象, 如果需要使用库, browserify负责解析依赖.

下面例子展示如何在Bearcat中使用browserify:

首先, 你需要一个名为 `requireUtil` 的JavaScript对象, 作为Bearcat与browserify之间的桥梁. 这个文件需要与browserify打包在一起, 同时又能调用browserify中的 `require` 方法解析库.

然后在其他文件需要从browserify中引用库的时候, 只需要注入 `requireUtil` 到该文件中即可.

requireUtil.js

```js
var RequireUtil = function() {
    this.$id = "requireUtil";
    this.$init = "init";
    this.brace = null;
};
  
RequireUtil.prototype.init = function() {
    this.brace = require('brace');
};
  
bearcat.module(RequireUtil, typeof module !== 'undefined' ? module : {});
```

接着在控制器JavaScript文件中,  使用魔法属性 `$requireUtil` 注入 `requireUtil` 

markDownController.js

```js
var MarkDownController = function() {
    this.$id = "markDownController";
    this.$requireUtil = null; // requireUtil is ready for you to use
};
  
bearcat.module(MarkDownController, typeof module !== 'undefined' ? module : {});
```

最后专注于编写业务逻辑: 

markDownController.js

```js
var MarkDownController = function() {
    this.$id = "markDownController";
    this.$requireUtil = null; // requireUtil is ready for you to use
};
  
MarkDownController.prototype.initBrace = function(md) {
    var ace = this.$requireUtil.brace;
    var editor = ace.edit('editor');
    editor.getSession().setMode('ace/mode/markdown');
    editor.setTheme('ace/theme/monokai');
    editor.setValue(md);
    editor.clearSelection();
    return editor;
};
  
bearcat.module(MarkDownController, typeof module !== 'undefined' ? module : {});
```

因为 `markDownController` 文件是异步加载的, 所以你可以尽情的编辑或者调试...   

完整源代码在 [bearcat browserify-markdown-editor](https://github.com/bearcatjs/bearcat-examples/tree/master/browserify-markdown-editor)  
例子的原工程来自于 [thlorenz browserify-markdown-editor](https://github.com/thlorenz/browserify-markdown-editor), 你可以下载下来对比一下.