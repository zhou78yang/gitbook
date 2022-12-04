# docker-compose

`docker-compose`是一个用于编排多个容器的docker应用，它通过yaml文件进行配置，然后使用`docker-compose`命令可以快速地管理多个`Docker Object`。					

使用Compose的通常步骤:
1. 通过`Dockerfile`确保运行环境一致;
2. 将应用需要的services通过`docker-compose.yml`文件编排在一起，整合到一个独立空间（网络）;
3. 通过`docker-compose`命令行工具启动services;

yaml配置文件大概长这样
```yaml
version: "3.9"  # optional since v1.27.0
services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/code
      - logvolume01:/var/log
    links:
      - redis
  redis:
    image: redis
volumes:
  logvolume01: {}
```


## 安装
参考文档: https://docs.docker.com/compose/install/


## 环境变量
Compose中配置环境变量有两种方案:
* 通过environment直接在yaml配置中指定 [文档](https://docs.docker.com/compose/environment-variables/)
* 通过env_file指定环境变量文件，**env_file修改后使用`docker-compose up`也会创建新容器** [文档](https://docs.docker.com/compose/env-file/)

```yaml
version: "3.7"

services:
  web:
    image: nginx
    container_name: web
    ports:
      - "8008:80"
    environment:
      - DEBUG=1
    env_file:
      # 相对项目目录
      - .env
      
```


## Compose与网络
参考文档: https://docs.docker.com/compose/networking/ 					

现有以下的一个配置文件
```yaml
# myapp/docker-compose.yml
version: "3.9"
services:
  web:
    build: .
    ports:
      - "8000:8000"
  db:
    image: postgres
    ports:
      - "8001:5432"
```
当`docker-compose up`时会发生什么：
1. 创建一个名为`myapp_default`的Network;
2. 通过`web`的配置创建一个容器，它在`myapp_default`中的名字为`web`;
3. 通过`db`的配置创建一个容器，它在`myapp_default`中的名字为`db`；

现在compose中的每一个容器都能通过service名找到指定的容器，而不需使用具体的ip，方便我们在配置文件中配置后端服务


### 自定义network
```yaml
version: "3"
services:

  proxy:
    build: ./proxy
    networks:
      - frontend
  app:
    build: ./app
    networks:
      - frontend
      - backend
  db:
    image: postgres
    networks:
      - backend

networks:
  backend:
    # 指定桥接模式
    driver: bridge
  frontend:
    # 使用自定义driver
    driver: custom-driver-1

```


### 使用已存在的network
```yaml
networks:
  default:
    external:
      name: my-pre-existing-network
```


## 参考文档
* Overview https://docs.docker.com/compose/
* compose配置的版本和可支持的最早docker引擎参考 https://docs.docker.com/compose/compose-file/
* Networking in Compose https://docs.docker.com/compose/networking/
