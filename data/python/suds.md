# 说明

官方文档: https://jortel.fedorapeople.org/suds/doc/

suds是一个轻量级的WebService客户端，用于调用WebService接口


### 简单使用
```python
from suds.client import Client
client = Client(url, timeout=15, proxy=proxies)			# 客户端，配置请求相关参数
instance = getattr(client.service, method)				# 获取指定接口实例
ret_val = instance(**kwargs)							# 请求，ret_val通常为suds.object

```


### 直接返回xml文本
```python
client.options.retxml = True
instance = getattr(self.client.service, method)
ret_val = instance(**kwargs)
client.options.retxml = False
```
retxml参数可以作为Client的构造参数传入，也可能通过修改options的方法使个别请求返回xml		
*注意：py2中返回的是字符串，py3中返回的是bytes*


### suds.sudsobject.Object
sudsobject可以用str方法输出特定格式文本，用于日志记录
