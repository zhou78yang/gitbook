# 服务器性能指标

衡量服务器的性能时，经常会涉及到几个指标，load、cpu、mem、qps、rt等。每个指标都有其独特的意义，很多时候在线上出现问题时，往往会伴随着某些指标的异常。

## 系统负载(load)
在UNIX系统中，系统负载是对当前CPU工作量的度量，被定义为特定时间间隔内运行队列中的平均线程数。`load average`表示机器一段时间内的平均load。这个值越低越好。负载过高会导致机器无法处理其他请求及操作，甚至导致死机。

Linux的负载高，主要是由于CPU使用、内存使用、IO消耗三部分构成。任意一项使用过多，都将导致服务器负载的急剧攀升。


查看系统负载的工具

### uptime

```bash
$ uptime
 19:47:26 up 25 days,  6:16,  1 user,  load average: 0.12, 0.04, 0.01

```
以上分别表示1分钟、5分钟、15分钟内系统的平均负荷。我们一般表示为load1、load5、load15


### w

```bash
$ w
 19:47:27 up 25 days,  6:16,  1 user,  load average: 0.12, 0.04, 0.01
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    116.30.5.115     19:46    7.00s  0.06s  0.00s w

```
第一行和uptime一致。之后为一个表格，分别是：用户，tty，ip，登录时间，空闲时间，JCPU， PCPU， 正在运行的进程

* JCPU: 该tty所有进程的cpu占用时间
* PCPU: 该tty当前进程的cpu占用时间


### top
```bash
top - 19:49:21 up 25 days,  6:18,  1 user,  load average: 0.88, 0.28, 0.09
Tasks: 134 total,   1 running, 133 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   7692.9 total,    473.5 free,   2686.1 used,   4533.4 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   4743.1 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                                    
      1 root      20   0  170588  12152   7688 S   0.0   0.2  21:51.12 systemd  
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.56 kthreadd  
      3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp 
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp  
```
