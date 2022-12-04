# Requests
[文档](https://requests.readthedocs.io/zh_CN/latest/index.html)
> Requests 唯一的一个非转基因的 Python HTTP 库，人类可以安全享用。

## 代理
文档: https://docs.python-requests.org/zh_CN/latest/user/advanced.html#proxies

通过指定参数`proxies`可以给单个请求指定代理，或者可以直接修改Session对象的`proxies`来在Session内复用
```python
import requests

proxies = {
  "http": "http://10.10.1.10:3128",
  "https": "http://10.10.1.10:1080",
}

requests.get("http://example.org", proxies=proxies)
```
若需要使用HTTP Basic Auth，可以使用`http://user:password@host/`语法

使用socks代理
```python
proxies = {
    'http': 'socks5://user:pass@host:port',
    'https': 'socks5://user:pass@host:port'
}
```

## 超时
你可以告诉`requests`在经过以`timeout`参数设定的秒数时间之后停止等待响应。基本上所有的生产代码都应该使用这一参数。如果不使用，你的程序可能会永远失去响应：
```python
>>> requests.get('http://github.com', timeout=0.001)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
requests.exceptions.Timeout: HTTPConnectionPool(host='github.com', port=80): Request timed out. (timeout=0.001)
```
注意
`timeout`仅对连接过程有效，与响应体的下载无关。 `timeout`并不是整个下载响应的时间限制，而是如果服务器在`timeout`秒内没有应答，将会引发一个异常（更精确地说，是在 timeout 秒内没有从基础套接字上接收到任何字节的数据时）


为防止服务器不能及时响应，大部分发至外部服务器的请求都应该带着`timeout`参数。在默认情况下，除非显式指定了`timeout`值，`requests`是不会自动进行超时处理的。如果没有`timeout`，你的代码可能会挂起若干分钟甚至更长时间。			
**连接超时**指的是在你的客户端实现到远端机器端口的连接时（对应的是`connect()`），Request 会等待的秒数。一个很好的实践方法是把连接超时设为比 3 的倍数略大的一个数值，因为 TCP 数据包重传窗口 (TCP packet retransmission window) 的默认大小是 3。一旦你的客户端连接到了服务器并且发送了 HTTP 请求，**读取超时**指的就是客户端等待服务器发送请求的时间。（特定地，它指的是客户端要等待服务器发送字节之间的时间。在 99.9% 的情况下这指的是服务器发送第一个字节之前的时间）。

使用示例:
```python
# 这一 timeout 值将会用作 connect 和 read 二者的 timeout。
r = requests.get('https://github.com', timeout=5)		

# 如果要分别制定，就传入一个元组 (连接超时，读取超时)
r = requests.get('https://github.com', timeout=(3.05, 27))

# 默认情况下
r = requests.get('https://github.com', timeout=None)
```
