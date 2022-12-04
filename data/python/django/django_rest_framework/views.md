# 视图（View）

官方文档: https://www.django-rest-framework.org/api-guide/views/

DRF使用APIView而非Django的View，相对于直接使用Django的View，它有以下几点不同:
* 使用DRF的Request作为请求对象而非Django的HttpRequest
* 使用DRF的Response作为响应对象而非Django的HttpResponse
* 提供异常处理机制，所有的`APIException`都会被捕获并处理
* 提供了认证Authentication，权限Permission，限流Throttle等组件，在处理Request之前将会进行相关处理

和Django的`View`一样，`APIView`可以通过实现诸如`get()`, `post()`的实例方法来处理`GET`，`POST`请求，
除此之外，APIView还提供了很多属性和方法来添加一些可插拔的控制。

## [APIView](https://www.django-rest-framework.org/api-guide/views/#class-based-views)
`APIView`主要是重写了`View`的`as_view()`和`dispatch()`方法来添加很多关于DRF的钩子。

```python
class APIView(View):

    # The following policies may be set at either globally, or per-view.
    renderer_classes = api_settings.DEFAULT_RENDERER_CLASSES
    parser_classes = api_settings.DEFAULT_PARSER_CLASSES
    authentication_classes = api_settings.DEFAULT_AUTHENTICATION_CLASSES
    throttle_classes = api_settings.DEFAULT_THROTTLE_CLASSES
    permission_classes = api_settings.DEFAULT_PERMISSION_CLASSES
    content_negotiation_class = api_settings.DEFAULT_CONTENT_NEGOTIATION_CLASS
    metadata_class = api_settings.DEFAULT_METADATA_CLASS
    versioning_class = api_settings.DEFAULT_VERSIONING_CLASS

    # Allow dependency injection of other settings to make testing easier.
    settings = api_settings

    schema = DefaultSchema()

    @classmethod
    def as_view(cls, **initkwargshttps://www.django-rest-framework.org/api-guide/viewsets/):
        """
        Store the original class on the view function.

        This allows us to discover information about the view when we do URL
        reverse lookups.  Used for breadcrumb generation.
        """
        if isinstance(getattr(cls, 'queryset', None), models.query.QuerySet):
            def force_evaluation():
                raise RuntimeError(
                    'Do not evaluate the `.queryset` attribute directly, '
                    'as the result will be cached and reused between requests. '
                    'Use `.all()` or call `.get_queryset()` instead.'
                )
            cls.queryset._fetch_all = force_evaluation

        view = super().as_view(**initkwargs)
        view.cls = cls
        view.initkwargs = initkwargs

        # Note: session based authentication is explicitly CSRF validated,
         # all other authentication is CSRF exempt.
        return csrf_exempt(view)

    # Note: Views are made CSRF exempt from within `as_view` as to prevent
    # accidental removal of this exemption in cases where `dispatch` needs to
    # be overridden.
    def dispatch(self, request, *args, **kwargs):
        """
        `.dispatch()` is pretty much the same as Django's regular dispatch,
        but with extra hooks for startup, finalize, and exception handling.
        """
        self.args = args
        self.kwargs = kwargs
        request = self.initialize_request(request, *args, **kwargs)
        self.request = request
        self.headers = self.default_response_headers  # deprecate?

        try:
            self.initial(request, *args, **kwargs)

            # Get the appropriate handler method
            if request.method.lower() in self.http_method_names:
                handler = getattr(self, request.method.lower(),
                                  self.http_method_not_allowed)
            else:
                handler = self.http_method_not_allowed

            response = handler(request, *args, **kwargs)

        except Exception as exc:
            response = self.handle_exception(exc)

        self.response = self.finalize_response(request, response, *args, **kwargs)
        return self.response

```


### policies
* `renderer_classes`: 渲染响应数据
* `parser_classes`: 解析请求数据
* `authentication_classes`: 用户认证(哪个用户请求的接口)
* `throttle_classes`: 限流
* `permission_classes`: 权限控制(用户是否能够请求接口)

### 获取policies的方法
* `get_renderers(self)`: 渲染响应数据
* `get_parsers(self)`: 解析请求数据
* `get_authenticators(self)`: 用户认证
* `get_throttles(self)`: 限流
* `get_permissions(self)`: 权限控制
* `get_exception_handler(self)`: 异常处理

### dispatch中的方法
* `initial(self, request, *args, **kwargs)`: 初始化操作
* `handle_exception(self, exc)`: 所有handler中抛出的异常都会流转到这里
* `initialize_request(self, request, *args, **kwargs)`: 将Django的HttpRequest转换为Request
* `finalize_response(self, request, response, *args, **kwargs)`: 确保从处理程序方法返回的任何响应对象都将呈现为由内容协商确定的正确内容类型。

initial(初始化)中包含的操作:
* `perform_content_negotiation(self, request, force=False)`
* `perform_authentication(self, request)`: 认证
* `check_permissions(self, request)`: 权限检查
* `check_throttles(self, request)`: 限流检查


## [api_view装饰器](https://www.django-rest-framework.org/api-guide/views/#api_view)
并不是所有时候都需要使用`class-based view`，DRF提供了一个装饰器`@api_view`来实现基于函数的view。

使用
```python
from rest_framework.decorators import api_view

@api_view()
def hello_world(request):
    return Response({"message": "Hello, world!"})
```

此外还提供了一系列policies的装饰器
* `@renderer_classes(...)`
* `@parser_classes(...)`
* `@authentication_classes(...)`
* `@throttle_classes(...)`
* `@permission_classes(...)`

源码位置: rest_framework/decorators.py


## [DRF的Generic View](https://www.django-rest-framework.org/api-guide/generic-views/)
`class-based view`的一大优势就是其拓展性，DRF基于APIView提供了一系列预设的`Generic View`，使我们能够开箱即用。

源码位置: rest_framework/generics.py

### GenericAPIView
`GenericAPIView`是`Generic View`的基类，相比于`APIView`，它和`Django`更“亲近”些，提供了更多的属性和方法

```python
class GenericAPIView(views.APIView):
    # You'll need to either set these attributes,
    # or override `get_queryset()`/`get_serializer_class()`.
    queryset = None
    serializer_class = None
    lookup_field = 'pk'
    filter_backends = api_settings.DEFAULT_FILTER_BACKENDS
    pagination_class = api_settings.DEFAULT_PAGINATION_CLASS


```
我们可以通过重写这些属性或方法来实现业务

属性
* `queryset`: 查询集
* `serializer_class`: 序列化类
* `lookup_field`: 详情url pattern中的参数
* `filter_backends`: 过滤器backend
* `pagination_class`: 分页类

方法
* `get_queryset(self): 获取基础查询集，可以将lookup_field中参数筛选置于此，返回一个QuerySet
* `filter_queryset(self, queryset)`: url查询参数的筛选，返回一个QuerySet
* `paginate_queryset(self, queryset)`: 分页，返回一个列表
* `get_object(self)`: 获取详情对象
* `get_serializer_class(self)`: 获取Serializer类
* `get_serializer(self, instance=None, data=None, many=False, partial=False)`: 获取序列化器
* `get_serializer_context(self)`: 传给序列化器的上下文，这使我们能将request，view之类的对象传入serializer中

> [!Note]
> 方法可以覆盖对应的属性


### Mixins
DRF预设了一些常用的`Mixins`，通过`Mixins`和`GenericAPIView`的排列组合，实现了各式各样的`Generic View`。

源码位置: rest_framework/mixins.py

预设的mixins
* `ListModelMixin`
* `CreateModelMixin`
* `RetrieveModelMixin`
* `UpdateModelMixin`
* `DestroyModelMixin`

排列组合成的`Generic View`: https://www.django-rest-framework.org/api-guide/generic-views/#concrete-view-classes


## 小结
`APIView`是DRF的基础，但我们一般不会直接使用它，而是使用`GenericAPIView`及其派生类。
`APIView`和`GenericAPIView`提供了很多钩子，我们可以通过重写类属性和方法来实现拓展，用好DRF的关键是找准需要重写的属性/方法，
这会使我们的view层代码轻便且易于拓展。