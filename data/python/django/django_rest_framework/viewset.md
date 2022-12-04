# ViewSet

官方文档: https://www.django-rest-framework.org/api-guide/viewsets/

`ViewSet`是对`APIView`的进一步拓展，将具有共性和相同url前缀的多个`APIView`组合在一起。
在其他框架中可能会命名为`Resources`或`Controllers`。

## 使用
DRF中内置了几种ViewSet:
* `ViewSet`: 对标`APIView`，`APIView`的拓展
* `GenericViewSet`: 对标`GenericView`
* `ReadOnlyModelViewSet`: 继承了只读方法的`GenericViewSet`
* `ModelViewSet`: 继承了所有CRUD方法的`GenericViewSet`

通常我们使用时会直接使用较高层级的`ReadOnlyModelViewSet`和`ModelViewSet`。
下面就是一个简单的ViewSet示例，实现了User表的所有CRUD接口方法:

```python
class UserViewSet(viewsets.ModelViewSet):
    serializer_class = UserSerializer
    queryset = User.objects.all()

```

### ViewSet的优势
和`View`相比，`ViewSet`主要具有以下两个优势:
* 重复的逻辑可以组合成一个类。在上面的例子中，我们只需要指定queryset一次，就可以在多个View中使用。
* 通过使用Router，不再需要对每个View进行url绑定

> [!Note]
> 如无必要，勿增实体，如果`GenericView`就能解决问题，就没有必要都上`ViewSet`。
> 即使后面需要新增接口，拓展成`ViewSet`也很方便，替换基类即可



## Router

通常`ViewSet`是通过`Router`进行url注册的
```python
from myapp.views import UserViewSet
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
urlpatterns = router.urls
```

*注：我们也可以通过`as_view`进行注册，但是一般不会这样做*
```python
user_list = UserViewSet.as_view({'get': 'list'})
user_detail = UserViewSet.as_view({'get': 'retrieve'})
```

## action
`ViewSet`对象上相对于`APIView`新增了几个属性:
* basename: 对应url配置的basename
* action: 当前处理请求的“动作”（例如：list, retrieve, create等）
* detail: 当前action视为一个ListView还是一个DetailView
* suffix: 类型，通常只在detail=True的时候显示为`'instance'`
* name: 当前action的名字
* description: action的描述（action的文档注释）

同时，action也是ViewSet中一个重要的概念，ViewSet中将能够作为请求handler的方法定义为action，如ModelViewSet中内置的`list`, `retrieve`, `create`, `update`, `destroy`等方法。
我们可以通过装饰器`@action`实现自定义action。


### 添加额外的action
自定义action示例
```python
from rest_framework import viewsets, response
from rest_framework.decorators import action


class PostViewSet(viewsets.ModelViewSet):
    ...

    @action(detail=False, methods=['GET'], serializer_class=TagSerializer)
    def tags(self, request, *args, **kwargs):
        serializer = self.get_serializer(Tag.objects.all(), many=True)
        return response.Response(data={'detail': '获取全部标签', 'data': serializer.data})

    @action(detail=True, methods=['POST'], url_path='tags')
    def add_tags(self, request, *args, **kwargs):
        # POST {BASE}/{pk}/tags/
        return response.Response(data={'detail': '添加标签'})

    @action(detail=True, methods=['GET'])
    def draft(self, request, *args, **kwargs):
        # GET {BASE}/{pk}/draft/
        return response.Response(data={'detail': '获取草稿'})

    @draft.mapping.post
    def create_draft(self, request, *args, **kwargs):
        # POST {BASE}/{pk}/draft/
        return response.Response(data={'detail': '添加草稿'})

```
解释:
* `detail`是用于区分是否为`detail view`的参数
* `methods`定义支持的请求方法
* `url_path`用于指定action的url路径
* 通过mapping可以对现在action进行其他请求方法的拓展。注意，mapping不接受任何其他参数
* 可以在action装饰器中重写`serializer_class`, `permission_classes`等View层级的属性，作用于当前action内

> [!Note]
> 通过`.get_extra_actions()`可以获取ViewSet中的所有拓展action。
> 上文中的create_draft方法不是一个action，不会出现在`.get_extra_actions()`的结果中，而是作为函数的mapping存在。
> 但是，在请求分派到create_draft时，`self.action`的值还是`create_draft`的。

