# bearcatjs.com

For English Documents: [README-EN.md](README-EN.md)

中文文档的预览版本, 我放在了Coding.net上面进行托管, 参考: http://bearcatjs.cn/

原有网站 `bearcatjs.org` 不知为何原因, 现在提供服务的内容与`bearcatjs`毫无关联, 所以fork此工程建立新站`bearcatjs.com`来暂代.

本站基于 [hexo](http://zespia.tw/hexo/) 编写. 内容使用Markdown编写, 保存于`source`目录下, 欢迎加入提交代码.

原有网站基于`npm`默认的`package.json`进行包的管理, 以至于有些包依赖问题导致此时已经无法正常编译, 所以我引入了`yarn`进行本工程的包依赖管理.

## 如何玩儿转本工程

测试服务器启动后, 使用浏览器访问 `http://localhost:4000`.

clone本工程代码
```
git clone https://github.com/bearcatjs/bearcatjs.org.git --recursive
```

使用npm安装依赖包
```
$ npm install -g hexo-cli
$ npm install
```

使用yarn安装依赖包
```
$ yarn add -G hexo-cli
$ yarn install
```

生成网站,启动服务器
```
$ hexo generate
$ cp -rf bearcat-examples public/examples 
$ hexo server
```

## 使用make命令编译工程

1. `make`         : 清理,编译,复制依赖 (部署正式服务前使用)
2. `make generate`: 清理,生成网站,启动网站 (编写/更改文字内容时使用)
3. `make update`  : 更新依赖工程
4. `make deploy`  : 编译,部署到服务器

