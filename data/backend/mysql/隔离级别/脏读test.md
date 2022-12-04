### 读未提交/脏读

准备
```sql
mysql> set session transaction isolation level read uncommitted;
Query OK, 0 rows affected (0.01 sec)

mysql> show variables like '%isolation';
+-----------------------+------------------+
| Variable_name         | Value            |
+-----------------------+------------------+
| transaction_isolation | READ-UNCOMMITTED |
+-----------------------+------------------+
1 row in set (0.01 sec)
```

C1: 开始事务，事务中查询
```sql
mysql> start transaction;
Query OK, 0 rows affected (0.02 sec)

mysql> select * from test;
+----+----------+-----+
| id | name     | age |
+----+----------+-----+
|  1 | zhangsan |  18 |
|  2 | lisi     |  20 |
|  3 | wangwu   |  22 |
+----+----------+-----+
3 rows in set (0.01 sec)
```

C2: 开始事务，更新数据
```sql
mysql> start transaction;
Query OK, 0 rows affected (0.01 sec)

mysql> update test set name='zhaoliu' where id=3;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

```

C1: 再次事务中查询（C1读取到C2未提交的更改，脏读）
```sql
mysql> select * from test;
+----+----------+-----+
| id | name     | age |
+----+----------+-----+
|  1 | zhangsan |  18 |
|  2 | lisi     |  20 |
|  3 | zhaoliu  |  22 |
+----+----------+-----+
3 rows in set (0.02 sec)

```

C2: 回滚事务
```sql
mysql> rollback;
Query OK, 0 rows affected (0.01 sec)

```

C1: 再次查询，数据变回初始状态
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

```
