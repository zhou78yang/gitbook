# ASGI
ASGI可以看做是WSGI的超集，支持Python异步

最简单的一个asgi应用
```python
async def application(scope, receive, send):
    event = await receive()
    ...
    await send({"type": "websocket.send", ...})
```

asgi由三部分组成
* event
* receive
* send
