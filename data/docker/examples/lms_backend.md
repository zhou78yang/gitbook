# 基于Django的应用部署实践

部署设计
* docker-compose编排容器
* docker以supervisord前端启动作为容器主进程
* supervisor管理对应服务所需进程，开发者通过conf中各个服务的supervisor-app.conf配置来管理服务进程

## 后端容器
Dockerfile文件
```Dockerfile
FROM python:3.7-stretch

MAINTAINER starmerx_yangchi

# 系统apk层
RUN apt-get update && \
    apt-get install -y \
    git \
    gettext \
    nginx \
    supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install -U pip

# COPY项目依赖文件，在依赖文件没有变化的时候不会重新构建这一层
COPY requirements.txt /home/app/
RUN pip3 install -r /home/app/requirements.txt -i https://pypi.douban.com/simple

# 源代码和配置文件COPY到镜像文件内主要是为了实现不挂载目录也能跑和API多版本发布
COPY ./lms /home/app/lms
COPY ./conf /home/app/conf
COPY ./entrypoint.sh /home/app/entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/home/app/entrypoint.sh"]

```


## docker-compose
docker-compose文件配置
```yaml
version: "3.7"

services:

  backend:
    container_name: "app_backend"
    restart: always
    build: .
    image: backend:latest
    env_file:
      - ./conf/.env
    volumes:
     - ./:/home/app
    ports:
     - 9010:80
    depends_on:
     - redis
    networks:
      - app

  redis:
    container_name: "app_redis"
    restart: always
    image: redis
    ports:
     - 9015:6379
    networks:
     - app

  frontend:
    container_name: "app_frontend"
    restart: always
    image: nginx
    volumes:
     - ./frontend/dist:/usr/share/nginx/html
     - ./frontend/nginx:/etc/nginx/conf.d
    ports:
     - 9012:80
    networks:
     - app

  celery:
    container_name: "app_celery"
    restart: always
    build:
      context: .
      dockerfile: ./dockerfiles/consumer/Dockerfile
    image: consumer:latest
    env_file:
     - ./conf/.env
    volumes:
     - ./conf/celery/supervisor-app.conf:/home/app/conf/supervisor-app.conf
     - ./:/home/app
    networks:
     - app
    depends_on:
     - redis

  kafka:
    container_name: "app_kafka"
    restart: always
    build:
      context: .
      dockerfile: ./dockerfiles/consumer/Dockerfile
    image: consumer:latest
    env_file:
     - ./conf/.env
    volumes:
     - ./conf/kafka/supervisor-app.conf:/home/app/conf/supervisor-app.conf
     - ./:/home/app
    networks:
     - app

  shell:
    container_name: "app_shell"
    restart: always
    build:
      context: .
      dockerfile: ./dockerfiles/shell/Dockerfile
    image: shell:latest
    env_file:
      - ./conf/.env
    volumes:
      - ./conf/crontab/crontab:/etc/init.d/crontab
      - ./:/home/app
    depends_on:
      - redis
    networks:
      - app

  rabbit:
    container_name: "app_rabbit"
    restart: always
    build:
      context: .
      dockerfile: ./dockerfiles/consumer/Dockerfile
    image: consumer:latest
    env_file:
     - ./conf/.env
    volumes:
     - ./conf/rabbitmq/supervisor-app.conf:/home/conf/supervisor-app.conf
     - ./:/home/app
    networks:
     - app

networks:
  app:
    name: "app"
    driver: bridge
```
