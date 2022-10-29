# 网络
网络相关的资料汇总


## 同源策略
浏览器安全的基石是"同源政策"（same-origin policy）。

同源的判定标准：
* 协议相同
* 域名相同
* 端口相同

非同源以下三种行为将会受限:
* Cookie, LocalStorage, IndexedDB无法读取
* DOM无法获得
* AJAX请求不能发送

资料:
* 浏览器同源政策及其规避方法 http://www.ruanyifeng.com/blog/2016/04/same-origin-policy.html


## CORS
CORS是一个W3C标准，全称是"跨域资源共享"（Cross-origin resource sharing）。
它允许浏览器向跨源服务器，发出XMLHttpRequest请求，从而克服了AJAX只能同源使用的限制。

资料:
* 跨域资源共享CORS详解 https://www.ruanyifeng.com/blog/2016/04/cors.html


## OAuth 2.0
OAuth 2.0 是目前最流行的授权机制，用来授权第三方应用，获取用户数据。

资料:
* 概念介绍 https://www.ruanyifeng.com/blog/2019/04/oauth_design.html
* OAuth 2.0 的四种方式 https://www.ruanyifeng.com/blog/2019/04/oauth-grant-types.html
* 示例教程 https://www.ruanyifeng.com/blog/2019/04/github-oauth.html

