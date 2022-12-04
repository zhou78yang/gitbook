# InnoDB分页优化

## 情况
在数据量不大的情况下/一般组件的默认情况，列表接口的分页形式一般是这样的：

![分页情况1](../img/分页方式1.png)

实现上大概是这样：
```sql
select count(1) from table_name;
select * from table_name limit 30 offset 0;
```
随着表中数据量日益增大，这个接口会越来越慢，主要原因有两个：
* 额外的一条count语句导致需要查询两次，其实很多时候业务并不关心这个总数;
* InnoDB的分页方式会导致offset越大，执行耗时越久;


## 处理方案

### 增对count的优化
由于很多时候，业务其实并不关心列表的总数，所以我们可以从用户习惯上进行优化，不去查询这条count语句，分页形式改成：

![分页情况2](../img/分页方式2.png)

这样我们只需要查询分页数据即可

### 对offset的优化
普通的`limit N offset M`的写法越往后查询越慢，因为InnoDB总是会去扫描M+N条数据来得到你想要的数据。


```bash
mysql> select count(1) from shipment;
+----------+
| count(1) |
+----------+
| 12492684 |
+----------+
1 row in set (1.68 sec)


mysql> select * from shipment limit 50;
50 rows in set (0.00 sec)

mysql> select * from shipment limit 50 offset 5000000;
50 rows in set (10.67 sec)

mysql> explain select * from shipment limit 50 offset 5000000;
+------+-------------+----------+------+---------------+------+---------+------+----------+-------+
| id   | select_type | table    | type | possible_keys | key  | key_len | ref  | rows     | Extra |
+------+-------------+----------+------+---------------+------+---------+------+----------+-------+
|    1 | SIMPLE      | shipment | ALL  | NULL          | NULL | NULL    | NULL | 13634485 |       |
+------+-------------+----------+------+---------------+------+---------+------+----------+-------+

```

id不间断时处理方案
```bash
mysql> select * from shipment where id between 5000000 and 5000050;

mysql> explain select * from shipment where id between 20000000 and 20000050;
+------+-------------+----------+-------+---------------+---------+---------+------+------+-------------+
| id   | select_type | table    | type  | possible_keys | key     | key_len | ref  | rows | Extra       |
+------+-------------+----------+-------+---------------+---------+---------+------+------+-------------+
|    1 | SIMPLE      | shipment | range | PRIMARY       | PRIMARY | 4       | NULL |   32 | Using where |
+------+-------------+----------+-------+---------------+---------+---------+------+------+-------------+

```

id有间断的处理方案
```bash
mysql> select u1.* from shipment u1 inner join (select id from shipment limit 50 offset 5000000) u2 on u1.id=u2.id;
50 rows in set (0.52 sec)

mysql> explain select u1.* from shipment u1 inner join (select id from shipment limit 50 offset 5000000) u2 on u1.id=u2.id;
+------+-------------+------------+--------+---------------+-------------------+---------+---------------+----------+-------------+
| id   | select_type | table      | type   | possible_keys | key               | key_len | ref           | rows     | Extra       |
+------+-------------+------------+--------+---------------+-------------------+---------+---------------+----------+-------------+
|    1 | PRIMARY     | <derived2> | ALL    | NULL          | NULL              | NULL    | NULL          |  5000050 |             |
|    1 | PRIMARY     | u1         | eq_ref | PRIMARY       | PRIMARY           | 4       | u2.idshipment |        1 |             |
|    2 | DERIVED     | shipment   | index  | NULL          | shipment_f841077f | 1       | NULL          | 11711999 | Using index |
+------+-------------+------------+--------+---------------+-------------------+---------+---------------+----------+-------------+

```
* offset M条的操作是在索引中完成的
* 再通过派生表获取到的主键去查询分页数据
