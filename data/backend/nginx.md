# Nginx配置

`nginx.conf`的默认配置通常有以下一段，
可以选择将http配置通常放在`/etc/nginx/sites-available`目录下，然后在`/etc/nginx/sites-enabled/`下使用`ln -s`链接配置文件；或者直接将配置文件放置在`/etc/nginx/conf.d`下

```ini
http {
	...

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```
> [!NOTE]
> 修改配置文件后，先使用`nginx -t`校验配置文件正确性，再reload配置


## http配置
以下为`/etc/nginx/sites-available`或`/etc/nginx/conf.d`目录下配置文件示例，即http模块内配置

### 简单配置
```nginx
server {
	listen          80;
	server_name     example.com;
	access_log      /var/log/access.log main;

	# 配置media访问本地文件
	location /media {
		alias /data/media;
	}

	# 最后配置/路由
	location / {
		index index.html;
		root  /var/www;
	}
}
```

### 负载均衡
文档地址：http://nginx.org/en/docs/http/ngx_http_upstream_module.html

```nginx
upstream backend {
    server backend1.example.com       weight=5;
    server backend2.example.com:8080;
    server unix:/tmp/backend3;

    server backup1.example.com:8080   backup;
    server backup2.example.com:8080   backup;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```

默认情况下，nginx按照权重轮询，即每7次请求中，将有5次请求到`backend1.example.com`， 第二和第三个server各一次请求。如果在与服务器通信期间发生错误，该请求将被传递到下一个服务器，依此类推，直到尝试所有正常运行的服务器为止。其它所有的非backup机器down或者繁忙的时候，请求backup机器。

<b>server的几个参数:</b>
* weight: 权重，默认为1，数值越大占比越多;
* max_fails: 最大失败次数，默认为1；
* max_conns: 并发最大连接数，默认为0，不限制;
* fail_timeout: timeout，默认10s
* backup: 标记为备用服务器（不能和hash，ip_hash和random这几种平衡方法一起使用）

<b>平衡方法:</b>
* ip_table: 针对ip地址进行哈希，分配到某一server上。该方法确保了来自同一客户端的请求将始终传递到同一server，即时这一台服务器不可用，也会稳定地请求到下一server。
* hash: 基于哈希分配server。键可以包含文本，变量及其组合。（注意，从组中添加或删除服务器可能会导致将大多数密钥重新映射到其他服务器）


### ssl证书
文档地址: http://nginx.org/en/docs/http/ngx_http_ssl_module.html
```nginx
server {
    ...

    ssl on;
    ssl_certificate     /etc/nginx/cert/registry/registry.crt;
    ssl_certificate_key /etc/nginx/cert/registry/registry.key;

    ssl_session_timeout 2m;     # 指定客户端可以重用会话参数的时间。
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;    # 支持的加密方式
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;    # 支持的协议
    ssl_prefer_server_ciphers on;   # 指定在使用SSLv3和TLS协议时，服务器密码应优先于客户端密码。

    ...
}
```


### 开启目录浏览
```nginx
	location /media {
        alias /data/media;
        autoindex on;               # 显示目录
        autoindex_exact_size on;    # 显示文件大小
        autoindex_localtime on;     # 显示文件时间
	}
```

### django-uwsgi-nginx配置
```nginx
# the upstream component nginx needs to connect to
upstream django {
    server unix:/home/app/conf/app.sock; # for a file socket
}

server {
    listen      80 default_server;

    server_name example.com;
    charset     utf-8;

    # max upload size
    client_max_body_size 75M;   		# body大小
    client_header_buffer_size 32K; 		# header大小
    proxy_buffer_size   32K;
    proxy_buffers   8 32K;
    proxy_busy_buffers_size 32K;
    # 文件缓存
    open_file_cache max=204800 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 1;

    # Django media
    location /media  {
        alias /data/media;
    }

    location /static {
        alias /data/static;
    }

    # Finally, send all non-media requests to the Django server.
    location / {
        uwsgi_pass  django;
        include     /conf/uwsgi_params; # the uwsgi_params file you installed
        uwsgi_connect_timeout 75;
        uwsgi_read_timeout 60;
        uwsgi_send_timeout 60;
    }
}
```


## stream配置
代理mysql示例
```nginx
stream {
    upstream db {
        server 127.0.0.1:3306;
    }

    server {
        listen 13306;#数据库服务器监听端口
        proxy_connect_timeout 10s;
        proxy_timeout 300s;#设置客户端和代理服务之间的超时时间，如果5分钟内没操作将自动断开。
        proxy_pass db;
    }
}
```


## 日志相关配置
日志格式配置相关文档：http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format                    
nginx变量说明文档: http://nginx.org/en/docs/varindex.html             

```nginx
    log_format mylog	'$remote_addr - $remote_user [$time_local] "$request" '
                    	'$status $body_bytes_sent "$http_referer" '
                    	'"$http_user_agent" "$http_x_forwarded_for" '
                    	'$request_time $upstream_response_time';

	access_log /dev/stdout main;	# access_log 日志路径 日志格式;
	error_log /dev/stderr;
```
<b>常用参数说明:</b>
* bytes_sent: 发送到客户端字节数
* connection: 连接序列号
* request_length: 请求长度，包括请求行，headers，body
* status: 响应状态，status_code
* time_local: 日志记录时间
* request_time: 请求处理时间，以秒为单位，精确到毫秒（从客户端读取第一个字节到将最后一个字节发送到客户端后的日志写入之间经过的时间）
* upstream_response_time: 从server接收响应所花费的时间，以秒为单位，精确到毫秒


## 认证
相关文档: http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html

ngx_http_auth_basic_module通过`HTTP Basic Authentication`认证，示例：
```nginx
server {
    auth_basic           "your site";       # 认证
    auth_basic_user_file conf.d/passwd;     # 认证文件

    location /media {
        auth_basic           off;           # 关闭认证
        alias /data/media;
    }

    location /static {
        auth_basic           "static auth"; # 覆盖上层认证
        auth_basic_user_file conf.d/passwd2;    
        alias /data/media;
    }
}
```
可以使用`htpasswd`或`openssl passwd`来加密密码，并将密文写入`conf.d/passwd`中
```bash
# 格式 user:password:comment
admin:FipxP14Sy8yNc
user:FipxP14Sy8yNc:普通用户
```


## 正向代理
代理（Proxy）其实就是客户端请求代理服务器，然后代理服务器去请求目标网站，再将响应返回给客户端。

```nginx
server {
	listen 1234;
	server_name _;
	location / {
		# 必须指定 resolver
		resolver 8.8.8.8;   
		proxy_pass $scheme://$host$request_uri;
	}
}
```


## 参考链接
* [nginx文档](http://nginx.org/en/docs/)              
* [nginx中文文档](https://www.nginx.cn/doc/)                
* [nginx变量索引](http://nginx.org/en/docs/varindex.html)           