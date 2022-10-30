# rabbitmqctl

RabbitMQ自带了一个命令行管理工具，以下是一些常用指令

## 查看队列信息
```bash
$ sudo rabbitmqctl list_queues
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
name	messages
hello	2
```

## 监控消息消费情况
```bash
$ sudo rabbitmqctl list_queues name messages_ready messages_unacknowledged
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
name	messages_ready	messages_unacknowledged
hello	1	0
```

## 查看交换机列表
```bash
$ sudo rabbitmqctl list_exchanges
Listing exchanges for vhost / ...
name    type
amq.topic       topic
        direct
amq.fanout      fanout
amq.rabbitmq.trace      topic
amq.match       headers
amq.headers     headers
amq.direct      direct
```

## 查看Bindings信息
```bash
$ sudo rabbitmqctl list_bindings
Listing bindings for vhost /...
source_name     source_kind     destination_name        destination_kind        routing_key     arguments
        exchange        amq.gen-q645RQTBE5CYxoJQ_-kl9A  queue   amq.gen-q645RQTBE5CYxoJQ_-kl9A  []
        exchange        amq.gen-hgjb_amHNdTYf_TRBhOSfQ  queue   amq.gen-hgjb_amHNdTYf_TRBhOSfQ  []
        exchange        amq.gen-ko6-oKLPU6sB165RcZfyIw  queue   amq.gen-ko6-oKLPU6sB165RcZfyIw  []
logs    exchange        amq.gen-hgjb_amHNdTYf_TRBhOSfQ  queue   amq.gen-hgjb_amHNdTYf_TRBhOSfQ  []
logs    exchange        amq.gen-ko6-oKLPU6sB165RcZfyIw  queue   amq.gen-ko6-oKLPU6sB165RcZfyIw  []
logs    exchange        amq.gen-q645RQTBE5CYxoJQ_-kl9A  queue   amq.gen-q645RQTBE5CYxoJQ_-kl9A  []

```
