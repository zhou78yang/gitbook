# MySQL 用户添加及授权操作

> [!Note]
> MySQL 5.7 中User表取消了password字段

## 操作用户
```sql
# 创建用户
create user 'username'@'host' identified by 'password';
# 更改用户密码
set password for 'username'@'host' = password('new_password');
# 删除用户
drop user 'username'@'localhost'
```

### MySQL 8.0 中User修改密码操作
```sql
# 更改用户密码
ALTER USER 'username'@'host'
  IDENTIFIED WITH mysql_native_password
  BY 'password';
```

## 用户权限设置
```sql
# 查看用户权限
show grants for 'username'@'host';
# 授权
grant privileges on DATABASE_NAME.TABLE_NAME to 'username'@'host';
flush privileges;
```

eg.
```sql
# 授权用户对某个数据库的所有表拥有所有操作权限
grant all privileges on 'db_name'.* to 'username'@'host';
# 对某个数据库某个表进行某些操作的授权
grant select, insert, update on 'db_name'.'table_name' to 'username'@'host';

# 撤销授权
revoke privilege on DATABASE_NAME.TABLE_NAME from 'username'@'host';
```

通配符授权(用反引号)
```sql
mysql> grant all privileges on `test%`.* to adminer@'%';
mysql> show grants for adminer@'%';
+----------------------------------------------------+
| Grants for adminer@%                               |
+----------------------------------------------------+
| GRANT USAGE ON *.* TO `adminer`@`%`                |
| GRANT ALL PRIVILEGES ON `test%`.* TO `adminer`@`%` |
+----------------------------------------------------+
2 rows in set (0.01 sec)

```
