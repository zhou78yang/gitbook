# dataclass

dataclasses是python 3.7引入的新特性，这个模块提供了一个类的装饰器和一些函数。

## 使用

```python
from dataclasses import dataclass

@dataclass
class InventoryItem:
    """Class for keeping track of an item in inventory."""
    name: str
    unit_price: float
    quantity_on_hand: int = 0

    def total_cost(self) -> float:
        return self.unit_price * self.quantity_on_hand
```
使用`dataclass`装饰器，则我们定义的类就是一个数据类，dataclass将会自动实现一些诸如`__init__`，`__repr__`之类的方法。

详细的使用参照：https://docs.python.org/zh-cn/3/library/dataclasses.html#module-level-decorators-classes-and-functions


## dataclass和普通class的区别
* 相比普通class，dataclass通常不包含私有属性，数据可以直接访问
* dataclass的repr方法通常有固定格式，会打印出类型名以及属性名和它的值
* dataclass拥有`__eq__`和`__hash__`魔法方法
* dataclass有着模式单一固定的构造方式，或是需要重载运算符，而普通class通常无需这些工作


## 实践示例

```python
from dataclasses import dataclass, fields, field, _MISSING_TYPE


@dataclass
class NotNullDataclass:
	# __post_init__是dataclass提供给初始化后处理的一个钩子方法，一般用来填充默认值
    def __post_init__(self):
        obj_fields = fields(self)
        for f in obj_fields:
            if not f.init:
            	continue
            default_value = f.default if not isinstance(f.default, _MISSING_TYPE) else f.default_factory()
            setattr(self, f.name, getattr(self, f.name) or default_value)


@dataclass
class TailwayFeeResult(NotNullDataclass):
    fee: float = 0.0            # 尾程运费
    weight: float = 0.0         # 计费重量
    handle_price: float = 0.0   # 处理费
    prescription: List[str] = field(default_factory=lambda: ['8', '15'])    # 时效
    error_msg: str = ''         # 错误信息
    formula: str = ''           # 计费公式
    order_formula: str = ''     # 返回给订单的计费公式


@dataclass
class HeadwayFeeResult(NotNullDataclass):
    fee: float = 0.0                # 头程费用
    weight: float = 0.0             # 头程重量
    processing_fee: float = 0.0     # 操作费
    result_unit: float = 0.0        # 结果币种单价
    error_msg: str = ''             # 错误信息
    formula: str = ''               # 计费公式


@dataclass
class FeeResult(NotNullDataclass):
    tailway: TailwayFeeResult = TailwayFeeResult()
    headway: HeadwayFeeResult = HeadwayFeeResult()
    error_msg: str = ''
    fee: float = field(init=False, default=0.0)

    def __post_init__(self):
        super().__post_init__()
        if not self.error_msg:
            if self.headway.error_msg:
                self.error_msg += f'头程费用计算异常: {self.headway.error_msg};\n'
            if self.tailway.error_msg:
                self.error_msg += f'尾程费用计算异常: {self.tailway.error_msg};\n'
        if not self.error_msg:
            # 无异常情况才有总运费
            self.fee = float(self.tailway.fee or 0) + float(self.headway.fee or 0) + float(self.headway.processing_fee or 0)

    def __lt__(self, other):
        """ 排序方法，无异常优先，相同异常状态按运费低优先 """
        self_lt = bool(self.error_msg) < bool(other.error_msg)
        other_lt = bool(other.error_msg) < bool(self.error_msg)
        if self_lt or other_lt:
            return self_lt
        return self.fee < other.fee

```

