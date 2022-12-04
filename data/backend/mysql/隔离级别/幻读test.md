
### 可重复读/幻读

准备
```sql
mysql> set session transaction isolation level repeatable read;
Query OK, 0 rows affected (0.01 sec)

mysql> show variables like '%isolation';
+-----------------------+-----------------+
| Variable_name         | Value           |
+-----------------------+-----------------+
| transaction_isolation | REPEATABLE-READ |
+-----------------------+-----------------+
1 row in set (0.01 sec)

```

C1: 开始事务
```sql
mysql> select * from test;
+----+----------+-----+
| id | name     | age |
+----+----------+-----+
|  1 | zhangsan |  18 |
|  2 | lisi     |  20 |
|  3 | wangwu   |  22 |
+----+----------+-----+
3 rows in set (0.01 sec)

mysql> start transaction;
Query OK, 0 rows affected (0.04 sec)

```

C2: 插入数据并提交
```sql
mysql> insert into test (`name`, `age`) values ('zhaoliu', 19);
Query OK, 1 row affected (0.01 sec)

```

C1: 查询区间数据(select之前的提交都可以读到，然后作为快照snapshot，在之后的select使用)
```sql
mysql> select * from test where age < 20;
+----+----------+-----+
| id | name     | age |
+----+----------+-----+
|  1 | zhangsan |  18 |
|  4 | zhaoliu  |  19 |
+----+----------+-----+
2 rows in set (0.02 sec)

```

C2: 另一个事务，插入第二条数据
```sql
mysql> insert into test (`name`, `age`) values ('haha', 15);
Query OK, 1 row affected (0.01 sec)

```

C1: 更新数据，查询数据集（不会出现不可重复度，但是update之后会出现幻行）
```sql
mysql> select * from test where age < 20;
+----+----------+-----+
| id | name     | age |
+----+----------+-----+
|  1 | zhangsan |  18 |
|  4 | zhaoliu  |  19 |
+----+----------+-----+
2 rows in set (0.02 sec)

mysql> update test set name='???' where age < 20;
Query OK, 3 rows affected (0.02 sec)
Rows matched: 3  Changed: 3  Warnings: 0

mysql> select * from test where age < 20;
+----+------+-----+
| id | name | age |
+----+------+-----+
|  1 | ???  |  18 |
|  4 | ???  |  19 |
|  5 | ???  |  15 |
+----+------+-----+
3 rows in set (0.02 sec)

```
