# Django-Rest-Framework的认证与权限

概念说明：
* 认证(Authentication): 服务器端获知当前请求的是哪个User
* 权限(Permission): 服务器端判定当前请求的User是否能够执行此操作

> [!Note]
> DRF的认证与权限配置只涉及接口级别的认证和权限，即View层的权限认证，作用于`rest_framework.views.APIView`及其派生类			
> 可以通过重写View的`authentication_classes`或者`get_authenticators()`来指定认证类			
> 可以通过重写View的`permission_classes`或者`get_permissions()`来指定权限类			

Django settings配置方式：
```python
REST_FRAMEWORK = {
    # 认证配置
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],

    # 权限配置
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],

    ...

}

```


## 认证

### 认证机制
* 认证的顺序按照settings配置的顺序进行，若某一个认证返回了用户，则会提前结束认证流程
* 认证是基于抛出异常来实现认证失败拦截的，若认证流程结束后都没有被拦截且无法获取到具体user，则会按照匿名用户处理

基于认证机制我们可以通过调整配置顺序，重写某些方法添加拦截或者取消拦截来自定义我们的认证

### 常用认证
* SessionAuthentication: `SessionMiddleware`的API版本，沿用Django的cookie认证形式进行认证，需要请求的时候携带带有sessionid的cookie
* TokenAuthentication: Token形式的认证后端，需要请求Headers携带Authorization，值的形式为`{keyword} {value}`，keyword默认为Token
* JSONWebTokenAuthentication: JWT的认证后端，可以理解为TokenAuthentication的派生类，用于JWT的认证

### 给现有认证添加缓存功能
* TokenAuthentication拓展: TokenAuthentication的派生类，添加缓存以减少数据库的查询次数
* JSONWebTokenAuthentication拓展: JSONWebTokenAuthentication的派生类，keyword是Token。添加缓存白名单使JWT失效，处理原生JWT签发后无法失效的问题

### 自定义测试用户认证
测试环境固定token的认证实现原理就是在settings_test中添加一组(token, username)映射，自定义一个测试后端（若token值在字典中能查到，则用映射用户登录）放置在认证配置列表最前

```python
# app/settings_test.py

# 测试环境长时token
REST_FRAMEWORK['DEFAULT_AUTHENTICATION_CLASSES'].insert(0, 'auth_ext.authentication.TestUserTokenAuthentication')
TEST_TOKEN_USER_MAPPING = {
    'b0f100fc27acdf16dd36073da6d60dc76dab7f73': 'xxxx',
}


# auth_ext/authentication.py
class TestUserTokenAuthentication(drf_authentication.TokenAuthentication):
    """
    django-rest-framework的认证是按照REST_FRAMEWORK['DEFAULT_AUTHENTICATION_CLASSES']先后顺序认证的，
    故该认证后端需要放在最前
    """
    def authenticate_credentials(self, key):
        TEST_TOKEN_USER_MAPPING = getattr(settings, 'TEST_TOKEN_USER_MAPPING', {})
        username = TEST_TOKEN_USER_MAPPING.get(key, None)
        if not username:
            return None

        user_model = apps.get_model(settings.AUTH_USER_MODEL)
        try:
            user = user_model.objects.get(username=username)
        except user_model.DoesNotExist:
            raise exceptions.AuthenticationFailed(_('Invalid token.'))
        return user, key

```


## 权限
### 权限机制
* 权限的验证顺序是按照settings配置的顺序进行，只有所有的权限认证都返回True才会算认证通过
* APIView在初始化的时候会调用`has_permission`验证view的权限，在APIView的`get_object()`方法被调用时会调用`has_object_permission()`验证对象的权限

### 常用权限
* IsAuthenticated: 判断user是否为登录用户
* IsAdminUser: 判断user是否为后台用户
* DjangoModelPermissions: 对API的增删查改接口验证Django默认权限


### 自定义权限
<b>1. 根据路由进行进行不同的权限校验</b>
```python
class DefaultPermission(drf_permissions.BasePermission):
    """
    api接口需要已认证用户，open-api接口需要外部系统用户认证
    """
    def has_permission(self, request, view):
        try:
            url_prefix = request.path.strip('/').split('/', 1)[0]
        except Exception as e:
            return False
        if url_prefix in ['api', 'docs']:
            return bool(request.user and request.user.is_authenticated)
        elif url_prefix in ['open-api', ]:
            return bool(request.user and getattr(request.user, 'external_user', None))
        elif url_prefix in ['open-docs', ]:
            return True
        return False
```

<b>2. 根据对象属性进行权限校验</b>
```python
class IsCreator(drf_permissions.BasePermission):
    """
    实现了auth_ext.mixins.CreatorMixin的Model可以判断是否是创建者

    """
    def has_object_permission(self, request, view, obj):
        if not isinstance(obj, CreatorMixin):
            return True
        return bool(request.user and request.user == obj.get_creator())


class IsOwner(drf_permissions.BasePermission):
    """
    实现了auth_ext.mixins.OwnerMixin的Model可以判断是否是拥有者

    """
    def has_object_permission(self, request, view, obj):
        if not isinstance(obj, OwnerMixin):
            return True
        return bool(request.user and request.user == obj.get_owner())
```


## Django的认证和权限
Django原生的认证和权限是由auth.backend实现的

settings配置
```python
# 认证后端配置
AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',
    'django_cas_ng.backends.CASBackend',
)
```

## 小结
Django和DRF的权限相辅相成，Django的权限认证（Backend）作用于Model层和前后端不分离情况，DRF的权限认证（Authentication和Permission）作用于API的View层。

异同点：
* Backend和Authentication的认证都是通过返回User或者抛出异常提前结束认证，整个认证流程结束都获取不到User则为匿名用户
* Backend权限验证任意一个后端返回True验证就通过，是any的逻辑
* Permission权限验证需要所有权限后端都返回True才验证通过，是all的逻辑

## 文档参考
* [DRF认证与权限](https://www.django-rest-framework.org/tutorial/4-authentication-and-permissions/)
* [DRF认证API](https://www.django-rest-framework.org/api-guide/authentication/)
* [DRF权限API](https://www.django-rest-framework.org/api-guide/permissions/)