# dockerfile最佳实践
官方文档：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

> [!Note]
> `Dockerfile`是一个文本文件，其内包含了一条条的指令(Instruction)，每一条指令构建一层，因此每一条指令的内容，就是描述该层应当如何构建。

## 一般性的指南和建议
### 容器应该是短暂的
通过`Dockerfile`构建的镜像所启动的容器应该尽可能短暂（生命周期短）。`短暂`意味 着可以停止和销毁容器，并且创建一个新容器并部署好所需的设置和配置工作量应该是极小的。			
设计原理参照[12-factor原则](../methodology/12-factor.md)

### 理解构建上下文
构建时包含构建镜像不需要的文件会导致更大的构建上下文和更大的镜像。这会增加构建镜像的时间、pull和push镜像的时间以及容器运行时的大小。
> [!Note]
> 构建时注意指定context目录（通常为`.`）和使用`.dockerignore`文件

### 借助stdin管道传输dockerfile
利用类似以下的方式构建镜像，无需生成dockerfile文件，适用于一次性且不需要context的镜像
```bash
echo -e 'FROM busybox\nRUN echo "hello world"' | docker build -
```

### 使用`.dockerignore`文件
用法和作用参照Git中的`.gitignore`，语法也和`.gitignore`相似

### 使用多阶段构建
Docker在17.05以上版本支持多阶段构建，参照[docker多阶段构建](./multi_stage.md)

### 避免安装不必要的包
为了降低复杂性、减少依赖、减小文件大小、节约构建时间，应该避免安装任何不必要的包。

### 一个容器只运行一个进程
应该保证在一个容器中只运行一个进程。将多个应用解耦到不同容器中，保证了容器的横向 扩展和复用。例如web应用应该包含三个容器：web应用、数据库、缓存。 如果容器互相依赖，可以使用`network`或者`docker-compose`来把这些容器连接起来

### 镜像层数尽可能少
需要在`Dockerfile`可读性（也包括长期的可维护性）和减少层数之间做一个平衡。

### 将多行参数排序
将多行参数按字母顺序排序（比如要安装多个包时）。可以避免重复包含同一个 包，更新包列表时也更容易。也便于PRs阅读和审查。(建议在反斜杠符号`\`之前添加一个 空格，以增加可读性。)			 
下面是来自`buildpack-deps`镜像的例子： 
```dockerfile
RUN apt-get update && apt-get install -y \
  bzr \
  cvs \
  git \
  mercurial \
  subversion \
  && rm -rf /var/lib/apt/lists/*
```

### 利用构建缓存
在镜像的构建过程中，Docker会遍历`Dockerfile`文件中的指令，然后按顺序执行。在执行每条指令之前，Docker都会在缓存中查找是否已经存在可重用的镜像，如果有就使用现存的镜像，不再重复创建。

> [!Note]
> 可以在`docker build`命令中使用`--no-cache=true`选项来禁止使用缓存。

使用缓存的场景：
* 从一个基础镜像开始（ FROM 指令指定），下一条指令将和该基础镜像的所有子镜像进行匹配，检查这些子镜像被创建时使用的指令是否和被检查的指令完全一样。如果不是，则缓存失效。
* 在大多数情况下，只需要简单地对比`Dockerfile`中的指令和子镜像。(部分指令需要更多的检查和解释) 
* 对于`ADD`和`COPY`指令，镜像中对应文件的内容也会被检查，每个文件都会计算出一个校验和(最后修改时间和最后访问时间不会纳入校验)。在缓存的查找过程中，会将这些校验和和已存在镜像中的文件校验和进行对比。如果文件有任何改变，则缓存失效。 
* 除了`ADD`和`COPY`指令，缓存匹配过程不会查看临时容器中的文件来决定缓存是否匹配。例如，当执行完`RUN apt-get -y update`指令后，容器中一些文件被更新，但Docker不会检查这些文件。这种情况下，只有指令字符串本身被用来匹配缓存。

一旦缓存失效，所有后续的`Dockerfile`指令都将产生新的镜像，缓存不会被使用。


## dockerfile指令
参照：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#dockerfile-instructions

### FROM
* 尽可能使用官方镜像
* 推荐alpine镜像，小且完整


### RUN
* 利用`|`和`&&`尽可能将一个操作放在同一层
* 利用`\`分隔，将长或复杂的RUN语句拆分成多行，增加可读性

RUN指令最常见的用法是安装包用的`apt-get`因为`RUN apt-get`指令会安装包，所以有几个问题需要注意：
* 避免使用`RUN apt-get upgrade`或`dist-upgrade`，因为许多基础镜像中的「必须」包不会在一个非特权容器中升级。
* 永远将`apt-get update`和`apt-get install`放在同一条RUN指令中，防止缓存的影响
* 清理掉apt缓存`var/lib/apt/lists`可以减小镜像大小

所有apt最佳实践的示例：
```dockerfile
RUN apt-get update && apt-get install -y \
    aufs-tools \
    automake \
    build-essential \
    curl \
    dpkg-sig \
    libcap-dev \
    libsqlite3-dev \
    mercurial \
    reprepro \
    ruby1.9.1 \
    ruby1.9.1-dev \
    s3cmd=1.1.* \
 && rm -rf /var/lib/apt/lists/*
```

> [!Note]
> 官方的`Debian`和`Ubuntu`镜像会自动运行`apt-get clean`，所以不需要显式的调用`apt-get clean`


### COPY和ADD
虽然ADD和COPY功能类似，但一般优先使用COPY。因为它比ADD更透明。COPY只支持简单将本地文件拷贝到容器中，而ADD有一些并不明显的功能（比如本地tar提取和远程URL支持）。因此，ADD的最佳用例是将本地tar文件自动提取到镜像中，例如`ADD rootfs.tar.xz`。 					

如果Dockerfile有多个步骤需要使用上下文中不同的文件。单独COPY每个文件，而不是一次性的COPY所有文件，这将保证每个步骤的构建缓存只在特定的文件变化时失效。


### CMD
Docker不是虚拟机，容器就是进程。既然是进程，那么在启动容器的时候，需要指定所运行的程序及参数。CMD指令就是用于指定默认的容器主进程的启动命令的。

CMD指令分为shell和exec两个格式：
如果使用shell格式的话，实际的命令会被包装为`sh -c`的参数的形式进行执行。比如：
```bash
CMD echo $HOME
```
在实际执行中，会将其变更为对应的exec格式：
```bash
CMD [ "sh", "-c", "echo $HOME" ]
```
[dockerfile最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#cmd)推荐直接使用exec格式，并且尽量避免CMD和ENTRYPOINT联用


### ENTRYPOINT
* ENTRYPOINT的格式和RUN指令格式一样，分为exec格式和shell格式。
* ENTRYPOINT的目的和CMD一样，都是在指定容器启动程序及参数。
* ENTRYPOINT在运行时也可以替代，不过比CMD要略显繁琐，需要通过`docker run`的参数`--entrypoint`来指定。

当指定了ENTRYPOINT后，CMD的含义就发生了改变，不再是直接的运行其命令，而是将CMD的内容作为参数传给ENTRYPOINT指令，等效于：
```bash
<ENTRYPOINT> "<CMD>"
```

**ENTRYPOINT存在的意义/ENTRYPOINT的使用场景**
* 让镜像变成像命令一样使用
* 应用运行前的准备工作（比如一些数据库的migrate工作）
这也是[dockerfile最佳实现](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#entrypoint)中推荐的两种用法


### EXPOSE
使用`EXPOSE`声明容器需要暴露的端口，使直接访问容器的对应端口能访问到（非宿主机端口）

> [!Note]
> 要将`EXPOSE`和在运行时使用`-p <宿主端口>:<容器端口>`区分开来。 `-p`是映射宿主端口和容器端口，将容器的对应端口服务公开给外界访问，而`EXPOSE`仅仅是声明容器打算使用什么端口而已，并不会自动在宿主进行端口映射


### VOLUME
VOLUME指令用于暴露任何数据库存储文件，配置文件，或容器创建的文件和目录。强烈建议使用VOLUME来管理镜像中的可变部分和用户可以改变的部分。


### ENV
用ENV指定一些版本号之类的常量，方便仅修改ENV来自动替换容器中的软件版本


### USER
建议使用非root用户执行
> [!Note]
> 在镜像中，用户和用户组每次被分配的`UID/GID`都是不确定的，下次重新构建镜像时被分配到的`UID/GID`可能会不一样。如果要依赖确定的`UID/GID`，则必须显式指定。


### WORKDIR
* WORKDIR应该永远使用绝对路径
* 用WORKDIR替代一切`cd`指令


### ONBUILD
ONBUILD是一个特殊的指令，它后面跟的是其它指令，比如RUN, COPY等，而这些指令，在当前镜像构建时并不会被执行。只有当以当前镜像为基础镜像，去构建下一级镜像的时候才会被执行。

Dockerfile中的其它指令都是为了定制当前镜像而准备的，唯有ONBUILD是为了帮助别人定制自己而准备的。
ONBUILD会在dockerfile构建出来的镜像被其他镜像引用时执行，优先于子镜像的执行顺序

示例：
```bash
# 构建onbuild镜像
onbuild$ cat Dockerfile
FROM nginx

ONBUILD RUN echo abc > /a.txt

onbuild$ docker build -t web:v1-onbuild .
Sending build context to Docker daemon  2.048kB
Step 1/2 : FROM nginx
 ---> 2622e6cca7eb
Step 2/2 : ONBUILD RUN echo abc > /a.txt
 ---> Running in 6d883cf2fe57
Removing intermediate container 6d883cf2fe57
 ---> 1d66713a5ff6
Successfully built 1d66713a5ff6
Successfully tagged web:v1-onbuild

# ONBUILD在onbuild镜像构建中不执行
onbuild$ docker run -it web:v1-onbuild bash -c "ls /"
bin   docker-entrypoint.d   home   media  proc	sbin  tmp
boot  docker-entrypoint.sh  lib    mnt	  root	srv   usr
dev   etc		    lib64  opt	  run	sys   var

# 构建子镜像
onbuild$ cat Dockerfile2
FROM web:v1-onbuild

RUN cat /a.txt

onbuild$ docker build -f Dockerfile2 -t web:v1 .
Sending build context to Docker daemon  3.072kB
Step 1/2 : FROM web:v1-onbuild
# Executing 1 build trigger
 ---> Running in 6b8a11d26434
Removing intermediate container 6b8a11d26434
 ---> 7c38d19d6c99
Step 2/2 : RUN cat /a.txt
 ---> Running in 35289da980b7
abc
Removing intermediate container 35289da980b7
 ---> 1f26af01e400
Successfully built 1f26af01e400
Successfully tagged web:v1

# 子镜像中有/a.txt文件
onbuild$ docker run -it web:v1 bash -c "ls /"
a.txt  dev		     etc   lib64  opt	run   sys  var
bin    docker-entrypoint.d   home  media  proc	sbin  tmp
boot   docker-entrypoint.sh  lib   mnt	  root	srv   usr

```


## 参考
* 官方仓库的dockerfile示例：https://github.com/docker-library/docs
