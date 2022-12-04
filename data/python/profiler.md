# Profile工具

## profile工具是什么
profile工具一般用于收集程序的运行信息（如函数的调用信息、指令信息等），可以用来分析、找出程序的瓶颈或错误。
主要实现方式有两种
* 
* 

### 

## py-spy
文档地址: https://github.com/benfred/py-spy

`py-spy`是一个Python程序的profiler，它的开销很低：py-spy使用Rust编写，所以速度会更快，并且和python程序不在一个进程中，因此可以用来分析生产环境进程。

### 使用
生成火焰图
```bash
py-spy record -o profile.svg --pid 12345
# OR
py-spy record -o profile.svg -- python myprogram.py
```

实时监控函数耗时情况，类似top
```bash
py-spy top --pid 12345
# OR
py-spy top -- python myprogram.py
```

显示当前的调用栈
```bash
py-spy dump --pid 12345
```

## profile
