# django-mptt


## 介绍


## 拓展
```python
def mptt_queryset_to_tree(qs, children_attr='children', root_pk=None):
    """
    将树结构查询集转换为真实的树结构。
    :param qs: 要转换的查询集。
    :param children_attr: 子节点属性名。
    :param root_pk: 根节点pk
    :return:
    """
    model_class = qs.model
    mptt_meta = model_class._mptt_meta
    parent_attr = mptt_meta.parent_attr

    root_data = []
    dict_data = {item.pk: item for item in qs}
    for item in qs:
        setattr(item, children_attr, [])
        parent_pk = getattr(item, f'{parent_attr}_id', None)

        if parent_pk == root_pk:
            root_data.append(item)
        else:
            parent = dict_data.get(parent_pk, None)         # 找到父节点
            if parent is None:
                continue

            if not hasattr(parent, children_attr):
                setattr(parent, children_attr, [])
            children = getattr(parent, children_attr)
            if not isinstance(children, list):
                children = []
            children.append(item)
    return root_data

```
