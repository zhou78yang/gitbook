# Mysql容器部署

参考文档：https://hub.docker.com/_/mysql

## 快速启动
```bash
docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
```

## 脚本部署
```bash
cd `dirname $0`

CONTAINER_NAME='mysql'

# 杀死现有的容器
CONTAINER_ID=`docker ps -a | grep $CONTAINER_NAME | grep -v prv | awk '{print $1}'`
if [ $CONTAINER_ID ]; then
    docker rm -f $CONTAINER_ID
    echo 'delete container '$CONTAINER_ID
fi

NETWORK_COUNT=`docker network ls | grep mysql-network | wc -l`
if [ $NETWORK_COUNT -lt 1 ]; then
	docker network create mysql-network
fi

docker run -d \
		   -v $PWD/data:/var/lib/mysql \
		   -v $PWD/conf:/etc/mysql/conf.d \
		   --env-file $PWD/.env \
		   --network mysql-network \
		   -p 6600:3306 \
		   -p 6601:33060 \
		   --name $CONTAINER_NAME \
		   mysql
```

`.env`文件内容
```bash
MYSQL_ROOT_PASSWORD=secret      # 管理员密码
```