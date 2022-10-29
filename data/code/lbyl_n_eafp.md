# LBYL和EAFP两种防御性编程风格

## 名词解释
* LBYL(Look Before You Leap): 程序执行之前先检查。
* EAFP(Easier to Ask for Forgiveness than Permission): 获得事后原谅比事先得到许可要容易得多。指先假定程序正常执行，出了问题再处理异常

## 对应代码逻辑
```python
# LBYL
if allow_to_do:
	do_something()
else:
	do_when_no_permission()


# EAFP
try:
	do_something()
except:
	do_when_no_permission()

```

很多情况下，两种方式的写法是可以互相替换的，但是[Python中鼓励使用EAFP](https://docs.python.org/3/glossary.html#term-eafp)。原因是这种方法的可读性更高，速度也更快（只有在出错的时候才需要处理，而LBYL需要每次运行都检查）。


## 比较

* 对于LBYL，容易打乱思维，本来业务逻辑用一行代码就可以搞定的。却多出来了很多行用于检查的代码。防御性的代码跟业务逻辑混在一块降低了可读性。
* 对于EAFP，业务逻辑代码跟防御代码隔离的比较清晰，更容易让开发者专注于业务逻辑。
* 异常处理会影响一点性能。因为在发生异常的时候，需要进行保留现场、回溯traceback等操作。(但其实性能相差不大，尤其是异常发生的频率比较低的时候)。

> [!Note|label:建议]
> 如果涉及到原子操作，强烈推荐用EAFP风格，尤其是多线程/多进程并发情况下。
> 比如一个Redis并发锁的逻辑，如果我们在获取锁之前先去检查Redis中的key是否存在，不存在才setnx写入，在并发情况下，其他进程可能也进行了相同操作，提前写入了key，导致写入失败程序异常。
> 而用EAFP风格则可以确保原子性，先假定setnx成功，不成功才返回获取锁失败。