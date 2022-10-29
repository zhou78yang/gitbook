# 命名规范

原文: https://github.com/kettanaito/naming-cheatsheet

命名很难，Github上有人整理了一套命名规范。这当然不能覆盖100%的情况，只能说给出一个参考建议，对命名这块起一个指导作用。

## Naming cheatsheet

### 使用英语命名

英语是编程的主要语言，一定要避免使用拼音甚至直接使用中文命名。
```js
/* Bad */
const primerNombre = 'Gustavo'
const amigos = ['Kate', 'John']

/* Good */
const firstName = 'Gustavo'
const friends = ['Kate', 'John']
```

### 命名风格
选择**一种**命名风格并严格遵守，命名风格有很多种，驼峰，`snake_case`，或者其他的一些什么，最重要的是保持一致的命名风格，尤其是在团队中，不要混搭。

```js
/* Bad */
const page_count = 5
const shouldUpdate = true

/* Good */
const pageCount = 5
const shouldUpdate = true

/* Good as well */
const page_count = 5
const should_update = true
```

### S-I-D原则
* Short: 命名应该简短，但是也要注意不能简写到失去本来的意思
* Intuitive: 直观，尽可能接近自然语言
* Descriptive: 以最有效的方式反映其作用或目的

```js
/* Bad */
const a = 5 // "a" could mean anything
const isPaginatable = a > 10 // "Paginatable" sounds extremely unnatural
const shouldPaginatize = a > 10 // Made up verbs are so much fun!

/* Good */
const postCount = 5
const hasPagination = postCount > 10
const shouldPaginate = postCount > 10 // alternatively
```

### 避免过度简写
命名要简短，但可读性更重要，如果为了简短而失去本来的意义，降低可读性，那节省几个字符也没什么意义。

```js
/* Bad */
const onItmClk = () => {}

/* Good */
const onItemClick = () => {}
```

### 避免上下文重复
如下文，用`MenuItem.handleClick`好过`MenuItem.handleMenuItemClick`。
```js
class MenuItem {
  /* Method name duplicates the context (which is "MenuItem") */
  handleMenuItemClick = (event) => { ... }

  /* Reads nicely as `MenuItem.handleClick()` */
  handleClick = (event) => { ... }
}
```

### 反映预期结果

命名应当能反映预期的结果。

```jsx
/* Bad */
const isEnabled = itemCount > 3
return <Button disabled={!isEnabled} />

/* Good */
const isDisabled = itemCount <= 3
return <Button disabled={isDisabled} />
```


## 命名公式

### A/HC/LC模式

可以参考下面的模式来命名
```
prefix? + action (A) + high context (HC) + low context? (LC)
```

示例

| Name                   | Prefix   | Action (A) | High context (HC) | Low context (LC) |
| ---------------------- | -------- | ---------- | ----------------- | ---------------- |
| `getUser`              |          | `get`      | `User`            |                  |
| `getUserMessages`      |          | `get`      | `User`            | `Messages`       |
| `handleClickOutside`   |          | `handle`   | `Click`           | `Outside`        |
| `shouldDisplayMessage` | `should` | `Display`  | `Message`         |                  |


> [!Note|label:注意]
> 上下文的顺序可能会影响变量的意义，例如`shouldUpdateComponent`意思是将要更新一个组件，而`shouldComponentUpdate`表示组件将要自我更新


### Actions

函数命名的动词部分，是描述一个函数最重要的部分:
* get: 表示获取数据(从内存中获取数据)
* set: 表示设置数据
* reset: 重置数据
* fetch: 请求数据(从他处获取数据)
* remove: 移除数据(从某处移除，类似列表中移除一个元素)
* delete: 删除数据(删除整个数据)
* compose: 从现有数据创建新数据
* handle: 处理某个操作


##### `get`
获取立即就能获取到的数据
```js
function getFruitCount() {
  return this.fruits.length
}
```

##### `set`
修改一个值
```js
let fruits = 0

function setFruits(nextFruits) {
  fruits = nextFruits
}

setFruits(5)
console.log(fruits) // 5
```

##### `reset`
重置一个值
```js
const initialFruits = 5
let fruits = initialFruits
setFruits(10)
console.log(fruits) // 10

function resetFruits() {
  fruits = initialFruits
}

resetFruits()
console.log(fruits) // 5
```

##### `fetch`
请求某些数据，通常是有网络IO的情况，例如通过接口获取某些数据
```js
function fetchPosts(postCount) {
  return fetch('https://api.dev/posts', {...})
}
```

##### `remove`
从某处删除一些东西，例如从数组中删除某个项

```js
function removeFilter(filterName, filters) {
  return filters.filter((name) => name !== filterName)
}

const selectedFilters = ['price', 'availability', 'size']
removeFilter('price', selectedFilters)
```

##### `delete`
删除某个东西，彻底移除它的存在
```js
function deletePost(id) {
  return database.find({ id }).delete()
}
```

##### `compose`
从现有数据中创建新数据
```js
function composePageUrl(pageName, pageId) {
  return (pageName.toLowerCase() + '-' + pageId)
}
```

##### `handle`
处理某个动作，通常是callback方法
```js
function handleLinkClick() {
  console.log('Clicked a link!')
}

link.addEventListener('click', handleLinkClick)
```

### 上下文
函数通常是对某事物的一个动作。重要的是要说明它的可操作域是什么，或者至少是预期的数据类型
```js
/* A pure function operating with primitives */
function filter(list, predicate) {
  return list.filter(predicate)
}

/* Function operating exactly on posts */
function getRecentPosts(posts) {
  return filter(posts, (post) => post.date === Date.now())
}
```

> [!Note]
> 有些时候可以省略上下文，例如`filter`通常在js中就能知道是筛选一个数组，所以不需要命名为`filterArray`。


### 前缀
前缀通常是给变量使用的

##### `is`
```js
const color = 'blue'
const isBlue = color === 'blue' // characteristic
const isPresent = true // state

if (isBlue && isPresent) {
  console.log('Blue is present!')
}
```

##### `has`
```js
/* Bad */
const isProductsExist = productsCount > 0
const areProductsPresent = productsCount > 0

/* Good */
const hasProducts = productsCount > 0
```

##### `should`
```js
function shouldUpdateUrl(url, expectedUrl) {
  return url !== expectedUrl
}
```

##### `min`/`max`
```js
/**
 * Renders a random amount of posts within
 * the given min/max boundaries.
 */
function renderPosts(posts, minPosts, maxPosts) {
  return posts.slice(0, randomBetween(minPosts, maxPosts))
}
```

##### `prev`/`next`
```jsx
function fetchPosts() {
  const prevPosts = this.state.posts

  const fetchedPosts = fetch('...')
  const nextPosts = concat(prevPosts, fetchedPosts)

  this.setState({ posts: nextPosts })
}
```

### 单数和复数

```js
/* Bad */
const friends = 'Bob'
const friend = ['Bob', 'Tony', 'Tanya']

/* Good */
const friend = 'Bob'
const friends = ['Bob', 'Tony', 'Tanya']
```
