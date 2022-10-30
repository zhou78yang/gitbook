# 心跳检测

官方文档: https://www.rabbitmq.com/heartbeats.html

> 很多应用层协议都有HeartBeat机制，通常是客户端每隔一小段时间向服务器发送一个数据包，通知服务器自己仍然在线，
> 并传输一些可能必要的数据。

RabbitMQ也有自己的心跳机制，用来检测客户端和服务端之间的TCP连接。在管理页面的Connection页可以跟进连接的状态。


## heartbeat timeout的值
在RabbitMQ服务器和客户端上都有heartbeat的timeout配置，当前（3.5.5之后）RabbitMQ服务端默认配置是60，单位是s。
可以在`/etc/rabbitmq/rabbitmq.conf`中查看或使用`rabbitmqctl environment`查看

对于两端的timeout值，一般是如此协商的：
* 如果有一端为0，取较大值（0为禁用）
* 两端都不为0，取较小值

> [!Warning|label:不确定的知识]
> 在pika客户端的实践中，若pika客户端没有设置heartbeat，则以RabbitMQ服务端为主，反之以客户端设置的heartbeat为主。且实际失效时间为heartbeat的3倍（默认配置下）


## 心跳帧(Heartbeat Frame)
心跳帧大约每`heartbeat timeout / 2`秒发送一次。此值有时称为**心跳间隔**。错过两次心跳后，对方被认为无法联系到。
不同的客户机以不同的方式显示这一点，但TCP连接将被关闭。
当客户端检测到RabbitMQ节点由于心跳而无法访问时，它需要重新连接。

> [!Note]
> 任何通信量（如协议操作、发送消息、ack等）都算作有效的心跳。客户机可以选择发送心跳帧，而不管连接上是否有任何其他通信，
> 但有些客户机只在必要时发送心跳帧

## 如何关闭heartbeat
通过在连接时在客户端将超时间隔设置为0，可以禁用heartbeat

> [!Warning|label: 注意]
> 除非已知环境在每台主机上都使用TCP keep-alive，否则强烈建议不要使用这种方法。


## 客户端配置(pika)

从rabbitmq3.5.5开始，RabbitMQ服务端的默认心跳超时从580秒减少到60秒。
因此，在运行pika连接的同一线程中执行长时间处理的应用程序可能会由于心跳超时而遇到意外的断开连接。

```python
import pika

params = pika.ConnectionParameters(heartbeat=600,
                                   blocked_connection_timeout=300)
conn = pika.BlockingConnection(params)
```
参数说明：
* heartbeat: 客户端`heartbeat timeout`值，单位为s，实际测试中发现Broker一端真正断开连接的时间是timeout值的3倍
* blocked_connection_timeout: 连接阻塞的超时时间，默认不超时


## 参考
* https://www.rabbitmq.com/heartbeats.html
* https://pika.readthedocs.io/en/stable/examples/heartbeat_and_blocked_timeouts.html