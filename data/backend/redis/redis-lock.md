# Redis分布式锁


## redis-py的lock
使用
```python
>>> with client.lock('test_lock', timeout=10, blocking_timeout=5) as lock: 
...     print(lock.name) 
...
test_lock

```

源码
```python
class Redis(object):
    ...

    def lock(self, name, timeout=None, sleep=0.1, blocking_timeout=None,
             lock_class=None, thread_local=True):
        if lock_class is None:
            lock_class = Lock
        return lock_class(self, name, timeout=timeout, sleep=sleep,
                          blocking_timeout=blocking_timeout,
                          thread_local=thread_local)

```
返回一个Lock实例，参数：
* timeout: 锁的失效时间
* sleep: 轮询取获取锁的时间间隔
* blocking_timeout: 获取锁的最长阻塞时间
* lock_class: 支持传入自定义锁，默认为`redis.lock.Lock`
* thread_local: 锁的token是否放在thread-local中，默认为True。

> [!Warning]
> thread_local=False的选项仅提供给需要一个线程获取锁，可能由另一个线程释放锁的情形


### redis.lock.Lock源码分析
实现功能
* 实现了上下文管理器，通常可直接with访问
* acquire: 获取锁，获取锁失败会抛出`redis.exceptions.LockError`
* release: 释放锁，释放失败抛出异常`redis.exceptions.LockNotOwnedError`
* extend: 延长锁的失效时间
* reacquire: 重置锁的失效时间
* 除了获取锁(只需要SET命令)，其他功能都是通过lua脚本实现原子性操作

##### acquire
```python
self.redis.set(self.name, token, nx=True, px=timeout)
```

##### release
1. 校验，锁存在且token和当前线程的token值相同
2. 删除锁

```lua
local token = redis.call('get', KEYS[1])
if not token or token ~= ARGV[1] then
    return 0
end
redis.call('del', KEYS[1])
return 1
```

* KEYS: lock-name
* ARGV: lock-token
* 如果返回0，则抛出异常`redis.exceptions.LockNotOwnedError`

##### extend
1. 校验，锁存在且token和当前线程的token值相同
2. 获取pttl，并校验锁是否已失效
3. 延长失效时间

```lua
local token = redis.call('get', KEYS[1])
if not token or token ~= ARGV[1] then
    return 0
end
local expiration = redis.call('pttl', KEYS[1])
if not expiration then
    expiration = 0
end
if expiration < 0 then
    return 0
end

local newttl = ARGV[2]
if ARGV[3] == "0" then
    newttl = ARGV[2] + expiration
end
redis.call('pexpire', KEYS[1], newttl)
return 1
```

* KEYS: lock-name
* ARGV: lock-token, additional_time(延长的时间), replace_ttl(是否重置，1则用add_time重置，0则累加)


##### reacquire
1. 校验，锁存在且token和当前线程的token值相同
2. 重置失效时间

```lua
local token = redis.call('get', KEYS[1])
if not token or token ~= ARGV[1] then
    return 0
end
redis.call('pexpire', KEYS[1], ARGV[2])
return 1
```

* KEYS: lock-name
* ARGV: lock-token, timeout


## 自定义锁的逻辑

基本的获取锁，释放锁逻辑。`conn`建议为`redis.Redis`对象
```python
def acquire_lock(conn, lock_name, acquire_time=10, expire=10, delta=0.005):
    """
    获取一个分布式锁
    :param conn: redis连接
    :param lock_name: 缓存key
    :param acquire_time: 获取时间(s)
    :param expire: 超时(s)
    :param delta: 轮询间隔
    :return:
    """
    identifier = str(uuid.uuid4())
    end = time.time() + acquire_time
    cache_key = 'sys:lock:{lock_name}'.format(lock_name=lock_name)
    while time.time() < end:
        if conn.set(cache_key, identifier, nx=True, ex=expire):
            return identifier
        time.sleep(delta)
    return False


def release_lock(conn, lock_name, identifier):
    """
    释放一个分布式锁
    :param conn: redis连接
    :param lock_name: 缓存key
    :param identifier: 缓存值
    :return:
    """
    cache_key = 'sys:lock:{lock_name}'.format(lock_name=lock_name)
    pip = conn.pipeline()
    while True:
        try:
            pip.watch(cache_key)
            lock_value = conn.get(cache_key)
            if not lock_value:
                return True

            if lock_value.decode() == identifier:
                pip.multi()
                pip.delete(cache_key)
                pip.execute()
                return True
            pip.unwatch()
            break
        except redis.exceptions.WatchError:
            pass
    return False
```


### 使用redis-cluster时
此时`conn`建议为`rediscluster.client.RedisCluster`对象

> [!Warning]
> redis-cluster的pipeline中没有multi, watch和unwatch等操作，需要调整适配


## 封装锁逻辑的装饰器
不同项目获取`redis.Redis`的方式不同，应当将获取redis连接的方式，封装成一个`get_redis_connection`

```python
class LockError(Exception):
    """ 分布式锁异常 """
    pass


def redis_lock(*dargs, **dkw):
    # support both @redis_lock and @redis_lock() as valid syntax
    if len(dargs) == 1 and callable(dargs[0]):
        def wrap_simple(f):
            @six.wraps(f)
            def wrapped_f(*args, **kw):
                return RedisLock().call(f, *args, **kw)
            return wrapped_f
        return wrap_simple(dargs[0])
    else:
        def wrap(f):
            @six.wraps(f)
            def wrapped_f(*args, **kw):
                return RedisLock(*dargs, **dkw).call(f, *args, **kw)
            return wrapped_f
        return wrap


class RedisLock(object):
    def __init__(self, lock_name=None, get_lock_name=None, acquire_time=10, expire=10):
        """
        :param lock_name: 锁名
        :param get_lock_name: 获取锁的方法，默认取第一个参数的字符串，类方法则是self的字符串
        :param acquire_time: 获取锁的时间
        :param expire: 锁失效的时间
        """
        self.get_lock_name = get_lock_name
        if self.get_lock_name is None:
            if lock_name is not None:
                self.get_lock_name = lambda *args, **kwargs: lock_name
            else:
                self.get_lock_name = lambda *args, **kwargs: str(args[0])

        self.acquire_time = acquire_time
        self.expire = expire
        self.client = get_redis_connection()

    def call(self, fn, *args, **kwargs):
        lock_name = self.get_lock_name(*args, **kwargs)
        identifier = acquire_lock(self.client, lock_name, self.acquire_time, self.expire)
        if not identifier:
            raise LockError('资源`{lock_name}`被锁定，请稍后重试'.format(lock_name=lock_name))
        try:
            result = fn(*args, **kwargs)
        except Exception as e:
            raise e
        finally:
            released = release_lock(self.client, lock_name, identifier)
            if not released:
                log.error('资源`{lock_name}`未成功释放'.format(lock_name=lock_name))
        return result
```


## 小结
`redis-py`的lock功能已经涵盖了很多常见的业务情况，日常使用应该直接使用lock方法或者基于此进行封装。