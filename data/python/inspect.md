# inspect

文档地址: https://docs.python.org/zh-cn/3/library/inspect.html

`inspect`模块提供了一些有用的函数帮助获取对象的信息，例如模块、类、方法、函数、回溯、帧对象以及代码对象。
例如它可以帮助你检查类的内容，获取某个方法的源代码，取得并格式化某个函数的参数列表，或者获取你需要显示的回溯的详细信息。

inspect主要有四个功能：
* 类型检查: 提供了大量类型校验的方法，例如`ismodule`, `isclass`, `ismethod`, `isfunction`
* 获取源代码: 提供了获取对象源码的方法，例如`getdoc`, `getfile`, `getsourcefile`, `getsourcelines`
* 检查类与函数
* 检查解释器的调用堆栈

## 使用案例
`client`是一个后端接口的客户端对接，每个api对应一个分类(url前缀)的接口API对接，使用到`inspect.getmembers`来增强`dir`中的内容

文件结构
```
client
├── api						# 对接的API
│   ├── __init__.py
│   ├── base.py
│   ├── service1.py         # 业务模块1接口
│   └── service2.py         # 业务模块2接口
├── __init__.py				# Client位置
└── base.py
```

BaseClient类访问方法
```python
# client/base.py
import inspect
from .api.base import BaseAPI

def _is_api(obj):
    return isinstance(obj, BaseAPI)


class BaseClient:
    def __new__(cls, *args, **kwargs):
        self = super().__new__(cls)
        apis = inspect.getmembers(self, _is_api)
        for name, api in apis:
            setattr(self, name, api.__class__(self))
        return self


# client/__init__.py
class Client(BaseClient):
    # 服务端api
    service1 = api.Service1()
    service2 = api.Service2()

```
以上代码使用上和直接在`Client.__init__()`中进行属性初始化的效果是一样的
```python
class Client(BaseClient):)
    def __init__(self):
        self.service1 = api.Service1(self)
        self.service2 = api.Service2(self)
```
区别主要在于dir时，如果通过`Client.__init__()`添加属性，那么`dir(Client)`是看不到service1和service2的，而用用类属性的方式可以看到
