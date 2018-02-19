all: update
	hexo clean
	hexo generate
	cp -rf bearcat-examples public/examples

g:
	hexo clean
	hexo generate
	hexo server

generate: g

d:	all
	hexo deploy

deploy: d

u:
	cd bearcat-examples && git checkout master && git pull

update: u