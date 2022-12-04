# 单例模式

## 概念

### 什么是单例模式
单例（Singleton）模式，属于创建类型的一种常用设计模式。
通过单例模式的方法创建的类在当前进程中只有一个实例。

### 为什么需要单例模式
有些时候，我们想要在程序中表示某种东西只有一个的时候，就会有“只有一个实例”的需求。
比较典型的就是某些操作系统类，配置类。
虽然我们可以用一个全局变量实现，但如果我们想“不需要多加注意才能生成一个实例”，又能满足我们的目的，这就需要用到单例模式

## 实现
以下是几种python代码实现单例的方式:
* 通过魔术方法`__new__`实现
* 通过metaclass实现
* 通过module实现
* 通过装饰器实现

> [!Note]
> 通常建议是使用`__new__`或metaclass实现，通过module和装饰器不建议采用，只作为实现参考。

### `__new__`实现
通过`__new__`关键字实现懒汉式单例模式。

```python
# singleton_new
class Sample(object):
    """
        >>> Sample() is Sample()
        True
    """
    _instance = None
    
    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls, *args, **kwargs)
        return cls._instance

```

### metaclass实现
以下是一个元类的定义，来自openpyxl源码
```python
class Singleton(type):
    """
    Singleton metaclass
    Based on Python Cookbook 3rd Edition Recipe 9.13
    Only one instance of a class can exist. Does not work with __slots__
    """

    def __init__(self, *args, **kw):
        super(Singleton, self).__init__(*args, **kw)
        self.__instance = None

    def __call__(self, *args, **kw):
        if self.__instance is None:
            self.__instance = super(Singleton, self).__call__(*args, **kw)
        return self.__instance
    
    
class A(metaclass=Singleton):
    """
        >>> A('zhangsan') is A('lisi')
        True
    """
    def __init__(self, name):
        self.name = name

```

### module实现
`Python`的模块就是天然的单例模式，module导入后，导入的对象会被缓存到sys.modules中，
之后再次导入该module会首先检查缓存中是否存在对象。
因此，我们只需把相关的函数和数据定义在一个模块中，就可以获得一个单例对象。

```python
# singleton_module.py
class _Sample:
    def __init__(self):
        ...

sample = _Sample()
```

> [!Note]
> 这本质上就是一个全局变量，并且将其类型隐藏起来实现的单例效果。


### 装饰器实现
函数装饰器实现
```python
# singleton_wrapper.py
from functools import wraps

def singleton(cls):
    """
        >>> A('zhangsan') is A('lisi')
        True
    """
    _instance = {}

    @wraps(cls)
    def _wrapper(*args, **kwargs):
        if cls not in _instance:
            _instance[cls] = cls(*args, **kwargs)
        return _instance[cls]
    return _wrapper

@singleton
class A:
    def __init__(self, name):
        self.name = name
```

类装饰器实现
```python
class Singleton(object):
    """
        >>> A('zhangsan') is A('lisi')
        True
    """
    _instance = {}
    
    def __init__(self, cls):
        self._cls = cls
        
    def __call__(self, *args, **kwargs):
        if self._cls not in self._instance:
            self._instance[self._cls] = self._cls(*args, **kwargs)
        return self._instance[self._cls]

    
@Singleton
class A:
    def __init__(self, name):
        self.name = name

```

> [!Warning]
> 这会将`A`从class“转化”为function。
> 考虑到作为单例的对象通常不会关心它的类，所以也有这种用法。

