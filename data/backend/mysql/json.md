# MySQL json数据类型

> 从MySQL 5.7.8开始，MySQL支持原生的json数据类型

和传统用字符格式存储json数据的方式相比，原生的json数据类型具有以下优势：
* 自动校验存在JSON列中的json字符串
* 更优的存储结构，读取效率更高

## 简单示例
```sql
mysql> CREATE TABLE t1 (jdoc JSON);
Query OK, 0 rows affected (0.18 sec)

mysql> INSERT INTO t1 VALUES('{"key1": "value1", "key2": "value2"}');
Query OK, 1 row affected (0.07 sec)

mysql> select * from t1 \G
*************************** 1. row ***************************
jdoc: {"key1": "value1", "key2": "value2"}

mysql> INSERT INTO t1 VALUES('[1, 2,');
ERROR 3140 (22032): Invalid JSON text: "Invalid value." at position 6 in value for column 't1.jdoc'.

```


## json相关函数一览

| 分类         | 函数               | 描述                                                         |
| ------------ | ------------------ | ------------------------------------------------------------ |
| 创建json     | json_array         | 创建json数组                                                 |
|              | json_object        | 创建json对象                                                 |
|              | json_quote         | 将json转成json字符串类型                                     |
| 查询json     | json_contains      | 判断是否包含某个json值                                       |
|              | json_contains_path | 判断某个路径下是否包json值                                   |
|              | json_extract       | 提取json值                                                   |
|              | column->path       | json_extract的简洁写法，MySQL 5.7.9开始支持                  |
|              | column->>path      | json_unquote(column -> path)的简洁写法                       |
|              | json_keys          | 提取json中的键值为json数组                                   |
|              | json_search        | 按给定字符串关键字搜索json，返回匹配的路径                   |
| 修改json     | json_append        | 废弃，MySQL 5.7.9开始改名为json_array_append                 |
|              | json_array_append  | 末尾添加数组元素，如果原有值是数值或json对象，则转成数组后，再添加元素 |
|              | json_array_insert  | 插入数组元素                                                 |
|              | json_insert        | 插入值（插入新值，但不替换已经存在的旧值）                   |
|              | json_merge         | 合并json数组或对象                                           |
|              | json_remove        | 删除json数据                                                 |
|              | json_replace       | 替换值（只替换已经存在的旧值）                               |
|              | json_set           | 设置值（替换旧值，并插入不存在的新值）                       |
|              | json_unquote       | 去除json字符串的引号，将值转成string类型                     |
| 返回json属性 | json_depth         | 返回json文档的最大深度                                       |
|              | json_length        | 返回json文档的长度                                           |
|              | json_type          | 返回json值得类型                                             |
|              | json_valid         | 判断是否为合法json文档                                       |




## 生成JSON值的函数

### JSON_ARRAY（数组）
```sql
mysql> SELECT JSON_ARRAY(1, "abc", NULL, TRUE, CURTIME());
+---------------------------------------------+
| JSON_ARRAY(1, "abc", NULL, TRUE, CURTIME()) |
+---------------------------------------------+
| [1, "abc", null, true, "19:42:08.000000"]   |
+---------------------------------------------+
```

### JSON_OBJECT（对象）
```sql
mysql> SELECT JSON_OBJECT('id', 87, 'name', 'carrot');
+-----------------------------------------+
| JSON_OBJECT('id', 87, 'name', 'carrot') |
+-----------------------------------------+
| {"id": 87, "name": "carrot"}            |
+-----------------------------------------+
```

### JSON_QUOTE（字符串）
```sql
mysql> SELECT JSON_QUOTE('null'), JSON_QUOTE('"null"');
+--------------------+----------------------+
| JSON_QUOTE('null') | JSON_QUOTE('"null"') |
+--------------------+----------------------+
| "null"             | "\"null\""           |
+--------------------+----------------------+

mysql> SELECT JSON_QUOTE('[1, 2, 3]');
+-------------------------+
| JSON_QUOTE('[1, 2, 3]') |
+-------------------------+
| "[1, 2, 3]"             |
+-------------------------+

```


## 查询json

### JSON_CONTAINS（是否包含）
```sql
mysql> SET @j = '{"a": 1, "b": 2, "c": {"d": 4}}';
Query OK, 0 rows affected (0.03 sec)

mysql> SELECT JSON_CONTAINS(@j, '{"a": 1}');
+-------------------------------+
| JSON_CONTAINS(@j, '{"a": 1}') |
+-------------------------------+
|                             1 |
+-------------------------------+

mysql> SELECT JSON_CONTAINS(@j, '1');
+------------------------+
| JSON_CONTAINS(@j, '1') |
+------------------------+
|                      0 |
+------------------------+

mysql> SELECT JSON_CONTAINS(@j, '1', '$.a');
+-------------------------------+
| JSON_CONTAINS(@j, '1', '$.a') |
+-------------------------------+
|                             1 |
+-------------------------------+

```

### JSON_EXTRACT（返回json中的数据）

获取对象/值
```sql
mysql> SET @j = '{"a": 1, "b": 2, "c": {"d": 4}}';
Query OK, 0 rows affected (0.03 sec)

mysql> SELECT JSON_EXTRACT(@j, '$.c');
+-------------------------+
| JSON_EXTRACT(@j, '$.c') |
+-------------------------+
| {"d": 4}                |
+-------------------------+

mysql> SELECT JSON_EXTRACT(@j, '$.c.d');
+---------------------------+
| JSON_EXTRACT(@j, '$.c.d') |
+---------------------------+
| 4                         |
+---------------------------+

```

获取列表
```sql
mysql> SELECT JSON_EXTRACT('[10, 20, [30, 40]]', '$[1]', '$[0]');
+----------------------------------------------------+
| JSON_EXTRACT('[10, 20, [30, 40]]', '$[1]', '$[0]') |
+----------------------------------------------------+
| [20, 10]                                           |
+----------------------------------------------------+

mysql> SELECT JSON_EXTRACT('[10, 20, [30, 40]]', '$[1]', '$[2][*]');
+-------------------------------------------------------+
| JSON_EXTRACT('[10, 20, [30, 40]]', '$[1]', '$[2][*]') |
+-------------------------------------------------------+
| [20, 30, 40]                                          |
+-------------------------------------------------------+

mysql> SELECT JSON_EXTRACT('[10, 20, [30, 40]]', '$', '$[2][*]');
+----------------------------------------------------+
| JSON_EXTRACT('[10, 20, [30, 40]]', '$', '$[2][*]') |
+----------------------------------------------------+
| [[10, 20, [30, 40]], 30, 40]                       |
+----------------------------------------------------+

```

### `->`运算符替代JSON_EXTRACT
从MySQL 5.7.9开始，支持使用`->`来替代JSON_EXTRACT
```sql
mysql> select jdoc, jdoc->'$.key1' from t1;
+--------------------------------------+----------------+
| jdoc                                 | jdoc->'$.key1' |
+--------------------------------------+----------------+
| {"key1": "value1", "key2": "value2"} | "value1"       |
+--------------------------------------+----------------+

```
也可以用在where子句中
```sql
mysql> ALTER TABLE jemp ADD COLUMN n INT;
Query OK, 0 rows affected (0.68 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> UPDATE jemp SET n=1 WHERE c->"$.id" = "4";
Query OK, 1 row affected (0.04 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT c, c->"$.id", g, n
     > FROM jemp
     > WHERE JSON_EXTRACT(c, "$.id") > 1
     > ORDER BY c->"$.name";
+-------------------------------+-----------+------+------+
| c                             | c->"$.id" | g    | n    |
+-------------------------------+-----------+------+------+
| {"id": "3", "name": "Barney"} | "3"       |    3 | NULL |
| {"id": "4", "name": "Betty"}  | "4"       |    4 |    1 |
| {"id": "2", "name": "Wilma"}  | "2"       |    2 | NULL |
+-------------------------------+-----------+------+------+
3 rows in set (0.00 sec)

mysql> DELETE FROM jemp WHERE c->"$.id" = "4";
Query OK, 1 row affected (0.04 sec)

mysql> SELECT c, c->"$.id", g, n
     > FROM jemp
     > WHERE JSON_EXTRACT(c, "$.id") > 1
     > ORDER BY c->"$.name";
+-------------------------------+-----------+------+------+
| c                             | c->"$.id" | g    | n    |
+-------------------------------+-----------+------+------+
| {"id": "3", "name": "Barney"} | "3"       |    3 | NULL |
| {"id": "2", "name": "Wilma"}  | "2"       |    2 | NULL |
+-------------------------------+-----------+------+------+
2 rows in set (0.00 sec)
```


## 参考
* MySQL json https://dev.mysql.com/doc/refman/5.7/en/json.html
* 生成json值的函数 https://dev.mysql.com/doc/refman/5.7/en/json-creation-functions.html
* 查询json的函数 https://dev.mysql.com/doc/refman/5.7/en/json-search-functions.html
* 修改json的函数 https://dev.mysql.com/doc/refman/5.7/en/json-modification-functions.html
* 返回json属性的函数 https://dev.mysql.com/doc/refman/5.7/en/json-attribute-functions.html
* 在JSON和non-JSON值之间转换 https://dev.mysql.com/doc/refman/5.7/en/json.html#json-converting-between-types 
