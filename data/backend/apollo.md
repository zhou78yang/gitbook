# Apollo

## 简介
Apollo（阿波罗）是一款可靠的分布式配置管理中心，诞生于携程框架研发部，能够集中化管理应用不同环境、不同集群的配置，配置修改后能够实时推送到应用端，并且具备规范的权限、流程治理等特性，适用于微服务配置管理场景。

Apollo支持4个维度管理Key-Value格式的配置：
* application (应用)
* environment (环境)
* cluster (集群)
* namespace (命名空间)

4个核心概念 https://www.apolloconfig.com/#/zh/design/apollo-introduction?id=_41-core-concepts


## python客户端对接
目前Apollo团队由于人力所限，只提供了Java和.Net的客户端。官方推荐了一些python的开源客户端 [推荐列表](https://www.apolloconfig.com/#/zh/usage/third-party-sdks-user-guide?id=_2-python)

对比下较合适的可能是 [xhrg-product/apollo-client-python](https://github.com/xhrg-product/apollo-client-python)
* 官方提供的三个项目开发人员都有交集，xhrg三个项目都接触过
* 支持较高的python3版本
* feature最多，且支持回调函数和<del>心跳请求</del>

同时，apollo-client-python 有些地方需要注意的
* 三个项目的star，维护人都较少，代码质量保证和可维护性上需要提个问号，暂时应该将其视同直接对接apollo OpenAPI的代码
* apollo-client-python没有提供pypi安装，目前需要在项目中引入代码
* apollo-client-python 最新release版本的心跳请求逻辑有bug，需要自行修正。可以参考这个[issue](https://github.com/xhrg-product/apollo-client-python/pull/5)



## 切换apollo配置遇到的问题
对接配置中心的目的是配置修改能够实时推送到应用端，而应用端需要能够及时更新配置，包括热更新配置和重启重新加载配置。
在Django项目对接过程中遇到了一些配置更新运行时无法生效的问题，以下列举出来

### django settings的更新
首先，django官方是不推荐更新settings对象；非要更新的话可以参考下面的方案，参考 https://docs.djangoproject.com/zh-hans/2.2/topics/settings/#altering-settings-at-runtime

```python
import logging
from apollo.apollo_client import ApolloClient
from django.conf import settings

logger = logging.getLogger('apollo')


def listener(*args):
    logger.warning(' '.join(args))
    action, namespace, key, new_value, *_ = args
    if action == 'update' and namespace == 'application':
        # 更新settings
        if hasattr(settings, key):
            setattr(settings, key, new_value)


apollo_client = ApolloClient('APOLLO_META_SERVER_URL', 'APOLLO_APP_ID', change_listener=listener)
```


### 已有的python对象缓存无法被更新
python在首次import一个module后，导入的对象会被缓存到sys.modules中，之后再次导入该module会首先检查缓存中是否存在对象，不会重新执行module。

形如下面的类属性定义，类属性`_HOST_URL`已经在定义时被缓存，apollo更新settings后也无法生效
```python
from django.conf import settings

class Base(object):
    _HOST_URL = settings.XX_HOST_URL

```
需要将类属性更改为对象属性


### DB_URI, CACHE_URI等数据库/缓存/队列的配置
DB_URI, CACHE_URI这列配置的更新概率极低，更新大概率伴随着升级。最好的建议就是这类连接配置不通过配置中心，通过环境变量配置。

如果使用配置中心配置这类连接信息，建议listener逻辑是直接杀死进程，通过系统的容错机制（supervisor/docker）重启服务。
