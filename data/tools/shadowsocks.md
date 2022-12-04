# Shadowsocks

## 客户端

### Mac OS
下载地址: https://github.com/zhou78yang/ShadowsocksX-NG

### Ubuntu
##### 安装
```bash
# 安装shadowsocks
sudo pip3 install shadowsocks

# 安装privoxy
sudo apt install privoxy

```

##### privoxy参考
`/etc/privoxy`配置
```
listen-address  127.0.0.1:8118
listen-address  [::1]:8118
forward-socks5t / 127.0.0.1:1080 .

actonsfile gfwlist.action
```

`/etc/privoxy/gfwlist.action`配置
```
{+forward-override{forward-socks5 127.0.0.1:1080 .}}
.blogspot.
.google.
.twimg.edgesuite.net
.twitter.
.youtube.
```

`~/.bashrc`配置
```
export http_proxy=http://127.0.0.1:8118
export https_proxy=http://127.0.0.1:8118
```

##### sslocal配置
```json
{
    "server": "SERVER IP",
    "server_port": 2333,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password": "PASSWORD",
    "timeout": 300,
    "method": "aes-256-cfb",
    "fast_open": false,
    "workers": 1,
    "prefer_ipv6": false
}
```

##### sslocal启动
```bash
cd `dirname $0`

sslocal -c $PWD/config.json \
        -d start \
        --pid-file $PWD/sslocal.pid \
        --log-file $PWD/access.log

```

### Windows

* shadowsocks客户端：https://github.com/shadowsocks/shadowsocks-windows/releases


## 服务端
示例是通过supervisor监控ssserver进程运行服务的

### 安装
```bash
apt update && apt install python3-pip supervisor
pip3 install shadowsocks
```

### supervisor配置
/etc/supervisor/conf.d/ss.conf
```ini
[program:ssserver1]
command = /usr/local/bin/ssserver -p 2333 -k PASSWORD -m aes-256-cfb start
#日志输出
stderr_logfile = /var/log/supervisor/%(program_name)s_%(process_num)02d_stderr.log
stdout_logfile = /var/log/supervisor/%(program_name)s_%(process_num)02d_stdout.log
stdout_logfile_maxbytes = 10485760
stderr_logfile_maxbytes = 10485760
stdout_logfile_backups = 3
stderr_logfile_backups = 3

```

### shadowsocks包报错，需要手动改代码
```bash
2021-03-16 07:18:41 INFO     loading libcrypto from libcrypto.so.1.1
Traceback (most recent call last):
  File "/usr/local/bin/ssserver", line 8, in <module>
    sys.exit(main())
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/server.py", line 34, in main
    config = shell.get_config(False)
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/shell.py", line 262, in get_config
    check_config(config, is_local)
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/shell.py", line 124, in check_config
    encrypt.try_cipher(config['password'], config['method'])
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/encrypt.py", line 44, in try_cipher
    Encryptor(key, method)
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/encrypt.py", line 82, in __init__
    self.cipher = self.get_cipher(key, method, 1,
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/encrypt.py", line 109, in get_cipher
    return m[2](method, key, iv, op)
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/crypto/openssl.py", line 76, in __init__
    load_openssl()
  File "/usr/local/lib/python3.8/dist-packages/shadowsocks/crypto/openssl.py", line 52, in load_openssl
    libcrypto.EVP_CIPHER_CTX_cleanup.argtypes = (c_void_p,)
  File "/usr/lib/python3.8/ctypes/__init__.py", line 386, in __getattr__
    func = self.__getitem__(name)
  File "/usr/lib/python3.8/ctypes/__init__.py", line 391, in __getitem__
    func = self._FuncPtr((name_or_ordinal, self))
AttributeError: /lib/x86_64-linux-gnu/libcrypto.so.1.1: undefined symbol: EVP_CIPHER_CTX_cleanup
```
每台服务器可能不一致，看版本，如上报错就是要修改/usr/local/lib/python3.8/dist-packages/shadowsocks/server.py
将文件内所有的EVP_CIPHER_CTX_cleanup替换成EVP_CIPHER_CTX_reset

解决方案：
https://blog.csdn.net/youshaoduo/article/details/80745196

