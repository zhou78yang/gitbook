# Signal

信号(Signal)是Django内置的一种解耦方式，当框架中的其他地方发生操作时，它可以帮助解耦的应用程序得到通知。

组成:
* Signal: 信号对象，`django.dispatch.Signal`的一个实例
* Sender: 消息发送方
* Receiver/Handler: 消息接收方，处理信号的一个callable对象


常用的一些关于Model的内置Signal:
* pre_init: Model实例化开始
* post_init: Model实例化结束
* pre_save: 保存数据之前（`save`方法内）
* post_save: 保存数据之后（`save`方法内）
* pre_delete: 删除之前（`delete`方法内)
* post_delete: 删除之后（`delete`方法内)
* m2m_changed: 多对多关联对象有改动，action判断动作类型


## 监听信号和信号绑定
Signal提供两种绑定handler的方法 			

### 通过`Signal.connect`直接绑定
```python
from django.core.signals import request_finished

def my_callback(sender, **kwargs):
    print("Request finished!")

request_finished.connect(my_callback)
```

### 通过`receiver`装饰器绑定
```python
from django.core.signals import request_finished
from django.dispatch import receiver

@receiver(request_finished)
def my_callback(sender, **kwargs):
    print("Request finished!")
```

> [!Note]
> 接收方法应该放在哪 		
> 严格地说，信号处理和注册代码可以放在项目中的任何位置，但是建议避免应用程序的根模块及其模型模块，以尽量减少导入代码的副作用。			
> 实际开发中，Handler通常在与其相关的应用的`signals.py`中定义，然后在Sender所在应用APPConfig的`ready()`方法中连接。如果使用的是`receiver()`装饰器，只需在`ready()`中导入`signals.py`即可。


如果以`ready`的方式导入signals方法，需要注意测试时的情况
> [!Warning]
> `AppConfig.ready()`方法可能在test中会执行多次


## 自定义和发送信号
所有的信号都是`django.dispatch.Signal`的实例，以下是一个信号的定义
```python
from django.dispatch import Signal

# providing_args只是起文档的作用，并不会去检查你执行send方法的代码是否传入指定参数
my_signal = Signal(providing_args=['instance', 'size'])

```

发送信号
```python
class MySender:
    def send_signal(self):
    	my_signal.send(sender=self.__class__, instance=self, size=5)

```


## 参考
* [Django Signal主题](https://docs.djangoproject.com/zh-hans/2.2/topics/signals/)
* [Django内置的Signal列表](https://docs.djangoproject.com/zh-hans/2.2/ref/signals/)
