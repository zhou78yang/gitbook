# Kibana

Kibana是Elastic Stack中的可视化工具，能够对`Elasticsearch`数据进行可视化,并且在`Elastic Stack`中进行导航

## KQL
官方文档: https://www.elastic.co/guide/en/kibana/current/kuery-query.html

KQL(Kibana Query Language)是Kibana的一种查询语言，以下是一些简单的使用。

### Term query
```
message: 401 403
```
以上表示筛选message中equels `401`或`403`的

```
message: "401 50"
```
表示筛选message中equels `401 50`的
> [!Warning]
> 引号只能单独使用，不能和不包含引号的字段使用



### Boolean query
KQL支持`and`，`or`，`not`做布尔查询

如果想要筛选message包含`401 50`和`403`的，可以
```
message: ("401 50" or 403)
```

### 条件运算符
KQL支持`>`, `>=`, `<`, `<=`这几种运算符

数值比较
```
account_number >= 100 and items_sold <= 200
```
日期比较
```
@timestamp < "2021-01-02T21:55:59"
```
```
@timestamp < "2021-01"
```

### Exists
判断一个字段是否存在用`:*`
```
message:*
```
