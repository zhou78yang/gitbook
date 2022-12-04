# Beats

`Beats`是`Elastic.co`从`packetbeat`发展出来的数据收集器系统。beat收集器可以直接写入`Elasticsearch`，也可以传输给`Logstash`。其中抽象出来的`libbeat`，提供了统一的数据发送方法，输入配置解析，日志记录框架等功能。也就是说，所有的beat工具，在配置上，除了`input`以外，在`output`、`filter`、`shipper`、`logging`、`run-options`上的配置规则都是完全一致的。


## 参考网站
* ELK中文网站: https://elkguide.elasticsearch.cn/beats/