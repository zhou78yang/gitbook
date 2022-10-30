# 安装和管理

## 安装

1.Docker安装
```bash
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```
启动后:
```bash
$ docker ps -a
CONTAINER ID   IMAGE                   COMMAND                  CREATED          STATUS          PORTS                                                                                                         NAMES
10099c6e73b9   rabbitmq:3-management   "docker-entrypoint.s…"   12 minutes ago   Up 12 minutes   4369/tcp, 5671/tcp, 0.0.0.0:5672->5672/tcp, 15671/tcp, 15691-15692/tcp, 25672/tcp, 0.0.0.0:15672->15672/tcp   rabbitmq

```
*5672为消息中间件的端口，15672为管理页面端口，管理页面默认账号密码为guest:guest*

### 单容器部署
启动脚本示例
```bash
cd `dirname $0`

docker run  -d \
	--memory=1G \
	--restart=always \
	--name rabbitmq \
	-p 8001:5672 \
	-p 8002:15672 \
	-v $PWD/data:/var/lib/rabbitmq \
	--hostname node-1 \
	-e RABBITMQ_DEFAULT_USER=${RABBIT_USERNAME} \
	-e RABBITMQ_DEFAULT_PASS=${RABBIT_PASSWORD} \
	rabbitmq:3-management

```
注意，需要指定`hostname`，rabbitmq的持久化文件是根据hostname命名的，所以需要固定hostname才能实现队列消息持久化。


2.Ubuntu安装
文档链接: https://www.rabbitmq.com/install-debian.html


## API
RabbitMQ提供了一套管理页面的API接口可以提供查询，通过Http Basic Authentication进行用户认证

文档地址: `http://{{HOST}}:{{PORT}}/api/index.html`


## 参考
* 安装RabbitMQ [链接](https://www.rabbitmq.com/download.html)
