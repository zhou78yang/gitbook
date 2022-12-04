# 缓存

## 设置缓存
缓存系统需要少量的设置。也就是说，你必须告诉它你的缓存数据应该放在哪里——是在数据库中，还是在文件系统上，或者直接放在内存中。
这是一个重要的决定，会影响你的缓存的性能；是的，有些缓存类型比其他类型快。

缓存设置项位于配置文件的CACHE配置中，Django自带的缓存后端：
* django.core.cache.backends.db.DatabaseCache
* django.core.cache.backends.dummy.DummyCache
* django.core.cache.backends.filebased.FileBasedCache
* django.core.cache.backends.locmem.LocMemCache
* django.core.cache.backends.memcached.PyMemcacheCache
* django.core.cache.backends.memcached.PyLibMCCache

### Memcached 
`Memcached`是一个完全基于内存的缓存服务器，是Django原生支持的最快、最高效的缓存类型。

参考文档: https://docs.djangoproject.com/zh-hans/3.2/topics/cache/#memcached


### 数据库缓存
Django 可以在数据库中存储缓存数据。如果你有一个快速、索引正常的数据库服务器，这种缓存效果最好。
用数据库表作为你的缓存后端：

* 将`BACKEND`设置为 django.core.cache.backends.db.DatabaseCache
* 将`LOCATION`设置为数据库表的 tablename。这个表名可以是没有使用过的任何符合要求的名称。

在这个例子中，缓存表的名称是`my_cache_table`：

```python
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
        'LOCATION': 'my_cache_table',
    }
}
```

参考文档: https://docs.djangoproject.com/zh-hans/3.2/topics/cache/#database-caching


### 文件系统缓存
基于文件的后端序列化并保存每个缓存值作为单独的文件。要使用此后端，可将BACKEND设置为"django.core.cache.backends.filebased.FileBasedCache"并将LOCATION设置为一个合适的路径。
比如，在`/var/tmp/django_cache`存储缓存数据，使用以下配置：
```python
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/var/tmp/django_cache',
    }
}
```

参考文档: https://docs.djangoproject.com/zh-hans/3.2/topics/cache/#filesystem-caching


### 本地内存缓存
如果你的配置文件中没有指定其他缓存，那么这是默认的缓存。如果你想获得内存缓存的速度优势，但又不具备运行Memcached的能力，可以考虑使用本地内存缓存后端。
这个缓存是每进程所有（见下文）和线程安全的。要使用它，可以将BACKEND设置为"django.core.cache.backends.locmem.LocMemCache"。例如:

```python
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
    }
}
```

> [!Warning]
> 请注意，每个进程都会有自己的私有缓存实例，这意味着不可能进行跨进程缓存。这也意味着本地内存缓存的内存效率不是特别高，所以对于生产环境来说，
> 它可能不是一个好的选择。对于开发来说是不错的选择。

参考文档: https://docs.djangoproject.com/zh-hans/3.2/topics/cache/#local-memory-caching


### 自定义缓存Backend
Django支持自定义缓存Backend，可以用于实现一些特殊的缓存需求

```python
CACHES = {
    'default': {
        'BACKEND': 'path.to.backend',
    }
}
```

自定义缓存后端可以使用标准缓存作为参考实现，可以在Django源代码的`django/core/cache/backends/`目录找到代码。

> [!Danger|label:注意]
> 通常是当前Django或者较成熟的第三方包和可配置参数都无法满足需求的时候，才考虑自定义缓存后端


### 可选配置参数
每个缓存后端可以通过额外的参数来控制缓存行为。这些参数在 CACHES 配置中作为附加键提供。有效参数如下：

* TIMEOUT: 缓存的默认超时时间，以秒为单位。这个参数默认为300秒（5分钟）。可以将TIMEOUT设置为None，这样，默认情况下，缓存键永远不会过期。值为0 会导致键立即过期（实际上是 “不缓存”）。
* OPTIONS: 任何应该传递给缓存后端的选项。OPTIONS参数会随着每个后端而变化，由第三方库支持的缓存后端会直接将其选项传递给底层缓存库。
* KEY_PREFIX: 一个自动包含在`Django`服务器使用的所有缓存键中的字符串前缀，默认为`''`。
* VERSION: 缓存键的默认版本号，默认为`1`。
* KEY_FUNCTION: 函数路径，该函数定义了如何将前缀、版本和键组成一个最终的缓存键。

**KEY_FUNCTION示例**
```python
def make_key(key, key_prefix, version):
    return ':'.join([key_prefix, str(version), key])
```

## 使用
Django公开了一个底层的缓存API。可以使用这个API以任意级别粒度在缓存中存储对象，
可以缓存任何可以安全的pickle的Python对象：模型对象的字符串、字典、列表，或者其他的对象。

### 访问缓存
可以通过`django.core.cache.caches`获取Django缓存对象，重复请求同一个线程里的同一个别名将返回同一个对象。
```python
>>> from django.core.cache import caches
>>> cache1 = caches['myalias']
>>> cache2 = caches['myalias']
>>> cache1 is cache2
True
```
如果键名不存在，将会引发`InvalidCacheBackendError`错误。

为了支持线程安全，将为每个线程返回缓存后端的不同实例。

通过`django.core.cache.cache`可以访问default配置的缓存：
```python
>>> from django.core.cache import cache, caches
>>> cache is caches['default']
True
```

### 常用功能
* timeout: 默认为300，可通过`set()`方法的timeout参数指定
* 缓存前缀: 通过配置中的KEY_PREFIX, VERSION, KEY_FUNCTION等参数可配置缓存key前缀

更多内容参考[基本用法](https://docs.djangoproject.com/zh-hans/3.2/topics/cache/#basic-usage)


## 参考
* [Django缓存框架](https://docs.djangoproject.com/zh-hans/3.2/topics/cache/)
* [Django缓存框架设计理念](https://docs.djangoproject.com/zh-hans/3.2/misc/design-philosophies/#cache-design-philosophy)
