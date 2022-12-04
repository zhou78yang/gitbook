# 聚合表达式
官方文档: [链接](https://docs.djangoproject.com/zh-hans/2.2/ref/models/expressions/#aggregate-expressions)

## 聚合函数
Django提供的默认聚合函数
* Avg: 对标数据库AVG函数，求平均值
* Count: 对标数据库COUNT函数，计数
* Max: 对标数据库MAX函数，求最大值
* Min: 对标数据库MIN函数，求最小值
* StdDev: 对标数据库STDDEV_SAMP(样本方差的算术平方根), STDDEV_POP(方差的算术平方根)，通过sample是否为True区分
* Sum: 对标数据库SUM函数，求和
* Variance: 对标数据库VAR_SAMP(非空集合的样本变量)，VAR_POP(非空集合的总体变量)，通过sample是否为True区分

## 自定义聚合
以自定义GROUP_CONCAT为例
```python
class GroupConcat(models.Aggregate):
    """
    自定义Django聚合函数实现GROUP_CONCAT
    excample:

    >>> qs = Document.objects.all()
    >>> str(qs.values('category_id').annotate(titles=GroupConcat('title')).order_by().query)
    'SELECT `notes_document`.`category_id`, GROUP_CONCAT(`notes_document`.`title` SEPARATOR ",") AS `titles` \
FROM `notes_document` GROUP BY `notes_document`.`category_id` ORDER BY NULL'

    """
    function = 'GROUP_CONCAT'
    name = 'GroupConcat'
    template = '%(function)s(%(distinct)s%(expressions)s%(separator)s)'

    def __init__(self, expression, distinct=False, separator=',', **extra):
        super(GroupConcat, self).__init__(
            expression,
            distinct='DISTINCT ' if distinct else '',
            separator=' SEPARATOR "{}"'.format(separator.replace('\"', r'\"')),
            output_field=models.CharField(),
            **extra)
```