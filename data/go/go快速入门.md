# Go快速入门

## 安装
详见 [安装教程](https://golang.google.cn/doc/install)

安装成功后检验一下(示例)
```bash
$ go version
go version go1.18 linux/amd64
```

## hello
新建`hello.go`，写入
```go
package main

import "fmt"

func main() {
	fmt.Println("hello world")
}
```
代码解读:
* 每个源码文件开头都是一个package声明，表名Go代码所属的包（包是Go中最基本的分发单位，也是工程管理中依赖关系的体现）
* 要生成Go可执行程序，必须建立一个名为`main`的包，并且包含`main()`函数
* Go的`main()`函数不能带参数和返回值，命令行入参通过`os.Args`变量保存
* import语句导入需要的包（注意：不得包含源码中没有使用的包，否则会报编译错误）
* Go中强制不允许左花括号另起一行(会报编译错误)

### 执行
```bash
$ go run hello.go
hello world
```

## 注释
```go
// 单行注释
/*
多行注释
*/
```

## 变量
Go语言当中的变量声明方式，Go语言的类型在变量后面
```go
    var v1 int      // 声明变量
    var v2 int = 2  // 声明并赋值
    var v3 = 3      // 自动推导类型
    v4 := 4         // 自动推导类型（推荐）
```

### 类型
Go语言内置以下这些类型：
* 布尔类型：bool
* 整型：uint8, uint16, uint32, uint64, int8, int16, int32, int64, uint, int
* 浮点类型：float32, float64
* 复数类型：complex64, complex128
* 字符串：string
* 字符类型：rune(`type rune = uint32`)
* 字节类型：byte(`type byte = uint8`)
* 错误类型：error
* 指针类型：uintptr
* any类型：any(`type any = interface{}`，1.18引入)

此外，Go语言也支持以下这些复合类型：
* 指针（pointer）
* 数组（array）
* 切片（slice）
* 字典（map）
* 通道（chan）
* 结构体（struct）
* 接口（interface）

内置类型的声明与赋值
```go
    var (
        v1 int
        v2 string
        v3 [10]int              // 数组
        v4 []int                // 数组切片
        v5 struct {
            f int
        }
        v6 *int = nil           // 指针
        v7 map[string] int      // key为string，value为int的map类型
        v8 func(a int) int
    )

    // 变量赋值
    fmt.Println("before:", v1, v2, v3, v4, v5, v6, v7, v8)
    v1 = 10
    v2 = "abc"
    v3[2] = 1
    v4 = v3[:2]
    v5.f = 1
    v6 = &v1
    v7 = make(map[string] int)
    v7["age"] = 18
    fmt.Println("after:", v1, v2, v3, v4, v5, v6, v7, v8)
```
代码解读
* 多个变量赋值的时候可以放置在一起，共用一个var，import同理


## 流程控制与函数
Go语言中的流程控制关键字
* 条件语句: `if`, `else`, `else if`
* 选择语句: `switch`, `case`, `select`
* 循环语句: `for`, `range`
* 跳转语句: `goto`
* 辅助: `break`, `continue`, `fallthrough`

流程控制示例代码
```go
package main

import "fmt"

// 获取分数等级
func getGrade(score int) (grade string) {
	if score >= 90 {
		grade = "优秀"
	} else if score >= 60 {
		grade = "及格"
	} else {
		grade = "不及格"
	}
	return
}

// 打印多个分数
func printGrade(scores []int) {
	for i, s := range scores {
		g := getGrade(s)
		fmt.Print(g)
		if i == len(scores)-1 {
			break
		}
		fmt.Print(" ")
	}
	fmt.Println()
}

// 统计每个等级的人数
func getGradeNums(scores []int) map[string]int {
	m := map[string]int{}

	for _, s := range scores {
		switch {
		case s >= 90:
			m["优秀"]++
		case s >= 60:
			m["及格"]++
		default:
			m["不及格"]++
		}
	}
	return m
}

func main() {
	scores := []int{72, 88, 91, 44, 100, 67}
	printGrade(scores)
	m := getGradeNums(scores)
	for k, v := range m {
		fmt.Println(k, v)
	}
}
```

代码解读
* `else`左边必跟`{`
* Go的`switch`非常灵活，表达式不必是常量或整数，执行的过程从上至下，直到找到匹配项
* Go里面`switch`默认相当于每个`case`后都带有`break`，匹配成功后不会自动向下执行其他case，而是跳出整个`switch`, 但是可以使用`fallthrough`强制执行后面的case代码
	

## 错误处理
Go语言中对于大多数函数，如果要返回错误，大致上都可以定义为如下模式，将error作为多种返回值中的最后一个：

```go
func Foo(param int) (n int, err error) {
    // ...
}
```

调用时的处理方案
```go
n, err := Foo(0) 
if err != nil { 
    // 错误处理
}
```

### defer
Go语言中有种不错的设计，即延迟`defer`语句，你可以在函数中添加多个`defer`语句。当函数执行到最后时，这些`defer`语句会按照逆序执行，最后该函数返回。特别是当你在进行一些打开资源的操作时，遇到错误需要提前返回，在返回前你需要关闭相应的资源，不然很容易造成资源泄露等问题。

```go
func defer_test() {
    // 下面循环会输出`4 3 2 1 0`
    for i := 0; i < 5; i++ {
        defer fmt.Printf("%d ", i)
    }
}
```

### panic和recover
Go语言引入了两个内置函数`panic()`和`recover()`以报告和处理运行时错误和程序中的错误场景：
```go
func panic(interface{})
func recover() interface{} 
```
`panic()`函数会制造一个panic，类似其他语言的异常抛出，正常的函数执行流程将立即终止。
但函数中之前使用defer关键字延迟执行的语句将正常展开执行，之后该函数将返回到调用函数，并导致逐层向上执行panic流程，
直至所属的goroutine中所有正在执行的函数被终止。错误信息将被报告，包括在调用panic()函数时传入的参数，这个过程称为错误处理流程。

对于panic，我们可以使用`recover()`函数进行处理，`recover()`会将当前产生的panic取出（如果有的话），后续的流程将会正常执行。 使用示例：
```go
func div(a, b int) int {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("wrong:", r)
        }
    }()

	return a / b
}
```