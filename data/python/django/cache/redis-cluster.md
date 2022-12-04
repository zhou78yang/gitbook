# Django使用RedisCluster做缓存

依赖包：
* django-redis 
* redis-py-cluster >= 2.1.0

## 配置

示例settings中基于django-environ中的env进行配置
```python
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": [
            env('REDIS_CLUSTER_1'),
            env('REDIS_CLUSTER_2'),
            env('REDIS_CLUSTER_3'),
        ],
        'OPTIONS': {
            'REDIS_CLIENT_CLASS': 'rediscluster.RedisCluster',      # 连接类
            'CONNECTION_POOL_CLASS': 'rediscluster.connection.ClusterConnectionPool',   # 连接池类
            'CONNECTION_POOL_KWARGS': {     # 连接池参数
                'skip_full_coverage_check': True  # 连接报错时加参数：config get cluster-require-full-coverage
            },
        },
        # "KEY_PREFIX": "myapp",  # key前缀，默认为''
        # "VERSION": 1,  # 版本号
        # "KEY_FUNCTION": "cache_ext.key_function.make_key",  # 自定义前缀规则，默认 KEY_PREFIX:VERSION:key
    },
}
```

说明：
* skip_full_coverage_check参数一般可以不指定，集群连接时报相关异常才加

### KEY_FUNCTION实现参考(多个系统共用集群时可能需要实现)
```python
def make_key(key, key_prefix, version):
    """覆盖原始的把版本号删除"""
    return f'{key_prefix}:{key}'
```


## 使用

### 通过Django缓存框架使用
```python
In [1]: from django.core.cache import cache
 
In [2]: cache.get('aaa')
 
In [3]: cache.set('aaa', 123)
Out[3]: True
 
In [4]: type(cache.client.get_client())         # 缓存Backend获取RedisCluster的方式
Out[4]: rediscluster.client.RedisCluster

```

### 通过get_redis_connection获取RedisCluster对象
```python
In [1]: from django_redis import get_redis_connection
 
In [2]: conn = get_redis_connection()
 
In [3]: type(conn)
Out[3]: rediscluster.client.RedisCluster

```

说明：
* django_redis内部实现了连接池，通过django_redis连接集群可以减少新建连接次数和集群的连接数
* RedisCluster的连接新建一般需要150ms左右，而连接池耗时通常在5ms以下（视服务器环境）

