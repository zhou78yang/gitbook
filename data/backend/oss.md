# 阿里云OSS

阿里云对象存储OSS（Object Storage Service）是一款海量、安全、低成本、高可靠的云存储服务。多种存储类型供选择，全面优化存储成本。
OSS具有与平台无关的RESTful API接口，开发者可以在任何应用、任何时间、任何地点存储和访问任意类型的数据。


## 命令行工具ossutil
ossutil官方提供的命令行工具，支持通过Windows、Linux和macOS系统以命令行方式管理OSS数据。

### 安装
详细安装和初始化配置教程: https://help.aliyun.com/document_detail/120075.html

```shell
$ wget http://gosspublic.alicdn.com/ossutil/1.7.8/ossutil64
$ chmod 755 ossutil64

# 初始化配置
$ ./ossutil64 config
```

### 常用指令
详细的使用教程: https://help.aliyun.com/document_detail/120050.html
```shell
# 获取帮助的手段
$ ossutil64 help

# 查看bucket列表
$ ossutil64 ls
CreationTime                                 Region    StorageClass    BucketName
2022-01-01 16:28:27 +0800 CST       oss-cn-shenzhen        Standard    oss://bucket2
2021-01-18 17:05:16 +0800 CST       oss-cn-shanghai        Standard    oss://bucket1
Bucket Number is: 2

# 查看文件列表
$ ossutil64 ls oss://bucket2/dir/
LastModifiedTime                   Size(B)  StorageClass   ETAG                                  ObjectName
2022-01-25 16:23:44 +0800 CST      7104618      Standard   BB0D1BC4047B4C1F0A6EAA7E8C2CFC51      oss://bucket2/dir/b.txt
2022-01-25 16:29:19 +0800 CST      7596473      Standard   96E0B966BAD6D94352570799E61F17A6      oss://bucket2/dir/a.txt
Object Number is: 2

# 上传单个文件到oss
$ ossutil64 cp ./test.txt oss://bucket2/path/to/your/file/test.txt

# 批量上传到oss(当前文件夹会拷贝成your_dir)
$ ossutil64 cp -r ./ oss://bucket2/your_dir
Succeed: Total num: 1295, size: 3,159,733,912. OK num: 1295(upload 1289 files, 6 directories).  
average speed 5145000(byte/s)

# 删除单个文件(对象)
$ ossutil64 rm oss://bucket2/a.txt
Succeed: Total 1 objects. Removed 1 objects.       

# 批量删除文件(对象)
$ ossutil64 rm -r oss://bucket2/your_dir

```


## 挂载工具ossfs
ossfs能让您在Linux系统中，将对象存储OSS的存储空间（Bucket）挂载到本地文件系统中，您能够像操作本地文件一样操作OSS的对象（Object），实现数据的共享。

> ossfs基于fuse用户态文件系统开发，只能运行在支持fuse的机器上。OSS提供了Ubuntu和CentOS系统的安装包，如果需要在其它环境下运行，可以通过源码方式构建目标程序。
> ossfs支持在阿里云内网以及互联网环境下使用。在内网环境下时，建议使用内网访问域名，以提升访问速度和稳定性。

### 安装
详细安装和初始化配置教程: https://help.aliyun.com/document_detail/153892.html

**Ubuntu 16.04 LTS环境下**
```shell
# 1. 下载安装包
$ wget http://gosspublic.alicdn.com/ossfs/ossfs_1.80.6_ubuntu16.04_amd64.deb

# 2. 安装文件
$ sudo apt-get update
$ sudo apt-get install gdebi-core
$ sudo gdebi ossfs_1.80.6_ubuntu16.04_amd64.deb

# 3. 配置账号信息
$ echo BucketName:yourAccessKeyId:yourAccessKeySecret > /etc/passwd-ossfs
$ chmod 640 /etc/passwd-ossfs

```

### 使用
```shell
# 挂载bucket到指定的folder
$ ossfs BucketName mountfolder -o url=Endpoint

# 卸载bucket
$ fusermount -u mountfolder

```
*注：默认情况下，只有root用户能访问挂载的目录，允许所有用户访问可以使用`-oallow_other`选项或者指定`-ouid`*

### 基于supervisor实现开机自动挂载

`start_oss.sh`脚本内容
```shell
# 卸载
fusermount -u /mnt/ossfs
# 重新挂载，必须要增加-f参数运行ossfs，让ossfs在前台运行。
exec ossfs bucket_name mount_point -ourl=endpoint -f
```

supervisor配置
```ini
[program:ossfs]
command=bash /root/ossfs_scripts/start_ossfs.sh
logfile=/var/log/ossfs.log
log_stdout=true
log_stderr=true
logfile_maxbytes=1MB
logfile_backups=10
```


## 资料
* [快速入门](https://help.aliyun.com/document_detail/31883.html)
* [开发指南](https://help.aliyun.com/document_detail/31890.html)
* [Python SDK](https://help.aliyun.com/document_detail/32026.html)
* [Python oss2 API文档](https://aliyun-oss-python-sdk.readthedocs.io/en/latest/api.html)
* [最佳实践](https://help.aliyun.com/document_detail/131103.html)