# 开始

## 创建项目
创建项目
```
scrapy startproject scrapy_chs
```

添加爬虫
```shell
cd scrapy_chs
scrapy genspider scrapy_chs_spider scrapy-chs.readthedocs.io
```

生成的目录
```
scrapy_chs$ tree
.
├── scrapy.cfg
└── scrapy_chs
    ├── __init__.py
    ├── items.py
    ├── middlewares.py
    ├── pipelines.py
    ├── settings.py
    └── spiders
        ├── __init__.py
        └── scrapy_chs_spider.py

```

## 编写spider
通过重写`parse`方法定制抓取功能
```python
import scrapy


class ScrapyChsSpiderSpider(scrapy.Spider):
    name = 'scrapy_chs_spider'
    allowed_domains = ['scrapy-chs.readthedocs.io']
    start_urls = [
        'https://scrapy-chs.readthedocs.io/zh_CN/1.0/intro/tutorial.html',
    ]

    def parse(self, response):
        filename = f"{response.url.strip('/').rsplit('/')[-1]}.html"
        with open(filename, 'wb') as f:
            f.write(response.body)

```

## 启动爬虫
```shell
# 需要在项目工作目录下
scrapy crawl scrapy_chs_spider
```

## 提取Item
从网页中提取数据有很多方法。Scrapy使用了一种基于 XPath 和 CSS 表达式机制: Scrapy Selectors 。

Selector基础方法：
* xpath(): 传入xpath表达式，返回该表达式所对应的所有节点的selector list列表 。
* css(): 传入CSS表达式，返回该表达式所对应的所有节点的selector list列表.
* extract(): 序列化该节点为unicode字符串并返回list。
* re(): 根据传入的正则表达式对数据进行提取，返回unicode字符串list列表

scrapy提供了一个shell环境方便我们调试Selector
```shell
scrapy shell "https://scrapy-chs.readthedocs.io/zh_CN/1.0/intro/tutorial.html"
```

### 定义Item
```python
class ScrapyChsItem(scrapy.Item):
    title = scrapy.Field()
    content = scrapy.Field()
```

### Spider获取Item
```python
class ScrapyChsSpiderSpider(scrapy.Spider):
    name = 'scrapy_chs_spider'
    allowed_domains = ['scrapy-chs.readthedocs.io']
    start_urls = [
        'https://scrapy-chs.readthedocs.io/zh_CN/1.0/index.html',
    ]

    def parse(self, response):
        for link in response.xpath('//li[@class="toctree-l1"]/a/@href').extract():
            url = response.urljoin(link)
            yield scrapy.Request(url=url, callback=self.parse_document)

    def parse_document(self, response):
        item = ScrapyChsItem()
        item['title'] = response.xpath('/html/head/title/text()').extract()
        item['content'] = response.xpath('//h1/text()').extract()
        yield item
```

## Item Pipeline
定义一个处理Item的Pipeline
```python
class JsonWriterPipeline(object):

    def __init__(self):
        self.file = open('items.jl', 'w')

    def process_item(self, item, spider):
        line = json.dumps(dict(item), ensure_ascii=False) + "\n"
        self.file.write(line)
        return item

    def close_spider(self, spider):
        self.file.close()
```

添加Pipeline
```python
ITEM_PIPELINES = {
   'scrapy_chs.pipelines.JsonWriterPipeline': 300,
}
```
分配给每个类的整型值，确定了他们运行的顺序，item按数字从低到高的顺序，通过pipeline，通常将这些数字定义在0-1000范围内。