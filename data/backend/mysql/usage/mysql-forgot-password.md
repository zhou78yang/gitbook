# MySQL服务密码找回

## 忘记密码处理
```bash
# 1. 修改mysqld配置
$ vim mysqld.cnf
...
[mysqld]
...
skip-grant-tables
...

# 2. 重启mysql服务
$ service mysql restart

# 3. 免密码登录mysql之后，更新用户密码
mysql> update mysql.user set authentication_string=password('NEW_PASSWORD') where user='USERNAME';
mysql> flush privileges;

# 4. 将mysqld配置恢复即密码修改完成
```

## 修改密码后ERROR 1698 (28000) 登录错误

该问题系user表的plugin字段被修改为auth_socket导致的，将对应user的plugin修改为mysql_native_password改为密码验证

```sql
mysql> select user, host, plugin from mysql.user;
+------------------+-----------+-----------------------+
| user             | host      | plugin                |
+------------------+-----------+-----------------------+
| root             | localhost | auth_socket           |
| mysql.session    | localhost | mysql_native_password |
| mysql.sys        | localhost | mysql_native_password |
| debian-sys-maint | localhost | mysql_native_password |
+------------------+-----------+-----------------------+
4 rows in set (0.02 sec)
```
