# gitbook容器部署方案

容器启动相关的可以参照[常用容器部署方案](../examples.md)中的gitbook部分


## dockerfile
开发环境
```bash
FROM node:6-slim

ARG VERSION=3.2.1

LABEL version=$VERSION

RUN npm install --global gitbook-cli &&\
	gitbook fetch ${VERSION} &&\
	npm cache clear &&\
	rm -rf /tmp/*

COPY ./data /srv/gitbook
WORKDIR /srv/gitbook

CMD /usr/local/bin/gitbook serve
```

正式环境（改用nginx部署）
```bash
FROM node:6-slim as build-stage

ARG VERSION=3.2.1

LABEL version=$VERSION

RUN npm install --global gitbook-cli &&\
	gitbook fetch ${VERSION} &&\
	npm cache clear &&\
	rm -rf /tmp/*

COPY ./data /srv/gitbook
WORKDIR /srv/gitbook
RUN /usr/local/bin/gitbook install && \
    /usr/local/bin/gitbook build

FROM nginx as prod-stage

COPY --from=build-stage /srv/gitbook/_book /usr/share/nginx/html

```


## 运行

### windows下运行

windows/wsl2 会有文件收集失败的问题，需要手动替换js文件

```bash
cd `dirname $0`

CONTAINER_NAME='gitbook'
# 杀死现有的容器
CONTAINER_ID=`docker ps -a | grep $CONTAINER_NAME | grep -v prv | awk '{print $1}'`
if [ $CONTAINER_ID ]; then
    docker rm -f $CONTAINER_ID
    echo 'delete container '$CONTAINER_ID
fi

docker run -d \
		   -v $PWD/data:/srv/gitbook \
		   -v $PWD/codes/gitbook/copyPluginAssets.js:/root/.gitbook/versions/3.2.1/lib/output/website/copyPluginAssets.js \
		   -p 4000:4000 \
		   --name $CONTAINER_NAME \
		   gitbook bash -c '/usr/local/bin/gitbook install && /usr/local/bin/gitbook serve'

```
