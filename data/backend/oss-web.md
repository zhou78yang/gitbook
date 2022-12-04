# OSS Web应用开发
本文主要介绍几种OSS的开发场景和解决方案资料整理。

## 服务端上传文件到OSS
从服务端上传文件到OSS一般是使用官方提供的SDK操作
* SDK文档: https://help.aliyun.com/document_detail/52834.html
* Python SDK文档: https://help.aliyun.com/document_detail/32027.htm

### Python sdk安装
```shell
$ pip install oss2
```

### Python 快速上手
一个简易的OSS Storage类示例，用到常用的读写方法
```python
from oss2 import Auth, Bucket

class AliOssStorage:
    """
        阿里云OSS Storage

        >>> s = AliOssStorage(access_key_id, access_key_secret, endpoint, bucket_name)
        >>> for i in range(3):
        ...     s.save(f'test/{i+1}.txt', b'hello world')
        'test/1.txt'
        'test/2.txt'
        'test/3.txt'
        >>> s.read('test/1.txt')
        b'hello world'
        >>> s.delete('test/1.txt').status
        204
        >>> for o in s.list('test'):
        ...     print(o.key)
        test/2.txt
        test/3.txt
        >>> s.batch_delete(['test/2.txt', 'test/3.txt']).deleted_keys
        ['test/2.txt', 'test/3.txt']

    """
    def __init__(self, access_key_id, access_key_secret, endpoint, bucket_name):
        self.auth = Auth(access_key_id, access_key_secret)
        self.bucket = Bucket(self.auth, endpoint, bucket_name)

    def path(self, name):
        """ 将文件标识转换为实际Storage存储的路径 """
        name = name.replace(' ', '_')
        return name

    def read(self, name):
        """ 返回文件内容(默认二进制流) """
        key = self.path(name)
        result = self.bucket.get_object(key)
        return result.read()

    def save(self, name, content):
        """ 保存文件 """
        key = self.path(name)
        self.bucket.put_object(key, content)
        return key

    def delete(self, name):
        """ 删除文件 """
        key = self.path(name)
        result = self.bucket.delete_object(key)
        return result

    def batch_delete(self, name_list):
        """ 批量删除文件 """
        key_list = [self.path(name) for name in name_list]
        result = self.bucket.batch_delete_objects(key_list)
        return result

    def exists(self, name):
        """ 文件是否存在 """
        key = self.path(name)
        return self.bucket.object_exists(key)

    def list_objects(self, key='', max_keys=100):
        """ 通过生成器访问对象列表 """
        result = self.bucket.list_objects(key, max_keys=max_keys)
        while True:
            for obj in result.object_list:
                yield obj
            if not result.next_marker:
                break
            result = self.bucket.list_objects(key, marker=result.next_marker, max_keys=max_keys)

    def list(self, name):
        """ 返回所有对象列表 """
        key = self.path(name)
        gen = self.list_objects(key)
        return list(gen)
```

## 客户端上传文件到OSS
### 通过应用服务器转发到OSS
Web端常见的上传方法是用户在浏览器或App端上传文件到应用服务器，应用服务器再把文件上传到OSS

![流程图](https://help-static-aliyun-doc.aliyuncs.com/assets/img/zh-CN/7354449951/p140018.png)

和数据直传到OSS相比，以上方法存在以下缺点：
* 上传慢：用户数据需先上传到应用服务器，之后再上传到OSS，网络传输时间比直传到OSS多一倍。如果用户数据不通过应用服务器中转，而是直传到OSS，速度将大大提升。而且OSS采用BGP带宽，能保证各地各运营商之间的传输速度。
* 扩展性差：如果后续用户数量逐渐增加，则应用服务器会成为瓶颈。
* 费用高：需要准备多台应用服务器。由于OSS上行流量是免费的，如果数据直传到OSS，将节省多台应用服务器的费用。

### Web端PostObject直传
数据直传至OSS是利用OSS的PostObject接口，使用表单上传方式上传文件至OSS。通常有以下三种实践方案:

* 在客户端通过JavaScript代码完成签名，然后通过表单直传数据到OSS。[链接](https://help.aliyun.com/document_detail/31925.htm)
* 在服务端完成签名，然后通过表单直传数据到OSS。[链接](https://help.aliyun.com/document_detail/31926.htm)
* 在服务端完成签名，并且服务端设置了上传后回调，然后通过表单直传数据到OSS。OSS回调完成后，再将应用服务器响应结果返回给客户端。[链接](https://help.aliyun.com/document_detail/31927.htm)

通常，我们为了安全性会选用服务端完成签名的方案，按需选择是否回调。服务端签名流程图：
![服务端流程图](https://help-static-aliyun-doc.aliyuncs.com/assets/img/zh-CN/4172710461/p374419.png)
