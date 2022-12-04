# Django模型继承

## Django的模型继承通常有三种方式：
1. 使用抽象模型类（Abstract Model）：将不需要为每个子类都建立的字段和方法添加到抽象基类中，抽象模型在数据库中不拥有实体，即抽象模型无法访问数据库
2. 多表继承（Multi-table inheritance）：基类和子类都在数据库中拥有自己对应的表
3. 使用代理模型（Proxy Model）：仅针对基类实现Python级别的拓展，代理模型在数据库中不拥有实体。如果只想修改模型的Python级行为，而不想以任何方式更改模型字段，则使用该种方式


## 知识点
* 抽象模型（Abstract Model）
    * 抽象模型的Meta类继承
    * 抽象模型中的外键关系，related_name和related_query_name
* 多表继承（Multi-table inheritance）
    * 子类和父类的一对一关联
* 代理模型（Proxy Model）
    * 代理模型的数据和父类的完全相同，只是增加了Python级别的方法
    * 在代理模型中自定义Manager，既保留了原本的模型，又能定制Manager和方法
    * 在代理模型中定制Meta信息


## 示例代码
```python
# 抽象模型
class BaseOrder(models.Model):
    sn = models.CharField(max_length=128, primary_key=True, unique=True, verbose_name='订单编号')
    created_time = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    pay_time = models.DateTimeField(null=True, blank=True, verbose_name='支付时间')

    def __str__(self):
        return self.sn

    class Meta:
        abstract = True
        ordering = ('-created_time', )


# 继承抽象模型
class Order(BaseOrder):
    product_name = models.CharField(max_length=128, verbose_name='商品名称')

    class Meta(BaseOrder.Meta):
        verbose_name = '订单'
        verbose_name_plural = '订单'
        db_table = 'my_model.order'


# 代理模型
class OrderUserMethod(Order):
    @classmethod
    def create_order(cls, user, **validated_data):
        obj = cls(**validated_data)
        if not user.has_perm('my_model.add_order', obj):
            raise exceptions.PermissionDenied()
        obj.save()
        return obj

    def change_order(self, user, **validated_data):
        if not user.has_perm('my_model.change_order', self):
            raise exceptions.PermissionDenied()
        for k, v in validated_data.items():
            setattr(self, k, v)
        self.save()
        return self

    class Meta:
        proxy = True
```
