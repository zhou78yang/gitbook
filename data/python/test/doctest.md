# doctest

官方文档: https://docs.python.org/zh-cn/3.7/library/doctest.html 					

> `doctest`模块寻找像Python交互式代码的文本，然后执行这些代码来确保它们的确就像展示的那样正确运行

## 使用

在代码中添加python交互式代码及其结果的注释，实现简单的单元测试

### 示例代码: 获取区间内所有日期
```python
# get_date.py
import datetime


def get_datelist(begin, end):
    """
        传入字符串
        >>> get_datelist('2021-01-01', '2021-01-05')
        ['2021-01-01', '2021-01-02', '2021-01-03', '2021-01-04', '2021-01-05']

        传入date对象
        >>> get_datelist(datetime.date.fromisoformat('2021-02-01'), 
        ...              datetime.date.fromisoformat('2021-02-07'))
        ['2021-02-01', '2021-02-02', '2021-02-03', '2021-02-04', '2021-02-05', '2021-02-06', '2021-02-07']
    """
    if isinstance(begin, str):
        begin = datetime.date.fromisoformat(begin)
    if isinstance(end, str):
        end = datetime.date.fromisoformat(end)

    if end < begin:
        begin, end = end, begin
    days = (end - begin).days
    date_list = [begin + datetime.timedelta(days=d) for d in range(days+1)]

    return [str(d) for d in date_list]
```


### 通过__main__测试
```python
if __name__ == '__main__':
    import doctest
    doctest.testmod()
```
> [!Note]
> 默认情况下，doctest只会输出报错的测试用例，全部通过则没有输出

如果要显示所有测试结果，`testmod()`需要添加`verbose`参数
```python
if __name__ == '__main__':
    import doctest
    doctest.testmod(verbose=True)
```
或者命令行使用`-v`选项
```bash
$ python3 get_date.py -v
```


### 通过命令行测试
```bash
$ python3 -m doctest -v get_date.py
Trying:
    get_datelist('2021-01-01', '2021-01-05')
Expecting:
    ['2021-01-01', '2021-01-02', '2021-01-03', '2021-01-04', '2021-01-05']
ok
Trying:
    get_datelist(datetime.date.fromisoformat('2021-02-01'), 
                 datetime.date.fromisoformat('2021-02-07'))
Expecting:
    ['2021-02-01', '2021-02-02', '2021-02-03', '2021-02-04', '2021-02-05', '2021-02-06', '2021-02-07']
ok
1 items had no tests:
    get_date
1 items passed all tests:
   2 tests in get_date.get_datelist
2 tests in 2 items.
2 passed and 0 failed.
Test passed.

```
`doctest -v`可以显示测试详情



## 结合框架

### django
```python
if __name__ == '__main__':
    import os
    import django
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'app.settings')
    django.setup()

    import doctest
    doctest.testmod()
```

### flask
```python
if __name__ == '__main__':
	import doctest
    from app import create_app
    app = create_app('dev', False)

    with app.app_context():
        doctest.testmod()

```


## 更多

### 省略长文本
```python
def div(a, b):
    """
    >>> div(1, 0)
    Traceback (most recent call last):
        ...
    ZeroDivisionError: division by zero
    """
    return a/b
```
Traceback中包含很多和文件位置相关的内容，这部分可以通过`...`省略


### 结果为dict/set时
> [!Warning]
> 在python3.6之前，当打印dict时，Python不能保证以任何特定的顺序打印键值对。

使用
```python
>>> foo()
{"Hermione", "Harry"}
```
可能会出错，应该使用下列格式
```python
>>> foo() == {"Hermione", "Harry"}
True
```


### 只测试指定的内容

> 利用`doctest.run_docstring_examples`测试指定某个模块，类，方法

参考: https://docs.python.org/3/library/doctest.html#doctest.run_docstring_examples 

```python
# my_test.py
class A:
    """
        >>> A().run()
        'this is A'
    """
    label = 'this is A'
    def run(self):
        """
            >>> A().run()   # test in run
            'this is A'
        """
        return self.label


class B(A):
    """
        >>> B().run()
        'this is B'
    """
    label = 'this is B'


def test():
    """
        >>> test()  # test in test()
        'this is A'
    """
    return A().run()


if __name__ == '__main__':
    import doctest
    doctest.run_docstring_examples(A, globals(), verbose=True)
    doctest.run_docstring_examples(A.run, globals(), verbose=True)
    doctest.run_docstring_examples(A, globals(), verbose=True, name='A.run')
    doctest.run_docstring_examples(B, globals(), verbose=True)
    doctest.run_docstring_examples(test, globals(), verbose=True)
```

输出结果：
```bash
$ python3 my_test.py 
Finding tests in NoName
Trying:
    A().run()
Expecting:
    'this is A'
ok
Finding tests in NoName
Trying:
    A().run()   # test in run
Expecting:
    'this is A'
ok
Finding tests in A.run
Trying:
    A().run()
Expecting:
    'this is A'
ok
Finding tests in NoName
Trying:
    B().run()
Expecting:
    'this is B'
ok
Finding tests in NoName
Trying:
    test()  # test in test()
Expecting:
    'this is A'
ok
```


