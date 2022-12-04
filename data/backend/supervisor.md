# supervisor

`supervisor`是一个基于C/S结构的进程管理工具。它通过以子进程的方式运行用户进程来监控和管理这些进程

<b>组成</b>
* supervisord： supervisor的服务器，它负责启动子程序，响应来自客户端的命令，重新启动崩溃或退出的子进程，记录其子进程stdout和stderr输出，并生成和处理与子进程生命周期中的点对应的“event”。
* supervisorctl: 客户端，supervisor运行时的cli工具，可以用来控制和查看子进程状态等

## supervisor配置
`supervisord`主要是通过ini配置文件，通常位于`/etc/supervisord.conf`或`/etc/supervisor/supervisord.conf`(since Supervisor 3.3.0)，其中包含`include`段来引用下层配置
```ini
[include]
files = /etc/supervisor/conf.d/*.conf
```

应用配置示例
```ini
[program:ssserver]
command = /usr/local/bin/ssserver -p 8008 -k 123456 -m aes-256-cfb start
#日志输出
stderr_logfile = /var/log/supervisor/%(program_name)s_%(process_num)02d_stderr.log
stdout_logfile = /var/log/supervisor/%(program_name)s_%(process_num)02d_stdout.log
stdout_logfile_maxbytes = 10485760
stderr_logfile_maxbytes = 10485760
stdout_logfile_backups = 3
stderr_logfile_backups = 3
```

## supervisorctl
supervisorctl cli界面
```bash
> status	# 查看程序状态
> stop program_name		# 关闭程序 
> start program_name	# 启动程序 
> restart program_name	# 重启程序(不会reread配置文件)
> reread	# 读取有更新（增加）的配置文件，但不会重启或者启动进程
> reload	# 载入最新的配置文件，停止原有的进程并按照新的配置启动
> update    # 重启配置文件修改过的程序，配置没有改动的进程不会收到影响而重启
```
上述指令也有等效的shell指令
```bash
$ supervisorctl status
$ supervisorctl stop program_name
$ supervisorctl start program_name
$ supervisorctl restart program_name
$ supervisorctl reread
$ supervisorctl reload
$ supervisorctl update
```

## supervisor日志按日期分割
当前版本（3.3.1）尚不支持按照日期进行日志分割。由于我们日志需要推送到es，其他的日志分割方式会导致推送有问题，所以采用以下方式将日志文件按照日期分割

1. 指定程序日志输出到`here`（配置文件所在目录）目录下
2. 启动前将配置文件拷贝的需要的日期目录下

配置文件
```ini
[program:app]
#日志输出
stderr_logfile = %(here)s/%(program_name)s_%(process_num)02d_stderr.log
stdout_logfile = %(here)s/%(program_name)s_%(process_num)02d_stdout.log
```
容器启动的entrypoint.sh
```bash
#!/bin/bash

BASE_LOG_DIR=/logs
LOG_DIR=/logs/$(date '+%Y-%m-%d')

# 日志文件目录不存在时创建
if [ ! -d "$BASE_LOG_DIR" ]; then
    echo "mkdir $BASE_LOG_DIR"
    mkdir "$BASE_LOG_DIR"
fi
if [ ! -d "$LOG_DIR" ]; then
    echo "mkdir $LOG_DIR"
    mkdir "$LOG_DIR"
fi

# 需要将配置文件拷贝到日志文件下，使log配置中的here生效，将子进程日志记录到LOG_DIR下
CONF_PATH=$LOG_DIR/supervisord.conf
cp /conf/supervisord.conf "$CONF_PATH"

# 启动supervisord
supervisord -n -c "$CONF_PATH" -l "$LOG_DIR/supervisord.log"

```



## 参考
* [supervisor文档](http://supervisord.org/) 					
* [supervisor配置文档](http://supervisord.org/configuration.html) 		