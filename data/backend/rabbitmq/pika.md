# pika
pika是`AMQP 0-9-1`的一种python实现。而RabbitMQ是AMQP的Broker实现，所以我们通常使用pika来作为RabbitMQ的客户端。


## Usage

### 队列声明
```python
# arguments是一个字典
arguments = {
	'x-message-ttl': 60*1000,
	'x-max-length': 10
	'x-dead-letter-exchange': 'dlx',
	'x-dead-letter-routing-key': 'dl_key',
}

channel.queue_declare(
	'queue_name', 
	durable=True,		# 持久化
	exclusive=False,	# 当前connection退出后销毁
	auto_delete=False,	# 消费者断连后销毁
	arguments=argument)	

```
> [!Note|label:`exclusive`和`auto_delete`的区别]
> `exclusive`是声明队列connection断开就会销毁，`auto_delete`类似，所有消费者的connection都断开就会销毁，如果队列从没有过消费者，则不会销毁

队列声明的可选参数(`x-arguments`)，常用的有:
* x-message-ttl: 消息失效时间，单位ms
* x-max-length: 队列最大长度
* x-dead-letter-exchange: 死信交换机
* x-dead-letter-routing-key: 死信`routing key`


### 交换机参数
exchange_declare也有一个arguments拓展参数，但是一般没有用到。


### binding参数
```python
# arguments是一个字典
arguments = {
	'x-match': 'any',
	'key1': 'value1',
	'key2': 'value2',
}

channel.queue_bind(queue='queue_name', exchange='ex', arguments=arguments)
```
binding的参数也不会很常用，一般只有headers交换机的binding需要用到:
* x-match: 指定`any`或者`all`
* 其他自定义键值对


### 消息属性
```python
# properties声明
properties = pika.BasicProperties(
	content_type='application/json',
	content_encoding=None, 
	headers=None, 
	delivery_mode=2,		 
	priority=None, 
	correlation_id=None, 
	reply_to=None, 
	expiration=str(60*1000), 
	message_id=None, 
	timestamp=None, 
	type=None, 
	user_id=None, 
	app_id=None, 
	cluster_id=None
)

# 消息属性的使用方式
channel.basic_publish(exchange='',
                      routing_key='',
                      body='message',
                      properties=properties)

```

AMQP规定了14种消息属性，常用的有：
* delivery_mode: `2`表示消息持久化，其他表示非持久化
* content_type: 消息类型(mime-type)，通常json用的`application/json`
* reply_to: 用于指定回调队列名
* correlation_id: 请求唯一值
* headers: 消息Headers内容
* expiration: 消息时效，单位为ms


## Examples

### 异步生产者
https://github.com/pika/pika/blob/master/examples/asynchronous_publisher_example.py

### 异步消费者
https://github.com/pika/pika/blob/master/examples/asynchronous_consumer_example.py


