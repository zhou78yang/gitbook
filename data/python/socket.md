# Python网络编程

> Socket是网络编程的一个概念。通常我们用一个Socket表示“打开了一个网络链接”，而打开一个Socket需要知道目标计算机的IP地址和端口号，再协议类型即可。

## TCP编程

### 客户端

大多数连接都是可靠的TCP连接。创建TCP连接时，主动发起连接的叫客户端，被动响应连接的叫服务器。

> 举个例子，当我们在浏览器中访问新浪时，我们自己的计算机就是客户端，浏览器会主动向新浪的服务器发起连接。如果一切顺利，新浪的服务器接受了我们的连接，一个TCP连接就建立起来的，后面的通信就是发送网页内容了。

最简单的连接例子：
```python
# 导入socket库:
import socket

# 创建一个socket:
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 建立连接:
s.connect(('www.sina.com.cn', 80))
```

访问网页的示例：
```python
import socket

# 创建socket，建立连接
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('www.baidu.com', 80))

# 发送请求
# HTTP请求格式：{METHOD} {PATH} {PROTOCOL}\n{HOST}\n{OTHER}...\n\n
s.send(b'GET / HTTP/1.1\nHost: www.baidu.com\nConnection: close\n\n')

# 接收数据
buffer = []
while True:
    d = s.recv(1024)    # 每次接收max字节的数据
    if d:
        buffer.append(d)
    else:
        break
data = b''.join(buffer)

# 关闭连接
s.close()

info = data.split(b'\r\n\r\n', 1)
header = info[0]
html = info[1]
print(header.decode('utf8'))
with open('test.html', 'wb') as f:
    f.write(html)
```

### 服务器

和客户端编程相比，服务器编程就要复杂一些。     
服务器进程首先要绑定一个端口并监听来自其他客户端的连接。如果某个客户端连接过来了，服务器就与该客户端建立Socket连接，随后的通信就靠这个Socket连接了。          
所以，服务器会打开固定端口（比如80）监听，每来一个客户端连接，就创建该Socket连接。由于服务器会有大量来自客户端的连接，所以，服务器要能够区分一个Socket连接是和哪个客户端绑定的。一个Socket依赖4项：*服务器地址、服务器端口、客户端地址、客户端端口*来唯一确定一个Socket。
但是服务器还需要同时响应多个客户端的请求，所以，每个连接都需要一个新的进程或者新的线程来处理，否则，服务器一次就只能服务一个客户端了。

简单Server示例:
```python
import socket
import threading

def tcplink(sock, addr):
    print('Accept new connection from {}...'.format(addr))
    sock.send(b'Welcome!')
    while True:
        data = sock.recv(1024)
        if not data or data.decode('utf8') == 'exit':
            break
        sock.send(('Hello, %s!' % data.decode('utf8')).encode('utf8'))
    sock.close()
    print('Connection from {} closed'.format(addr))

# 创建socket，监听本地端口
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('127.0.0.1', 13145))
s.listen(5)     # 开始监听，传入参数指定等待连接的最大数量
print('Waiting for connection...')

while True:
    # 接受一个新连接
    sock, addr = s.accept()
    t = threading.Thread(target=tcplink, args=(sock, addr))
    t.start()
```
Client:
```python
import socket
import time

# 创建socket，建立连接
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('127.0.0.1', 13145))

# 接收欢迎信息
print(s.recv(1024).decode('utf8'))
# 发送请求
for data in [b'zhangsan', b'lisi', b'wangwu', b'zhaoliu']:
    s.send(data)
    time.sleep(1)
    print(s.recv(1024).decode('utf8'))
s.send(b'exit')

# 关闭连接
s.close()
```

### 小结
用TCP协议进行Socket编程在Python中十分简单，对于客户端，要主动连接服务器的IP和指定端口，对于服务器，要首先监听指定端口，然后，对每一个新的连接，创建一个线程或进程来处理。通常，服务器程序会无限运行下去。
同一个端口，被一个Socket绑定了以后，就不能被别的Socket绑定了。

## UDP编程

TCP是建立可靠连接，并且通信双方都可以以流的形式发送数据。相对TCP，UDP则是面向无连接的协议。
使用UDP协议时，不需要建立连接，只需要知道对方的IP地址和端口号，就可以直接发数据包。但是，能不能到达就不知道了。
虽然用UDP传输数据不可靠，但它的优点是和TCP比，速度快，对于不要求可靠到达的数据，就可以使用UDP协议。

Server(*实现回声功能，将接收到的信息反射回去*):
```python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
port = 13145
s.bind(('127.0.0.1', port))
print('Bind UDP on {}'.format(port))
while True:
    data, addr = s.recvfrom(1024)
    print('Received from %s:%s.' % addr)
    s.sendto(b'Echo: %s!' % data, addr)
```
创建Socket时，SOCK_DGRAM指定了这个Socket的类型是UDP。绑定端口和TCP一样，但是不需要调用listen()方法，而是直接接收来自任何客户端的数据

Client:
```python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
while True:
    data = input()
    s.sendto(bytes(data, 'utf8'), ('127.0.0.1', 13145))
    print(s.recv(1024).decode('utf8'))
    if data == 'exit':
        break
s.close()
```

### 小结

UDP的使用与TCP类似，但是不需要建立连接。此外，服务器绑定UDP端口和TCP端口互不冲突，也就是说，UDP的9999端口与TCP的9999端口可以各自绑定。

## 相关链接
https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/001432004977916a212e2168e21449981ad65cd16e71201000 
