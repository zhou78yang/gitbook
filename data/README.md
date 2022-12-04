# 开始

## Go
- Go语言基础
  - [Go快速入门](./go/go快速入门.md)
  - [空结构体](./go/lang/empty_struct.md)
  - [json](./go/std/json.md)

## Python

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