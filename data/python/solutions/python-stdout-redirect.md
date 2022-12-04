# Python重定向输出到文件延迟问题

## 问题

示例脚本
```python
import time

def show():
    print('this is message')
    time.sleep(1)


if __name__ == '__main__':
    for i in range(1000):
        show()

```

形如下面直接用python执行脚本的情况：
```bash
$ python test.py >> output.log &

$ tail -f output.log
```
可能会遇到等半天都没看到输出的情况。原因是在python中，print的内容会先被存在缓冲区中暂存，缓存区的数据积累到一定的量的时候，才会将内容输出。

**stdout在遇到'\n'时会自动flush一次，重定向到文件则不会**

### 其他复现方式

* 将python指定的重定向语句写在shell脚本内
* 将python指令放到shell脚本中，对脚本输出重定向


```bash
# 将python指定的重定向语句写在shell脚本内
$ echo 'python test.py > output.log' > test.sh
$ sh test.sh

# 将python指令放到shell脚本中，对脚本输出重定向
$ echo 'python test.py' > test.sh
$ sh test.sh > output.log 

```


## 解决方案

1.print中显式指定flush参数
```python
print('this is msg', flush=True)
```

2.在需要flush时显式指定
```python
import sys

sys.stdout.flush()
```

3.python命令行添加-u参数(**通常使用这个**)
```bash
$ python -u test.py >> output.log
```