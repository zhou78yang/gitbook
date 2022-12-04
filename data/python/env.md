# 常用env工具

[12-Factor](../methodology/12-factor.md)推荐将应用的配置存储于环境变量中。
环境变量可以非常方便地在不同的部署间做修改，却不动一行代码；与配置文件不同，不小心把它们签入代码库的概率微乎其微。

env工具的基本设计思路是将一个键值对文件(`.env`)中的内容读取，并写入环境变量中。以下介绍一些常用的env工具


## python-dotenv
地址: https://github.com/theskumar/python-dotenv

### 使用
```python
from dotenv import load_dotenv

load_dotenv()  # 将 .env 中的配置加载到环境变量

# os.environ.get('MY_VAR') 或者 os.getenv('MY_VAR')
```

直接取值env文件中的配置，不加载到环境变量
```python
from dotenv import dotenv_values

config = dotenv_values()    # 默认加载 .env 文件
```
例如多个env文件时
```python
import os
from dotenv import dotenv_values

config = {
    **dotenv_values(".env.shared"),  # load shared development variables
    **dotenv_values(".env.secret"),  # load sensitive variables
    **os.environ,  # override loaded values with environment variables
}
```

`load_dotenv()`中的`override`(默认为False)参数的作用(是否覆盖系统环境变量)
##### override=False
环境变量加载顺序:           

1. 系统环境变量中的值
2. `.env`文件中的值
3. 默认值，如果有
4. None

##### override=True
环境变量加载顺序:       

1. `.env`文件中的值
2. 系统环境变量中的值
3. 默认值，如果有
4. None


## django-dotenv
地址: https://github.com/jpadilla/django-dotenv

```python
from dotenv import read_dotenv

read_dotenv('.env')     # 将 .env 中的配置加载到环境变量中

```
django-dotenv的`read_dotenv`是和python-dotenv中的`load_dotenv`等效，需要注意的是，它们两个都是dotenv，同一个项目只能使用一个

### 小结
不推荐使用，建议直接用python-dotenv


## environs
地址: https://github.com/sloria/environs

相对于dotenv，environs不止是将env文件加载到环境变量中，还增加了一些其他的功能
* 类型转换。支持int, list, dict, url, path等多种类型的转换
* 前缀匹配
* 数据校验
* 框架集成（主要是Flask和Django）

```python
from environs import Env

env = Env()
# Read .env into os.environ
env.read_env()

env.bool("DEBUG")  # => True
env.int("PORT")  # => 4567
```

### 前缀匹配 prefixed
```python
# export MYAPP_HOST=lolcathost
# export MYAPP_PORT=3000

with env.prefixed("MYAPP_"):
    host = env("HOST", "localhost")  # => 'lolcathost'
    port = env.int("PORT", 5000)  # => 3000

# nested prefixes are also supported:

# export MYAPP_DB_HOST=lolcathost
# export MYAPP_DB_PORT=10101

with env.prefixed("MYAPP_"):
    with env.prefixed("DB_"):
        db_host = env("HOST", "lolcathost")
        db_port = env.int("PORT", 10101)
```

## django-environs
地址: https://github.com/joke2k/django-environ

功能基本和environs包相当，更针对Django进行处理，提供了些`db`, `cache`之类的函数，将支持的uri转换成字典。             
详情看 https://github.com/joke2k/django-environ#supported-types

```python
import environ
env = environ.Env(
    # set casting, default value
    DEBUG=(bool, False)
)
# reading .env file
environ.Env.read_env()

# False if not in os.environ
DEBUG = env('DEBUG')

# Raises django's ImproperlyConfigured exception if SECRET_KEY not in os.environ
SECRET_KEY = env('SECRET_KEY')

# Parse database connection url strings like psql://user:pass@127.0.0.1:8458/db
DATABASES = {
    # read os.environ['DATABASE_URL'] and raises ImproperlyConfigured exception if not found
    'default': env.db(),
    # read os.environ['SQLITE_URL']
    'extra': env.db('SQLITE_URL', default='sqlite:////tmp/my-tmp-sqlite.db')
}

CACHES = {
    # read os.environ['CACHE_URL'] and raises ImproperlyConfigured exception if not found
    'default': env.cache(),
    # read os.environ['REDIS_URL']
    'redis': env.cache('REDIS_URL')
}
```


