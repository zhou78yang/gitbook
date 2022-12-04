# docker实践方案

实践方案默认使用以下目录结构

```bash
.
├── data/				# 用于持久化的目录
└── run.sh				# 启动脚本
```


## registry
<strong>registry</strong>是docker私有仓库镜像

镜像文档：https://docs.docker.com/registry/            
参考文章：https://www.cnblogs.com/gcgc/p/10489385.html           

```bash
cd `dirname $0`

docker run -d \
           -p 5000:5000 \
           --restart always \
           --name registry \
           -v $PWD/data:/var/lib/registry \
           registry:latest
```

> [!Note]
> 可能会出现无法push镜像到私有仓库的问题，大概率是https的原因。这时需要修改客户端docker的配置文件/etc/docker/daemon.json，添加registry服务地址
```json
{
    "insecure-registries": ["x.x.x.x:5000"]
}
```
修改好之后需要重启客户端`Docker`服务使其生效。


## nginx
镜像文档：https://hub.docker.com/_/nginx           
```bash
cd `dirname $0`

docker run -d \
           --restart=always \
           --name=nginx \
           -p 8888:80 \
           -v $PWD/config:/etc/nginx/conf.d \
           -v $PWD/data:/data \
           nginx
```
> [!Warning]
> 默认的nginx配置文件`/etc/nginx/nginx.conf`中配置的user是nginx，工作进程数是1
```
user  nginx;
worker_processes  1;
```


## jenkins
<strong>Jenkins</strong>是一种持续集成工具,用于监控持续重复的工作

镜像文档：
* jenkins [jenkinsci/jenkins](https://github.com/jenkinsci/docker/blob/master/README.md)            
* 带blueocean的Jenkins [jenkinsci/blueocean](https://hub.docker.com/r/jenkinsci/blueocean)            

```bash
cd `dirname $0`

docker run -d \
    -u root \
    -p 7000:8080 \
    -p 7001:50000 \
    -v $PWD/data:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --restart=always \
    --name=jenkins \
    jenkinsci/blueocean
```


## MySQL
[MySQL容器部署](../mysql/docker.md)


## metabase
<strong>Metabase</strong>是一个开源的BI数据可视化平台。 

[镜像使用文档](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html)


```bash
cd `dirname $0`

docker run -d \
           -p 3000:3000 \
           -v $PWD/data:/metabase-data \
           -e "MB_DB_FILE=/metabase-data/metabase.db" \
           --name metabase \
           metabase/metabase
```


## adminer
adminer是一个单页php图形化数据库管理工具

[镜像使用文档](https://hub.docker.com/_/adminer)

```bash
cd `dirname $0`

docker run -d \
           -p 3300:8080 \
           --name adminer \
           adminer
```


## MongoDB
<strong>MongoDB</strong>是一个基于分布式文件存储的数据库

[镜像文档](https://hub.docker.com/_/mongo)

```bash
cd `dirname $0`

docker run -d \
        --memory=2G \
        --restart=always \
        --name mongo \
        -v $PWD/data/db:/data/db \
        -v $PWD/data/configdb:/data/configdb \
        -p 8130:27017 \
        -e MONGO_INITDB_ROOT_USERNAME=<your_username> \
        -e MONGO_INITDB_ROOT_PASSWORD=<your_password> \
        mongo

```
* mongo镜像提供了/data/db和/data/configdb两个目录的挂载
* mongod进程的所有数据文件默认都存储在/data/db里。


## gitbook
<strong>GitBook</strong>是一个基于 Node.js 的命令行工具，可使用 Github/Git 和 Markdown 来制作精美的电子书

[镜像使用文档](https://hub.docker.com/r/fellah/gitbook)


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
		   -p 4000:4000 \
		   --name $CONTAINER_NAME \
		   fellah/gitbook bash -c '/usr/local/bin/gitbook install && /usr/local/bin/gitbook serve'
```


## gitlab

[镜像使用文档](https://docs.gitlab.com/omnibus/docker/)

```bash
cd `dirname $0`


sudo docker run -d \
  --hostname gitlab.example.com \
  -p 4100:443 -p 4101:80 -p 4102:22 \
  --name gitlab \
  --restart always \
  -v $PWD/config:/etc/gitlab \
  -v $PWD/logs:/var/log/gitlab \
  -v $PWD/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest

```
gitlab消耗内存过多，一般需要3-4G内存。


## NextCloud

<strong>Nextcloud</strong>是一款开源免费的私有云存储网盘项目,可以让你快速便捷地搭建一套属于自己或团队的云同步网盘,
从而实现跨平台跨设备文件同步、共享、版本控制、团队协作等功能

[镜像文档地址](https://hub.docker.com/_/nextcloud)

```bash
cd `dirname $0`

docker run -d \
           -u 1000:0 \
		   -v $PWD/data:/var/www/html \
           -p 8900:80 \
		   --name nextcloud \
		   nextcloud
```
* 项目文件和数据都存放在/var/www/html下
* 空项目启动时可以初始化管理员、文件存放位置、数据库等相关配置，也可以通过环境变量初始化
