# GO Simple Tunnel
> GOST是GO语言实现的安全隧道

项目地址: https://github.com/ginuerzh/gost          
文档地址: https://docs.ginuerzh.xyz/gost/               

## 安装

### Ubuntu
```shell
sudo snap install core
sudo snap install gost
```

### Docker
```shell
docker pull ginuerzh/gost
```

### 二进制文件
https://github.com/ginuerzh/gost/releases


## 使用
### 快速开始
详见文档: https://docs.ginuerzh.xyz/gost/getting-started/


##### 开启代理服务
![开启代理服务](https://docs.ginuerzh.xyz/gost/img/001.png)
```shell
gost -L :8080
```

##### 开启多个代理服务
```shell
gost -L http2://:443 -L socks5://:1080 -L ss://aes-128-cfb:123456@:8338
```

##### 使用转发代理
![使用转发代理](https://docs.ginuerzh.xyz/gost/img/002.png)
```shell
gost -L :8080 -F 192.168.1.1:8081
```

##### 代理链
![代理链](https://docs.ginuerzh.xyz/gost/img/003.png)
```shell
gost -L=:8080 -F=quic://192.168.1.1:8081 -F=socks5+wss://192.168.1.2:8082 -F=http2://192.168.1.3:8083 ... -F=a.b.c.d:NNNN
```

##### shadowsocks示例
```shell
# ss服务端，使用ss协议，加密方法chacha20，密码123456，端口2333
gost -L ss://chacha20:123456@:2333

# ss客户端转http代理(默认http协议)
gost -L :8118 -F ss://chacha20:123456@<SERVER IP>:2333 

```


### 参数
`gost`参数
```
-L - 指定本地服务配置，可设置多个。
-F - 指定转发服务配置，可设置多个，构成转发链。
-C - 指定外部配置文件。
-D - 开启Debug模式，更详细的日志输出。
-V - 查看版本，显示当前运行的gost版本号。

```


### docker启动
镜像文档: https://hub.docker.com/r/ginuerzh/gost

*目前文档只是复制README，建议直接看Dockerfile*。`docker run`相当于直接启用一个`gost`进程

Dockerfile节选
```shell
FROM alpine:latest

WORKDIR /bin/

COPY --from=builder /src/cmd/gost/gost .

ENTRYPOINT ["/bin/gost"]
```


## 配置

### 示例
`gost`配置使用标准json格式配置
```json
{
    "Debug": true,
    "Retries": 0,
    "ServeNodes": [
        ":8080",
        "ss://chacha20:12345678@:8338"
    ],
    "ChainNodes": [
        "http://192.168.1.1:8080",
        "https://10.0.2.1:443"
    ],
    "Routes": [
        {
            "Retries": 1,
            "ServeNodes": [
                "ws://:1443"
            ],
            "ChainNodes": [
                "socks://:192.168.1.1:1080"
            ]
        },
        {
            "Retries": 3,
            "ServeNodes": [
                "quic://:443"
            ]
        }
    ]
}
```

格式说明
```
Debug - 对应命令行参数-D。(2.4+)
Retries - 通过代理链建立连接失败后的重试次数。(2.5+)
ServeNodes - 必须项，等同于命令行参数-L。
ChainNodes - 等同于命令行参数-F。
Routes - 可选参数，额外的服务列表，每一项都拥有独立的转发链。(2.5+)

```

### 外部配置文件
支持部分选项的外部配置文件

**ip**
详见 [负载均衡](https://docs.ginuerzh.xyz/gost/load-balancing/)

**bypass**
详见 [路由控制](https://docs.ginuerzh.xyz/gost/bypass/)

```
gost -L :8080?bypass=bypass.txt -F :1080?bypass=bypass2.txt
```
配置文件的格式为(地址列表和可选的配置项)：
```
# options
reload   10s
reverse  true

# bypass addresses
127.0.0.1
172.10.0.0/16
localhost
*.example.com
.example.org
```
reload - 此配置文件支持热更新。此选项用来指定文件检查周期，默认关闭热更新。
reverse - 指定是否切换为白名单。

*可以通过reverse=true取反，也可以通过`?bypass=~bypass.txt`取反*

注意，设置路由后不在bypass中的路由将无法到达，返回403异常
