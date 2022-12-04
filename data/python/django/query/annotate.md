# 聚合
官方文档: [链接](https://docs.djangoproject.com/zh-hans/2.2/topics/db/aggregation/)

## annotate方法
`annotate`方法中的参数是`SELECT`子句中需要聚合的字段

### filter和annotate方法的顺序
filter在annotate之前: 对应`WHERE`子句

filter在annotate之后: 对应`HAVING`子句（或者一些奇怪的结果，不应该在annotate后filter不属于annotate中的字段）

### values和annotate方法的顺序
values在annotate之前: values中是`GROUP BY`子句的字段

values在annotate之后: values中是`SELECT`子句的字段

注意点：
* values_list也能实现group by聚合，使用方法同values
* QuerySet使用了values或者values_list后，QuerySet的项就不会再是Model实例

### order_by和annotate方法连用
order_by中是`ORDER BY`子句的字段，前后顺序不影响，多个order_by以最后一个为准.

当order_by同时与values和annotate连用时：<strong>order_by的参数也是`GROUP BY`子句中的字段</strong>


相关示例:
```python
# notes/models.py
class Document(models.Model):
    title = models.CharField(max_length=100, verbose_name='标题')
    content = models.TextField(default='', verbose_name='正文')
    created_time = models.DateTimeField(auto_now_add=True, editable=False, verbose_name='创建时间')
    updated_time = models.DateTimeField(auto_now=True, editable=False, verbose_name='最后修改时间')

    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, verbose_name='分类')
    tags = models.ManyToManyField(Tag, blank=True, verbose_name='标签')

    def __str__(self):
        return self.title

    class Meta:
        ordering = ('-created_time', )



>>> from notes.models import Document
>>> from django.db import models
>>> qs = Document.objects.all()
>>> str(qs.query)
'SELECT `notes_document`.`id`, `notes_document`.`title`, `notes_document`.`content`, `notes_document`.`created_time`, `notes_document`.`updated_time`, `notes_document`.`category_id` FROM `notes_document` ORDER BY `notes_document`.`created_time` DESC'

>>> # annotate单用(以pk聚合)
>>> sstr(qs.annotate(count=models.Count('id')).query)
'SELECT `notes_document`.`id`, `notes_document`.`title`, `notes_document`.`content`, `notes_document`.`created_time`, `notes_document`.`updated_time`, `notes_document`.`category_id`, COUNT(`notes_document`.`id`) AS `count` FROM `notes_document` GROUP BY `notes_document`.`id`'

>>> # filter在annotate之前(where)
>>> str(qs.filter(category_id=1).annotate(count=models.Count('id')).query)
'SELECT `notes_document`.`id`, `notes_document`.`title`, `notes_document`.`content`, `notes_document`.`created_time`, `notes_document`.`updated_time`, `notes_document`.`category_id`, COUNT(`notes_document`.`id`) AS `count` FROM `notes_document` WHERE `notes_document`.`category_id` = 1 GROUP BY `notes_document`.`id`'

>>> # values在annotate之前(group by)
>>> str(qs.values('category_id').annotate(count=models.Count('id')).order_by().query)
'SELECT `notes_document`.`category_id`, COUNT(`notes_document`.`id`) AS `count` FROM `notes_document` GROUP BY `notes_document`.`category_id` ORDER BY NULL'

>>> # 默认ordering和annotate连用的影响(等效于order_by与values和annotate连用)
>>> str(qs.values('category_id').annotate(count=models.Count('id')).query)
'SELECT `notes_document`.`category_id`, COUNT(`notes_document`.`id`) AS `count` FROM `notes_document` GROUP BY `notes_document`.`category_id`, `notes_document`.`created_time`'

>>> # filter在annotate之后(having)
>>> str(qs.values('category_id').annotate(count=models.Count('id')).filter(count__gt=1).order_by().query)
'SELECT `notes_document`.`category_id`, COUNT(`notes_document`.`id`) AS `count` FROM `notes_document` GROUP BY `notes_document`.`category_id` HAVING COUNT(`notes_document`.`id`) > 1 ORDER BY NULL'

>>> # values在annotate之后(select)
>>> str(qs.annotate(count=models.Count('id')).values('category_id', 'title').query)
'SELECT `notes_document`.`category_id`, `notes_document`.`title` FROM `notes_document` GROUP BY `notes_document`.`id`'


```