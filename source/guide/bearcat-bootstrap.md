title: bearcat-bootstrap.js文件
type: guide
order: 8
---

众所周知, 前端浏览器没有异步加载一说, 因此***bearcat-bootstrap.js***文件用于告诉Bearcat如何根据meta配置加载那些文件.

bearcat-bootstrap.js 文件是自动生成的, 无需手写.  

安装 bearcat

```
npm install -g bearcat

yarn add -G bearcat
```

然后在工程的根目录执行下面代码生成 bearcat-bootstrap.js 文件.

```
bearcat generate
```

可以通过script标签, browerify的require方法, 或者amd的define方法来加载该文件.  

``` html
<script src="bearcat-bootstrap.js"></script>
```

***注意***

仅当增加/删除某个文件, 或者移动文件路径的时候需要重新生成`bearcat-bootstrap.js`, 当仅仅是修改文件内容, 则无需重新生成.