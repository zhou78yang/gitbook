# Python装饰器

**装饰器是什么**

一个装饰器就是一个函数，它接受一个函数作为参数并返回一个新的函数。(函数实指callable对象)


**装饰器的作用**         

装饰器的主要目的是为了在不修改原有函数代码的情况下，增加额外功能，比如：插入日志、性能测试、事务处理、缓存、权限校验等场景。装饰器可以抽离出大量与函数功能本身无关的雷同代码并继续重用。


## 装饰器的定义
```python
# 基础的装饰器
def log(func):
    def wrapper(*args, **kwargs):
        print('running %s' % func.__name__)
        return func(*args, **kwargs)
    return wrapper
    
# 带参数的装饰器
def log_level(level, text):
    def decorator(func):
        def wrapper(*args, **kwargs):
            print('running %s: %s' % (func.__name__, text))
            return func(*args, **kwargs)
        return wrapper
    return decorator
```


## 装饰器的使用
```python
@log
def func(*args, **kwargs):
    pass
    
@log_level(level='WARNING', text='warning')
def func2(*args, **kwargs):
    pass
    
# 装饰器的作用相当于
def func(*args, **kwargs):
    pass
func = log(func)

def func2(*args, **kwargs):
    pass
func2 = (log_level(level='WARNING', text='warning'))(func2)
```
也就是说, 通过装饰器的包装, func其实已经变成了wrapper. 这样, 我们就给函数添加了额外功能,却又没有破坏函数的代码逻辑结构.


### 装饰类的顺序
```python
@a
@b
@c
def d():
    pass
# 等价于
d = a(b(c(d)))
```

### wraps方法(functools.wraps)
使用装饰器极大地复用了代码, 但是有一点, 它把原函数的元信息给覆盖掉了, 为了保持函数的元信息, python提供了内置的装饰器`wraps`来复制元信息
```python
from functools import wraps
def log(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        # do something
        return func(*args)
    return wrapper
```


## 装饰器类
相比于函数装饰器, 装饰器类具有灵活度大, 高内聚, 封装性等特点. 
```python
class Foo(object):
    def __init__(self, func):
        self._func = func
    
    # 使用类装饰器依赖于__call__方法
    def __call__(self):
        print('begin %s' % self._func.__name__)
        self._func()
        print('end %s' % self._func.__name__)
        
@Foo
def bar():
    print('bar()')
    
def Profiled(func):
    ncalls = 0
    @wraps(func)
    def wrapper(*args, **kwargs):
        nonlocal ncalls
        ncalls += 1
        return func(*args, **kwargs)
    wrapper.ncalls = lambda: ncalls
    return wrapper

# Example
@Profiled
def add(x, y):
    return x + y
```


## 装饰器实践案例

### 默认启用的装饰器
有一类情况, 我们需要在程序启动时就要将函数进行"绑定"之类的操作, 例如Django Signal中“接收者”装饰器的实现（django项目启动时会遍历项目，故被装饰器的函数将会和signal绑定）
```python
def receiver(signal, **kwargs):
    def _decorator(func):
        # 以下部分是在开始运行时就将函数与信号绑定了的
        if isinstance(signal, (list, tuple)):
            for s in signal:
                s.connect(func, **kwargs)
        else:
            signal.connect(func, **kwargs)
        return func
    return _decorator
```

### 同时支持传参和不传参的装饰器
同时支持传参和不传参的装饰器会给我们带来比较好的使用体验，例如retrying包:
```python
def retry(*dargs, **dkw):
    """
    Decorator function that instantiates the Retrying object
    @param *dargs: positional arguments passed to Retrying object
    @param **dkw: keyword arguments passed to the Retrying object
    """
    # support both @retry and @retry() as valid syntax
    if len(dargs) == 1 and callable(dargs[0]):
        def wrap_simple(f):

            @six.wraps(f)
            def wrapped_f(*args, **kw):
                return Retrying().call(f, *args, **kw)

            return wrapped_f

        return wrap_simple(dargs[0])

    else:
        def wrap(f):

            @six.wraps(f)
            def wrapped_f(*args, **kw):
                return Retrying(*dargs, **dkw).call(f, *args, **kw)

            return wrapped_f

        return wrap


class Retrying(object):
    ...
```
retrying将重试逻辑封装在Retrying类中，提供简易的装饰器方法，同时支持`@retry`和`@retry()`两种调用方式


## 拓展资料
* 如何理解Python装饰器？ https://www.zhihu.com/question/26930016
* 将装饰器定义为类 http://python3-cookbook.readthedocs.io/zh_CN/latest/c09/p09_define_decorators_as_classes.html
