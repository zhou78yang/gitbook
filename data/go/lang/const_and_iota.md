# 常量和iota

## 常量

Go语言中支持布尔常量(boolean constants)，数字常量(numeric constants)和字符串常量(string constants)，其中数字常量又可分为`rune`, `integer`, `floating-point`, `complex`几种类型。

### 常量定义
常量在定义时必须赋值，不指定类型时可以自动推导类型
```go
const pi = 3.1415
var f1 float32 = pi
var f2 float64 = pi
fmt.Printf("%f %T %T\n", pi, f1, f2) // 3.1415 float32 float64
```

const可以组声明多个常量，如果省略值，就表示和上一行值相同(包括格式)
```go
const (
	c1 int = 100
	c2
	c3 = "aaa"
	c4
	c5, c6 = iota, iota + 1 // 此时iota=4
	_, _                    // 此时iota=5
	c7, _                   // 此时iota=6
)
fmt.Println(c1, c2, c3, c4) // 100 100 aaa aaa
fmt.Println(c5, c6, c7)     // 4 5 6
```

### 常量的类型
常量可以分为有类型常量和无类型常量。字面值（literal），`true`，`false`，`iota`，以及仅含无类型常量组成的复合常量，都是无类型常量。

无类型常量可以在使用时隐式转换为需要的类型，但无类型常量也会存在默认推导类型，根据字面值可以是`bool`, `rune`, `int`, `float64`, `complex128`, `string`。

```go
const (
	cBool    = true
	cRune    = 'a'
	cInt     = 15
	cFloat   = 3.5
	cComplex = 1 + 5i
	cString  = "hello"
)
vBool, vRune, vInt, vFloat, vComplex, vString := cBool, cRune, cInt, cFloat, cComplex, cString
fmt.Printf("%T %T %T %T %T %T\n", vBool, vRune, vInt, vFloat, vComplex, vString) // bool int32 int float64 complex128 string
```

### 编译器实现约束
* 表示至少256位的整数常量
* 表示浮点常量，包括复数常量的部分，尾数至少为256位，带符号二进制指数至少为16位。
* 如果无法精确表示整数常量，则给出错误
* 如果由于溢出而无法表示浮点或复数常量，则给出错误
* 如果由于精度限制而无法表示浮点或复数常量，则舍入到最接近的可表示常量



## iota
iota是Go语言中的常量计数器，每一个const关键字出现iota都会被重置为0，每一行iota都会自增1
```go
const (
	Sun = iota
	Mon
	Tue
	Wed
	Thu
	Fri
	Sat
)
fmt.Println(Sun, Mon, Tue, Wed, Thu, Fri, Sat) // 0 1 2 3 4 5 6

// iota从1开始的方式
const (
	i1 = iota + 1
	i2
	i3
)
fmt.Println(i1, i2, i3) // 1 2 3

// 移位常量
const (
	b1 = 1 << iota
	b2
	b3
	b4
	b5
)
fmt.Println(b1, b2, b3, b4, b5) // 1 2 4 8 16

// 每一行iota都会自增1，即使没有出现
const (
	t1 = iota
	t2
	t3 = 15
    t4 = iota // 此时iota=3
	t5
)
fmt.Println(t1, t2, t3, t4, t5) // 0 1 15 3 4
```

## 参考
* 常量 https://go.dev/ref/spec#Constants
* iota https://go.dev/ref/spec#Iota