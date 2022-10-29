# json

`encoding/json`包提供了快速对Go对象进行JSON序列化和反序列化的能力。

## 序列化
`json.Marshal`函数能够快速对一个Go对象进行JSON序列化(结果为[]byte类型)

```go
func marshal() {
	msg := struct {
		Name string
		Body string
		Time int64
	}{
		"zhangsan", "Hello", 123456789,
	}
	b, err := json.Marshal(msg)
	if err != nil {
		panic(err)
	}

	if string(b) == `{"Name":"zhangsan","Body":"Hello","Time":123456789}` {
		fmt.Println(string(b))
	}
}
```

### 只有可以表示为有效JSON的数据结构才会被编码
* JSON对象只支持字符串作为key; 如果要对map进行序列化, 它的格式必须是map[string]T（其中T是json包支持的任何Go类型）
* `channel`, `complex`, `function`等类型无法被序列化
* 不支持循环的结构体，会导致`Marshal`无限循环
* 指针将被编码为它们所指向的值（如果指针为nil，则为“null”）


## 反序列化
`json.Unmarshal`函数能快速将JSON数据反序列化为Go对象

```go
// unmarshal 通过`json.Unmarshal`对JSON数据进行反序列化
func unmarshal() {
	var msg struct {
		Name string
		Body string
		Time int64
	}

	b := []byte(`{"Name":"zhangsan","Body":"Hello","Time":123456789}`)
	err := json.Unmarshal(b, &msg)
	if err != nil {
		panic(err)
	}

	fmt.Println(msg)
}
```

### `Unmarshal`的字段查找顺序（按优先级）
例如在struct中查找符合JSON数据中key为`Foo`的字段：
* 查找struct中字段tag中指定为json字段为`Foo`的字段
* 查找struct中字段名为`Foo`的字段
* 查找struct中字段名为`foo`, `FOO`, `FoO`等大小写不敏感的同名字段

如果在struct中找不到符合以上条件的字段，那么`Unmarshal`会忽略`Foo`字段的反序列化


## 反序列化为任意数据

```go
// decodeInterface 结构不确定的JSON数据反序列化
func decodeInterface() {
	b := []byte(`{"name": "zhangsan", "age": 18, "weight": 62.1, "tags": ["male", "student"], "is_adult": true,
				  "addr": {"country": "cn", "city": "sz"}, "nil_value": null}`)

	var f interface{}
	err := json.Unmarshal(b, &f)
	if err != nil {
		panic(err)
	}
	fmt.Println("object:", f)

	m, ok := f.(map[string]interface{})
	if !ok {
		panic("[genericJson] decode map error")
	}

	for k, v := range m {
		switch v := v.(type) {
		case bool:
			fmt.Println(k, "is bool:", v)
		case string:
			fmt.Println(k, "is string:", v)
		case float64:
			fmt.Println(k, "is number:", v)
		case []interface{}:
			fmt.Println(k, "is array:", v)
		case map[string]interface{}:
			b, err := json.Marshal(v)
			if err != nil {
				fmt.Println(k, "marshal err:", err)
			}
			fmt.Println(k, "is object:", string(b))
		case nil:
			fmt.Println(k, "is null")
		default:
			fmt.Printf("%s is unknown type %T\n", k, v)
		}
	}
}
```

### JSON值在Go中的默认映射
* object: map[string]interface{}
* array: []interface{}
* string: string
* number: float64
* bool: bool
* null: nil


## json tag
...


## 格式化
...


## 数据流的Encoder和Decoder
...


## 参考资料
* 官方介绍文档: https://go.dev/blog/json
* `json`包文档: https://pkg.go.dev/encoding/json
* `jsonrpc`包文档: https://pkg.go.dev/net/rpc/jsonrpc
