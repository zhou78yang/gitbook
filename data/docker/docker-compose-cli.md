# docker-compose-cli
> 通常使用`docker-compose --help`和`docker-compose COMMAND --help`查看usage或者直接查阅官方文档: https://docs.docker.com/compose/reference/overview/ 			

## 常用指令
* build: 构建最新的service(如果有更新的话)
* config: 查看compose配置
* create: 创建service（已经弃用，用`up --no-start`替代）
* down: 停止并删除容器，网络，镜像，数据卷等
* logs: docker logs的compose版本
* pull: 拉service镜像
* push: 推service镜像
* restart: 重启service，**改动的compose配置并不会生效**
* start: 启动service容器
* stop: 停止service容器
* top: docker top的compose版本
* up: create && start 容器，**改动的compose配置会生效，会recreate service**


## 指定compose file
通过`-f`参数可以指定一个或者多个compose file，后者会覆盖前面的配置
例如：
```bash
$ docker-compose -f docker-compose.yml -f docker-compose.admin.yml run backup_db
```
其中，`docker-compose.yml`定义了`webapp`的配置为:
```yaml
webapp:
  image: nginx
  ports:
    - "8000:80"
  volumes:
    - "./data:/usr/share/nginx/html"
```
`docker-compose.admin.yml`中定义了`webapp`的配置为:
```yaml
webapp:
  build: .
  ports:
    - "4000:80"
  environment:
    - DEBUG=1
```
结果：
```bash
$ docker inspect -f '{{json .NetworkSettings.Ports}}' $CONTAINER_NAME
{"80/tcp":[{"HostIp":"0.0.0.0","HostPort":"4000"},{"HostIp":"0.0.0.0","HostPort":"8000"}]}
```

> [!Note]
> 当使用`-f`指定多个compose file时，所有compose file的路径都是相对于第一个compose file的路径的。				
> 或者可以使用`--project directory`显式指定项目路径


