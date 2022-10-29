# 空结构体

## 特性
参考：https://go.dev/ref/spec#Size_and_alignment_guarantees
> A struct or array type has size zero if it contains no fields (or elements, respectively) that have a size greater than zero. 
> Two distinct zero-size variables may have the same address in memory.

翻译
> 如果结构或数组类型不包含大小大于零的字段（或元素），则其大小为零。两个不同的零大小变量在内存中可能具有相同的地址


源码: runtime/malloc.go
```go
// base address for all 0-byte allocations
var zerobase uintptr

// 创建一个新对象
func newobject(typ *_type) unsafe.Pointer {
    return mallocgc(typ.size, typ, true)
}

func mallocgc(size uintptr, typ *_type, needzero bool) unsafe.Pointer {
    if gcphase == _GCmarktermination {
        throw("mallocgc called with gcphase == _GCmarktermination")
    }

    if size == 0 {
        return unsafe.Pointer(&zerobase)
    }

    ...
}
```
对于大小为0的对象，都会返回`zerobase`的地址，所以所有空结构体的地址都相同。

## 空结构体的应用

### 集合类型(Set)
集合Set可以看做是一个只有键的映射Map，Go语言中没有内置Set类型，但我们可以利用map实现。
但我们只会用到map中的键，只需要提供 添加键，删除键，键是否存在 这三种能力，对于值是什么完全不关心，可以将值类型设为大小为0的`struct{}`

```go
package empty_struct

type setItem struct{}

type Set struct {
	items map[interface{}]setItem
}

var itemVal setItem

func NewSet(n int) *Set {
	return &Set{
		items: make(map[interface{}]setItem, n),
	}
}

func (s *Set) Add(v interface{}) {
	s.items[v] = itemVal
}

func (s *Set) Remote(v interface{}) {
	delete(s.items, v)
}

func (s *Set) Has(v interface{}) bool {
	_, exists := s.items[v]
	return exists
}

func (s *Set) Len() int {
	return len(s.items)
}
```

### 限制struct的初始化方式
```go
type MustKeyStruct struct {
	Name string
	Age  int
	_    struct{}
}

func main() {
	// 只能使用key的方式进行初始化
	a := MustKeyStruct{
		Name: "zhangsan", Age: 18,
	}
	//a = MustKeyStruct{"lisi", 22} // 编译失败
	fmt.Println(a)
}
```

### 作为通道的信号传输
有些时候，我们使用channel只是为了传递信号，并不关心传递的值是什么，这个时候就会考虑使用空结构体来节省channel空间

```go
var empty = struct{}{}

type Semaphore chan struct{}

func NewSemaphore(n int) Semaphore {
	return make(Semaphore, n)
}

func (s Semaphore) P(n int) {
	for i := 0; i < n; i++ {
		s <- empty
	}
}

func (s Semaphore) V(n int) {
	for i := 0; i < n; i++ {
		<-s
	}
}
```
