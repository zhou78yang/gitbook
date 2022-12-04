# xmltodict
文档: [链接](https://github.com/martinblech/xmltodict)

`xmltodict`是对`xml`包的一个高级封装，主要是处理xml和dict之间的转换。提供以下两个api方法:
* parse: xml转换成dict
* unparse: dict转换成xml

## xml转换dict
转换结果为一个OrderedDict，相同元素会转换成列表

### string
```python
>>> import xmltodict
>>> doc = xmltodict.parse("""
... <a prop="x">
... 	<b>1</b>
... 	<b>2</b>
... </a>
... """)
>>> doc
OrderedDict([('a', OrderedDict([('@prop', 'x'), ('b', ['1', '2'])]))])
>>> doc['a']
OrderedDict([('@prop', 'x'), ('b', ['1', '2'])])
>>> doc['a']['b']
['1', '2']

```

### file-like
```python
# test.xml
<test>
    <a>haha</a>
</test>


>>> with open('test.xml', 'rb') as f:
... 	doc = xmltodict.parse(f)
... 
>>> doc
OrderedDict([('test', OrderedDict([('a', 'haha')]))])
>>> doc['test']['a']
'haha'
```

## dict转换xml
```python
>>> d = {'a': {'b': [1, 2], '@prop': '???'}}
>>> xmltodict.unparse(d) 
'<?xml version="1.0" encoding="utf-8"?>\n<a prop="???"><b>1</b><b>2</b></a>'

>>> xmltodict.unparse(d, full_document=False)
'<a prop="???"><b>1</b><b>2</b></a>'

```
