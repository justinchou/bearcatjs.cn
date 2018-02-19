# bearcatjs.com

中文文档参考 [README.md](README.md)

There is a project in English, See: 

https://gitee.com/justinchou/bearcatjs.com.git OR https://github.com/justinchou/bearcatjs.com.git

English Website Is Avalible On http://bearcatjs.com/ For Preview.


Old site `bearcatjs.org` is no longer about `bearcatjs`, so I fork the project to create `bearcatjs.com` to replace it.

This site is built with [hexo](http://zespia.tw/hexo/). Site content is written in Markdown format located in `source`. Pull requests welcome!

Old site packages dependency is managed just by npm `package.json`, and some of the new version hexo user cannot build the project, so I add `yarn` package manager. 

## Developing

Start a dev server at `localhost:4000`:

clone
```
git clone https://github.com/bearcatjs/bearcatjs.org.git --recursive
```

How to install dependency with `npm`
```
$ npm install -g hexo-cli
$ npm install
```

How to install dependency with `yarn`
```
$ yarn add -G hexo-cli
$ yarn install
```

Generate Html code and start server
```
$ hexo generate
$ cp -rf bearcat-examples public/examples 
$ hexo server
```

## using make to compile

1. `make`         : clean, compile, copy dependency
2. `make generate`: clean, generate html, start server
3. `make update`  : update dependency examples
4. `make deploy`  : make and deploy to server器

