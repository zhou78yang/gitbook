# SearchFilter

## DRF SearchFilter说明
SearchFilter是Django-rest-framework默认的搜索后端，也是一种FilterBackend。

### 使用
默认可以在View中指定search_fields标明可搜索字段，可以通过添加前缀实现更精确的匹配需求（默认为icontains)，参照：
```python    
    lookup_prefixes = {
        '^': 'istartswith',	# 前部模糊匹配
        '=': 'iexact',		# 精确匹配
        '@': 'search',		# 仅postgresql支持
        '$': 'iregex',		# 正则匹配
    }
```

### 搜索逻辑
前端传入搜索参数（默认search),SearchFilter可以按照（空格，半角逗号，换行，空白等）参数为一个search_terms列表

筛选逻辑：
```python
AND(OR(Q(field=term) for field in search_fields) for term in search_terms)
```
举例：
* sku列表接口的search_fields为 sku, spu, name
* 请求接口入参为 search=PUSH, CKSCBX0, M码

实际匹配为
```sql
where ((`sku` LIKE '%PUSH%' OR `spu_code` LIKE '%PUSH%' OR `chinese_title` LIKE '%PUSH%') AND (`sku` LIKE '%CKSCBX0%' OR `spu_code` LIKE '%CKSCBX0%' OR `chinese_title` LIKE '%CKSCBX0%') AND (`sku` LIKE '%M码%' OR `spu_code` LIKE '%M码%' OR `chinese_title` LIKE '%M码%'))
```
实现了很精确的搜索匹配，同时也牺牲了查询效率


## 自定义拓展

### 支持批量筛选的SearchFilter设计
目标: 使同一个搜索框中实现模糊搜索和列表搜索

实现方案：
1. 修改搜索参数分片逻辑，如果有英文逗号，则使用英文逗号分片，否则使用空白分片
2. 搜索参数数量不大于1时使用原SearchFilter进行筛选；大于1时使用列表精确匹配
3. 可以通过加英文逗号的方式保留原有的多值精确匹配功能


```python
class SearchFilter(filters.SearchFilter):
    """
    定制搜索FilterBackend，在原SearchFilter的基础上进行调整，新增支持列表筛选
    示例说明：
    search_fields = ('A', '^B', 'A__C')

    eg1: ?search=1, 2, 3, 4,
    逗号分隔的列表筛选
    ==> Q(A__in=[1,2,3,4]) | Q(B__in=[1,2,3,4]) | Q(A__C__in=[1,2,3,4])

    eg2: ?search=1 2 3 4
    空白分隔的列表筛选
    ==> Q(A__in=[1,2,3,4]) | Q(B__in=[1,2,3,4]) | Q(A__C__in=[1,2,3,4])

    eg3: ?search=1 2, 3 4
    搜索值中包含空格的列表筛选，例如B2W的订单号
    ==> Q(A__in=['1 2', '3 4']) | Q(B__in=['1 2', '3 4']) | Q(A__C__in=['1 2', '3 4'])

    eg4: ?search=张三
    模糊搜索
    ==> Q(A__icontains='张三') | Q(B__istartswith='张三') | Q(A__C__icontains='张三')

    eg5: ?search=,张三 M码
    精确匹配，通过`,`开头或者结尾实现多值精确匹配
    ==> (Q(A__icontains='张三') | Q(B__istartswith='张三') | Q(A__C__icontains='张三')) &
        (Q(A__icontains='M码') | Q(B__istartswith='M码') | Q(A__C__icontains='M码'))

    """

    def get_my_search_terms(self, request):
        """
        搜索参数分片（有继承问题，不能直接使用get_search_terms）：
        1. 搜索参数包含`,`时按照`,`进行分片，也可以利用此机制进行精确搜索
        2. 搜索参数中不包含`,`按照空白进行分片
        """
        params = request.query_params.get(self.search_param, '')
        params = params.replace('\x00', '')  # strip null characters

        if ',' in params:
            return [s.strip() for s in params.strip(',').split(',')]    # 去掉头尾`,`后分片，确保terms数量正确
        return params.split()

    def construct_list_search(self, field_name):
        """ 构造列表搜索的orm查询条件 """
        if self.lookup_prefixes.get(field_name[0]):
            # 有前缀的去除前缀
            field_name = field_name[1:]
        lookup = 'in'   # 搜索列表
        return LOOKUP_SEP.join([field_name, lookup])

    def filter_queryset(self, request, queryset, view):
        search_terms = self.get_my_search_terms(request)
        if len(search_terms) <= 1:
            # 搜索参数数量不大于1时使用原SearchFilter进行筛选
            return super().filter_queryset(request, queryset, view)
        search_fields = self.get_search_fields(view, request)

        if not search_fields or not search_terms:
            return queryset

        orm_lookups = [
            self.construct_list_search(str(search_field))
            for search_field in search_fields
        ]

        queries = [
            models.Q(**{orm_lookup: search_terms})
            for orm_lookup in orm_lookups
        ]
        base = queryset
        queryset = queryset.filter(reduce(operator.or_, queries))

        if self.must_call_distinct(queryset, search_fields):
            queryset = distinct(queryset, base)
        return queryset
```

