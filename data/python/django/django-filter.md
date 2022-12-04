# django-filter

`django-filter`是一个通用的，可重用的QuerySet筛选组件，能够有效减轻编写views代码的工作量。

### 为什么选用django-filter
* 用类似`ModelForm`的声明方式处理url查询参数
* 提供`rest_framework`子包能很好地集成到`Django-Rest-Framework`中

## 使用
### 添加app
```python
# settings.py
INSTALLED_APPS = [
    ...
    'django_filters',
]
```

### 基础使用

