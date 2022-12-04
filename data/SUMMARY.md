# Summary

## 开始
[开始](./README.md)

## Go
- Go语言基础
  - [Go快速入门](./go/go快速入门.md)
  - [空结构体](./go/lang/empty_struct.md)
  - [json](./go/std/json.md)

## Python
* Django
    * Model
        - [Django模型继承](./python/django/model/inherit.md) 
    * [缓存](./python/django/cache/cache.md)
        - [django-redis](./python/django/cache/django-redis.md)
        - [Django使用RedisCluster做缓存](./python/django/cache/redis-cluster.md)
    * 查询
        - [分组](./python/django/query/annotate.md) 
        - [聚合](./python/django/query/aggregate-expressions.md)
    * [中间件](./python/django/middleware.md)
    * [信号Signal](./python/django/signal.md) Django内置的一种解耦方式
    * [Channel](./python/django/django_channels/base.md) Django提供的websocket框架
    * [资料](./python/django/resource.md) Django的一些拓展资料整理
* [Django-Rest-Framework](./python/django/django_rest_framework/base.md)
    - [APIView](./python/django/django_rest_framework/views.md)
    - [ViewSet](./python/django/django_rest_framework/viewset.md)
    - [认证和权限](./python/django/django_rest_framework/auth.md)
    - [搜索](./python/django/django_rest_framework/search.md)
* Flask
    - [快速上手](./python/flask/base.md)
* 语言
    - [装饰器](./python/decorator.md)
    - [typing](./python/typing.md)
    - [dataclass](./python/dataclass.md)
    - [inspect](./python/inspect.md)
    - [python重定向输出延迟问题](./python/solutions/python-stdout-redirect.md)
* [env环境](./python/env.md) 常用env工具
* [pipenv](./python/pipenv.md)
* 网络协议及网络数据处理
    - [requests](./python/requests.md) http网络请求
    - [suds/suds-py3](./python/suds.md) WebService请求
    - [email](./python/email/email.md) 邮件基本概念及email发送
    - [常用的email客户端](./python/email/常用的email客户端.md)
    - [socket](./python/socket.md) socket简介
* 数据处理
    - [json](./python/json.md) JSON编码和解码器
    - [xmltodict](./python/xmltodict.md) xml与dict转换方法，常用`parse`和`unparse`
    - [PDF处理](./python/pdf.md) pdf处理: reportlab, pdfminer, pdfkit
    - [excel处理](./python/excel.md) excel文件处理
* [keyring](./python/keyring.md) 访问系统keyring(钥匙串)服务的第三方包，方便存储秘钥
* Scrapy
    - [快速上手](./python/scrapy/start.md)
    - [基础知识](./python/scrapy/基础知识.md)
* 测试
    - [doctest](./python/test/doctest.md)
* cookbook
    - [单例模式](./python/singleton.md)

## 后端
- MySQL
    - [MySQL架构](./backend/mysql/mysql架构.md) MySQL服务器架构和存储引擎
	- [JSON数据类型](./backend/mysql/json.md)
	- [容器部署方案](./backend/mysql/docker.md)
	- 使用
	    - [MySQL服务密码找回](./backend/mysql/usage/mysql-forgot-password.md)
	    - [MySQL 5.7 用户添加及授权操作](./backend/mysql/usage/mysql-grant.md)
	- [隔离级别](./backend/mysql/隔离级别/隔离级别.md)
	    - [幻读](./backend/mysql/隔离级别/幻读.md)
	    - 测试
	        - [读未提交/脏读](./backend/mysql/隔离级别/脏读test.md)
            - [读已提交/不可重复读](./backend/mysql/隔离级别/不可重复读test.md)
            - [可重复读/幻读](./backend/mysql/隔离级别/幻读test.md)
    - [并发控制](./backend/mysql/并发控制.md)
    - [复制](./backend/mysql/复制.md)
    - 优化
    	- [InnoDB分页优化](./backend/mysql/优化/innodb分页优化.md)
- Redis
    - [redis基础](./backend/redis/碎片.md)
    - [redis分布式锁](./backend/redis/redis-lock.md)
    - [资料汇总](./backend/redis/redis复习.md)
- RabbitMQ
  - [安装和管理](./backend/rabbitmq/install.md) docker部署，管理页面，API接口
  - [快速上手](./backend/rabbitmq/tutorial.md)
  - [死信和延迟队列](./backend/rabbitmq/dead-letter.md)
  - [消息和队列的失效时间](./backend/rabbitmq/ttl.md)
  - [心跳检测](./backend/rabbitmq/heartbeat.md)
  - [pika](./backend/rabbitmq/pika.md) 
  - [rabbitmqctl](./backend/rabbitmq/rabbitmqctl.md)
  - [拓展资料](./backend/rabbitmq/资料汇总.md)
- Linux
  - [服务器性能指标](./backend/linux/load.md)
- [Apollo](./backend/apollo.md) 是一款可靠的分布式配置管理中心。
- [Jenkins](./backend/jenkins.md) 是一个开源自动化服务器，可用于自动化与构建、测试、交付或部署软件相关的所有任务。
- nginx 是一个HTTP和反向代理服务器、邮件代理服务器和通用TCP/UDP代理服务器
  - [Nginx配置](./backend/nginx.md)
- [supervisor](./backend/supervisor.md) 一个基于C/S结构的进程管理工具
- [Kibana](./backend/kibana.md) 是Elastic Stack中的可视化工具
- [阿里云OSS](./backend/oss.md)
  - [OSS Web应用开发](./backend/oss-web.md)
- [钉钉工作通知对接](./backend/dingtalk.md)


## 软件工程
- 工程
  - [12-factor原则](./se/12-factor.md) 一套SaaS应用的方法论
- 编码
  - [设计原则](./code/设计原则.md)
  - [命名规范](./code/naming.md)
  - [LBYL和EAFP两种防御性编程风格](./code/lbyl_n_eafp.md)
- 安全
  - [CVSS](./security/cvss.md)(Common Vulnerability Scoring System, 通用漏洞评分系统)是一个行业公开标准，其被设计用来评测漏洞的严重程度，并帮助确定所需反应的紧急度和重要度。
- [网络](./network/network.md)

## 其他
- [WSL](./windows/wsl.md) WSL, Windows Subsystem Linux

