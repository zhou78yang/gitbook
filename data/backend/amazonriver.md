## amazonriver产生的背景:
- amazonriver 是一个将postgresql的实时数据同步到es或kafka的服务

## 版本支持
- Postgresql 9.4 or later
- Kafka 0.8 or later
- ElasticSearch 5.x

## 原理
amazonriver 利用pg内部的逻辑复制功能,通过在pg创建逻辑复制槽,接收数据库的逻辑变更,通过解析test_decoding特定格式的消息,得到逻辑数据

## 架构图
![avatar](https://raw.githubusercontent.com/hellobike/amazonriver/master/doc/arch.png)

## 安装步骤
- 先安装golang环境, golang版本需要>=1.13版本,go环境搭建步骤

``` shell

wget https://studygolang.com/dl/golang/go1.13.5.linux-amd64.tar.gz

vim /etc/profile
#set go env
export GOROOT=/home/yfbastion/mingliang/go #这要改
export PATH=$PATH:$GOROOT/bin:$HOME/go/repo/bin:$HOME/go/ws/bin
export GOPATH=$HOME/go/repo:$HOME/go/ws
# 保存后

source /etc/profile
```
- 安装 amazonriver 的步骤

``` shell
git clone https://github.com/hellobike/amazonriver
cd amazonriver
go install (这个可能需要尝试多次,依赖网络情况)
```
- 创建配置文件 config.json

``` json
{
    # pg_dump 可执行文件path，如pg_dump在 $PATH 路径下面，则不需配置
    "pg_dump_path": "",
    "subscribes": [{
        # 是否dump 历史数据，如只需要实时数据，可以不配或配置为false，默认false
        "dump": false,
        # 逻辑复制槽名称，确保唯一
        "slotName": "slot_for_kafka",
        # pg 连接配置
        "pgConnConf": {
            "host": "127.0.0.1",
            "port": 5432,
            "database": "test",
            "user": "postgres",
            "password": "admin"
        },
        # 同步规则配置
        "rules": [
            {
                # 表名匹配，支持通配符
                "table": "res_users",
                # 表的主键配置
                "pks": ["id"],
                # kafka topic
                "topic": "ming-users"
            }
        ],
        # kafka 连接配置
        "kafkaConf": {
            "addrs": ["127.0.0.1:9092"]
        },
        # 错误重试配置,0为不重试,-1会一直重试直到成功
        "retry": 0
    }],
    # 监控抓取地址配置
    "prometheus_address": ":8080"
}
```
- 启动 amazonriver 命令

``` shell
amazonriver -config config.json
```

- 当监控的表有数据发生变动时,打入到消息队列的样式为如下

```json
[
  {
    "topic": "ming-users",
    "key": 1636,
    "value": {
      "schema": "public",
      "table": "res_users",
      "operation": "UPDATE",
      "data": {
        "password": "peng665",
        "write_date": "2019-10-04 06:08:32.496399",
        "id": 1636,
        "write_uid": 1637,
        "login_date": "2019-10-22",
        "create_uid": 1606,
        "partner_id": 64010,
        "login": "pengxianfu1",
        "signature": null,
        "action_id": null,
        "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InBlbmd4aWFuZnUiLCJleHAiOjE1NzM1Mjg0MjgsInVzZXJfaWQiOjE2MzZ9.1052bfYBblBj5avWabRJa5Trk_X18FY2_4zfDG6fX50",
        "company_id": 1,
        "menu_id": 1,
        "share": "false",
        "default_section_id": null,
        "active": "true",
        "create_date": "2018-12-14 01:20:26.172478",
        "alias_id": 1647
      },
      "operateTime": 1576894633816
    },
    "partition": 0,
    "offset": 0
  }
]
```