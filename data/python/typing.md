# typing 类型标注

*python 3.5 新功能.*					
文档: https://docs.python.org/zh-cn/3.6/library/typing.html 			
最基本的支持由 Any，Union，Tuple，Callable，TypeVar 和 Generic 类型组成。

## 使用
函数接受并返回一个字符串，注释像下面这样:
```python
def greeting(name: str) -> str:
    return 'Hello ' + name
```
在函数`greeting`中，参数`name`预期是`str`类型，并且返回`str`类型。子类型允许作为参数。

## 类型别名
类型别名通过将类型分配给别名来定义。在这个例子中，`Vector`和`List[float]`将被视为可互换的同义词:
```python
from typing import List
Vector = List[float]

def scale(scalar: float, vector: Vector) -> Vector:
    return [scalar * num for num in vector]

# typechecks; a list of floats qualifies as a Vector.
new_vector = scale(2.0, [1.0, -4.2, 5.4])
```

## Any 类型
`Any`是一种特殊的类型。静态类型检查器将所有类型视为与`Any`兼容，反之亦然，`Any`也与所有类型相兼容。
