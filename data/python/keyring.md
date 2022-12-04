# keyring

keyring库提供了一种用Python访问系统keyring(钥匙串)服务的简单方法。它可以用于任何需要安全密码存储的应用程序。

## 使用
```python
>>> import keyring
>>> keyring.set_password("system", "username", "password")
>>> keyring.get_password("system", "username")
'password'
```

保存的文件位置:
```python
>>> import keyring
>>> keyring.util.platform_.config_root()    # 配置文件
'/home/$USER/.config/python_keyring'
>>> keyring.util.platform_.data_root()      # 数据文件
'/home/$USER/.local/share/python_keyring'

```

## 拓展
keyring通过调用不同的`backend`来实现钥匙串存储，keyring还提供了一些api方法允许我们更换backend:
* get_keyring: 获取服务后端
* set_keyring: 设置服务后端


## 参考
* 文档: https://pypi.org/project/keyring/
