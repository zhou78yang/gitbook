# V2Ray

`V2Ray`是`Project V`下的一个工具。`Project V`是一个包含一系列构建特定网络环境工具的项目，而`V2Ray`属于最核心的一个。 官方中介绍`Project V`提供了单一的内核和多种界面操作方式。内核（V2Ray）用于实际的网络交互、路由等针对网络数据的处理，而外围的用户界面程序提供了方便直接的操作流程。不过从时间上来说，先有`V2Ray`才有`Project V`。 简单地说，`V2Ray`是一个与`Shadowsocks`类似的代理软件，可以用来科学上网（翻墙）学习国外先进科学技术。


## 安装

### Linux
最新的脚本地址: https://github.com/v2fly/fhs-install-v2ray/blob/master/README.zh-Hans-CN.md

```shell
# 安装和更新v2ray可执行文件，需要超级用户权限
# bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

### docker
官方提供镜像，可以直接使用或者基于官方镜像定制

```shell
docker run -d \
           --name v2ray \
           -p 1080:1080 \
           -v $PWD/config.json:/etc/v2ray/config.json \
           v2fly/v2fly-core
```


## 快速上手
文档: https://www.v2ray.com/chapter_00/start.html

服务端配置
```json
{
  "inbounds": [{
    "port": 10086, // 服务器监听端口，必须和上面的一样
    "protocol": "vmess",
    "settings": {
      "clients": [{ "id": "b831381d-6324-4d53-ad4f-8cda48b30811" }]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
```

客户端配置
```json
{
  "inbounds": [{
    "port": 1080,  // SOCKS 代理端口，在浏览器中需配置代理并指向这个端口
    "listen": "127.0.0.1",
    "protocol": "socks",
    "settings": {
      "udp": true
    }
  }],
  "outbounds": [{
    "protocol": "vmess",
    "settings": {
      "vnext": [{
        "address": "server", // 服务器地址，请修改为你自己的服务器 ip 或域名
        "port": 10086,  // 服务器端口
        "users": [{ "id": "b831381d-6324-4d53-ad4f-8cda48b30811" }]
      }]
    }
  },{
    "protocol": "freedom",
    "tag": "direct",
    "settings": {}
  }],
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules": [{
      "type": "field",
      "ip": ["geoip:private"],
      "outboundTag": "direct"
    }]
  }
}
```
*上述配置会把除了局域网（比如访问路由器）之外的所有流量转发到你的服务器。*


## 配置

### vTemplate
vTemplate一个`V2Ray`配置文件模板收集仓库，可以参考来定制自己的配置。          
项目地址： https://github.com/KiriKira/vTemplate


## 参考资料
* 官方网站: https://www.v2ray.com/
* 白话文教程: https://toutyrater.github.io/
* Linux安装脚本: https://github.com/v2fly/fhs-install-v2ray/blob/master/README.zh-Hans-CN.md
* vTemplate: https://github.com/KiriKira/vTemplate 