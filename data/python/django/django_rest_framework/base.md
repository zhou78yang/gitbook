# REST-FRAMEWORK
官方文档: https://www.django-rest-framework.org/

Django Rest Framework是Django的一个View层框架，包含了完整的REST-API的封装和实现。

## 组成
DRF主要由三个对象组成:
* Request: 请求
* Response: 响应
* APIView: class-base的View层处理类

还有一系列为它们服务的其他对象:
* Authentication: 用户认证
* Permission: 用户权限
* Throttle: 请求限流
* Serializer: 序列化
* Validator: 数据校验
* Filter: 数据筛选(url查询参数处理)
* Pagination: 列表分页

`Request`, `Response`, `APIView`这三个对象是DRF这个View层框架的核心，其他所有的功能都是基于他们拓展开来的

## 请求(Request)
官方文档: https://www.django-rest-framework.org/api-guide/requests/

DRF的请求是对`django.http.request.HttpRequest`的一种增强，通过代理模式继承了HttpRequest的属性和一些方法，并给DRF提供其需要的方法。 

源码
```python
class Request:
    ...

    def __getattr__(self, attr):
        """
        If an attribute does not exist on this instance, then we also attempt
        to proxy it to the underlying HttpRequest object.
        """
        try:
            return getattr(self._request, attr)
        except AttributeError:
            return self.__getattribute__(attr)

```

## 响应(Response)
官方文档: https://www.django-rest-framework.org/api-guide/responses/

DRF的响应是`django.template.response.SimpleTemplateResponse`的子类，
当请求的Accept包含`application/json`时，返回json格式数据，否则渲染html页面。

## APIView
官方文档: https://www.django-rest-framework.org/api-guide/views/

DRF使用APIView而非Django的View，相对于直接使用Django的View，它有以下几点不同:
* 使用DRF的Request作为请求对象而非Django的HttpRequest
* 使用DRF的Response作为响应对象而非Django的HttpResponse
* 提供异常处理机制，所有的`APIException`都会被捕获并处理
* 提供了认证Authentication，权限Permission，限流Throttle等组件，在处理Request之前将会进行相关处理

