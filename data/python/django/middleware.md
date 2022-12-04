# 中间件

官方文档: [链接](https://docs.djangoproject.com/zh-hans/3.0/topics/http/middleware/)

中间件是`Django`请求/响应处理的钩子框架。它是一个轻量级的、低级的“插件”系统，用于全局改变`Django`的输入或输出。每个中间件组件负责做一些特定的功能。例如`Django`包含一个中间件组件`AuthenticationMiddleware`，它的作用就是通过`Session`给`request`添加`user`对象。

## 中间件配置
在`MIDDLEWARE`中，每个中间件组件由字符串表示：指向**中间件工厂**的类或函数名的完整Python路径。(自定义中间件相对项目根目录)
```python
# settings.py

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'your.middleware',
]
```
Django提供的中间件工厂查看 [中间件](https://docs.djangoproject.com/zh-hans/3.0/ref/middleware/#module-django.middleware)


## 自定义中间件工厂

**中间件工厂**是一个callable对象，它接受`get_response`并返回中间件。中间件也是callable对象，它接受请求并返回响应。

中间件可以被写成这样的函数：
```python
def simple_middleware(get_response):
    # One-time configuration and initialization.

    def middleware(request):
        # Code to be executed for each request before
        # the view (and later middleware) are called.

        response = get_response(request)

        # Code to be executed for each request/response after
        # the view is called.

        return response

    return middleware
```

或者它可以写成一个类，它的实例是可调用的，如下：
```python
class SimpleMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        # One-time configuration and initialization.

    def __call__(self, request):
        # Code to be executed for each request before
        # the view (and later middleware) are called.

        response = self.get_response(request)

        # Code to be executed for each request/response after
        # the view is called.

        return response
```

Django也提供了一个Mixin，一般是通过继承`MiddlewareMixin`并实现`process_request`和`process_response`两个方法分别处理请求和详情来拓展系统功能。

<b>MiddlewareMixin源码</b>
```python
class MiddlewareMixin:
    def __init__(self, get_response=None):
        self.get_response = get_response
        super().__init__()

    def __call__(self, request):
        response = None
        if hasattr(self, 'process_request'):
            response = self.process_request(request)
        response = response or self.get_response(request)
        if hasattr(self, 'process_response'):
            response = self.process_response(request, response)
        return response

```

## 自定义中间件案例

### 记录请求日志的中间件
```
import time
import json
import logging
from django.utils.deprecation import MiddlewareMixin


class LogMiddleware(MiddlewareMixin):
    """ 通过session的认证方式记录 """

    def process_request(self, request):
        try:
            if request.session.session_key is not None:
                data = {
                    "name": str(request.user),
                    "sid": request.session.session_key,
                    "action_time": time.strftime("%Y-%m-%dT%H:%M:%S+08:00", time.localtime()),
                    "uri": request.path
                }
                logger = logging.getLogger('access_log')
                logger.info(msg=json.dumps(data))
        except Exception as e:
            logger.error(e)

    def process_response(self, request, response):
        return response

```


