# Django-Redis

## 为什么要用Django-Redis
* 持续更新
* 可扩展客户端，解析器，序列化器
* 默认客户端主/从支持
* 完善的测试
* 已在一些项目的生产环境中作为 cache 和 session 使用
* 支持永不超时设置
* 原生接入redis客户端/连接池支持
* 高可配置

## 配置

### 作为缓存后端

```python
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://127.0.0.1:6379/1",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        }
    }
}
```

支持的url类型
```
redis://[:password]@localhost:6379/0
rediss://[:password]@localhost:6379/0
unix://[:password]@/path/to/socket.sock?db=0
```
* redis://: 普通的TCP套接字连接
* rediss://: SSL包裹的TCP套接字连接
* unix://: Unix域套接字连接

> [!Note]
> redis的db只能支持以下写法，不以斜杠结尾
> ```
db 查询参数, 例如: redis://localhost?db=0
如果使用 redis:// scheme, 可以直接将数字写在路径中, 例如: redis://localhost/0
```
> 


### 作为session后端
```python
SESSION_ENGINE = "django.contrib.sessions.backends.cache"
SESSION_CACHE_ALIAS = "default"
```


## 使用

### 失效时间
和django设定保持一致
* timeout=0 立即过期
* timeout=None 永不超时

### 锁
django-redis支持redis分布式锁，锁的线程接口是相同的。

使用上下文管理器分配锁的例子:
```python
with cache.lock("somekey"):
    do_some_thing()
```

### 使用原生客户端
在某些情况下你的应用需要进入原生Redis客户端使用一些django cache接口没有暴露出来的进阶特性. 为了避免储存新的原生连接所产生的另一份设置, django-redis提供了方法`get_redis_connection(alias)`使你获得可重用的连接字符串.
```python
>>> from django_redis import get_redis_connection
>>> con = get_redis_connection("default")
>>> con
<redis.client.StrictRedis object at 0x2dc4510>
```

### 连接池

django-redis使用redis-py的连接池接口, 并提供了简单的配置方式. 除此之外, 你可以为backend定制化连接池的产生.

> redis-py默认不会关闭连接, 尽可能重用连接

连接池默认配置，通过`max_connections`设置最大连接数

```python
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        ...
        "OPTIONS": {
            "CONNECTION_POOL_KWARGS": {"max_connections": 100}
        }
    }
}
```

## 更多
* django-redis中文文档: https://django-redis-chs.readthedocs.io/zh_CN/latest/#
* 项目地址: https://github.com/jazzband/django-redis