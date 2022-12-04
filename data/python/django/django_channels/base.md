# Django Channels

## 介绍
* Channels是什么？主要解决什么问题？
* Channels的优势和劣势
* Channels的工作原理"turtles all the way down"
    * asgi: 构建Channels的异步服务器规范名称，相当于是wsgi在同步应用中的作用
    * daphne: Channels推荐的默认异步服务器
* Django的views仍然是系统中的一部分，并且在Channels中依旧可用。我们可以使用`channels.http.AsgiHandler`将其包装在ASGI应用中
* Channels的理念: 我们依旧对Django views等使用安全、同步的技术，为复杂场景使用更直接、异步的接口


## Scopes and Events
Channels和ASGI将传入的连接分成了两个组件：作用域和一系列事件
* Scope(作用域)是什么？主要作用
* Event(事件)是什么？主要作用


## Consumer(消费者)
* Consumer是什么？主要作用
    Consumer(消费者)是Channels代码中的基本单位，我们称之为消费者是因为它能消费Event（事件），但可以把它认为是一个小型应用。当一个请求或新的socket传入时，Channels会根据路由表查看一段时间内的最后消费者，然后开启它的一个复制
    Consumers通常是长期存在的，它们是基于生存一段时间的想法构建的（它们的生存周期维持在一个scope中）

<b>基本的consumer</b>
```python
class ChatConsumer(WebsocketConsumer):

    def connect(self):
        self.username = "Anonymous"
        self.accept()
        self.send(text_data="[Welcome %s!]" % self.username)

    def receive(self, *, text_data):
        if text_data.startswith("/name"):
            self.username = text_data[5:].strip()
            self.send(text_data="[set your username to %s]" % self.username)
        else:
            self.send(text_data=self.username + ": " + text_data)

    def disconnect(self, message):
        pass
```
每种不同的协议都有不同类型的事件发生，每种类型都由不同的方法表示。开发者负责编写每个事件的代码，并交由Channels来负责调度他们

<b>在异步事件循环中安全地执行阻塞操作(调度django orm)</b>
```python
class LogConsumer(WebsocketConsumer):

    def connect(self, message):
        Log.objects.create(
            type="connected",
            client=self.scope["client"],
        )
```

<b>完全异步的Consumer</b>
```python
class PingConsumer(AsyncConsumer):
    async def websocket_connect(self, message):
        await self.send({
            "type": "websocket.accept",
        })

    async def websocket_receive(self, message):
        await asyncio.sleep(1)
        await self.send({
            "type": "websocket.send",
            "text": "pong",
        })
```


## Rounting(路由)与Multiple Protocols(多协议)
Channels不仅仅是为HTTP和WebSocket构建的，还能适用于Django环境下的各种协议（包括自定义协议）

<b>ASGI应用的路由</b>
```python
application = URLRouter([
    url(r"^chat/admin/$", AdminChatConsumer),
    url(r"^chat/$", PublicChatConsumer),
])
```
*绑定Consumer与URL patterns*

<b>多协议下的URL路由</b>
```python
application = ProtocolTypeRouter({

    "websocket": URLRouter([
        url(r"^chat/admin/$", AdminChatConsumer),
        url(r"^chat/$", PublicChatConsumer),
    ]),

    "telegram": ChattyBotConsumer,
})
```


## 跨进程通信
...


## 注意
* ASGI Application需要有独立的URL routing，middleware

