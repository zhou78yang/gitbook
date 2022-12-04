# NextCloud

<strong>Nextcloud</strong>是一款开源免费的私有云存储网盘项目,可以让你快速便捷地搭建一套属于自己或团队的云同步网盘,
从而实现跨平台跨设备文件同步、共享、版本控制、团队协作等功能

## 安装
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

## 同步文件
我们可能存在不通过Web页面/客户端直接修改文件的情况，或者新建服务时，存储的目录并不为空。
NextCloud默认不会自动同步这些文件，所以需要手动扫描文件存储文件。

`/var/www/html`目录下有一`occ`的可执行文件
```bash
php occ files:scan --all        # 扫描全部用户
php occ files:scan <username>   # 扫描指定用户
```

通过容器部署情况
```bash
docker exec nextcloud php occ files:scan --all
```

## 性能优化
参考资料：https://www.jianshu.com/p/55fd5ddafb1a
