# pipenv使用

`Pipenv`是Python项目的依赖管理器。相比于pip，它是一种更高级的工具，可简化依赖关系管理的常见使用情况。

主要特性包含：
* 为锁定的依赖项生成并检查文件哈希。
* 根据`Pipfile`自动寻找项目根目录。
* 如果不存在，可以自动生成`Pipfile`和`Pipfile.lock`。
* 自动在项目目录的`.venv`目录创建虚拟环境。（这个目录地址通过设置`WORKON_HOME`改变）
* 自动管理`Pipfile`新安装和删除的包。
* 自动加载`.env`文件;

Pipfile的基本理念是：
* Pipfile文件是TOML格式而不是requirements.txt这样的纯文本。
* 一个项目对应一个Pipfile，支持开发环境与正式环境区分。默认提供`default`和`development`区分。
* 提供版本锁支持，存为`Pipfile.lock`。

## 安装
```bash
pip install pipenv
```

## 使用

![使用](./img/pipenv.gif)

创建虚拟环境
```bash
pipenv_test$ pipenv install
Creating a virtualenv for this project…
Pipfile: $HOME/yangchi/code/pipenv_test/Pipfile
Using /usr/local/bin/python3.8 (3.8.1) to create virtualenv…
⠸ Creating virtual environment...Already using interpreter /usr/local/bin/python3.8
Using base prefix '/usr/local'
New python executable in $HOME/.local/share/virtualenvs/pipenv_test-UTimSlYW/bin/python3.8
Also creating executable in $HOME/.local/share/virtualenvs/pipenv_test-UTimSlYW/bin/python
Installing setuptools, pip, wheel...
done.

✔ Successfully created virtual environment! 
Virtualenv location: $HOME/.local/share/virtualenvs/pipenv_test-UTimSlYW
Creating a Pipfile for this project…
Pipfile.lock not found, creating…
Locking [dev-packages] dependencies…
Locking [packages] dependencies…
Updated Pipfile.lock (db4242)!
Installing dependencies from Pipfile.lock (db4242)…
  🐍   ▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉ 0/0 — 00:00:00
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.

```

激活虚拟环境
```bash
pipenv_test$ pipenv shell
Launching subshell in virtual environment…
pipenv_test$  . $HOME/.local/share/virtualenvs/pipenv_test-UTimSlYW/bin/activate

```

查看激活后python
```bash
(pipenv_test) pipenv_test$ which python
$HOME/.local/share/virtualenvs/pipenv_test-UTimSlYW/bin/python

```

退出虚拟环境
```bash
(pipenv_test) pipenv_test$ exit
exit
```

当前目录下生成了`Pipfile`和`Pipfile.lock`文件
```bash
(pipenv_test) pipenv_test$ ls
Pipfile  Pipfile.lock

(pipenv_test) pipenv_test$ cat Pipfile
[[source]]
name = "pypi"
url = "https://pypi.org/simple"
verify_ssl = true

[dev-packages]

[packages]

[requires]
python_version = "3.8"

```

安装包
```bash
(pipenv_test) pipenv_test$ pipenv install requests
Installing requests…
Adding requests to Pipfile's [packages]…
✔ Installation Succeeded 
Pipfile.lock (fbd99e) out of date, updating to (db4242)…
Locking [dev-packages] dependencies…
Locking [packages] dependencies…
✔ Success! 
Updated Pipfile.lock (fbd99e)!
Installing dependencies from Pipfile.lock (fbd99e)…
  🐍   ▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉ 5/5 — 00:00:01


(pipenv_test) pipenv_test$ cat Pipfile	# 新增了requests依赖
[[source]]
name = "pypi"
url = "https://pypi.org/simple"
verify_ssl = true

[dev-packages]

[packages]
requests = "*"

[requires]
python_version = "3.8"

```

查看依赖关系
```bash
(pipenv_test) pipenv_test$ pipenv graph
requests==2.25.1
  - certifi [required: >=2017.4.17, installed: 2020.12.5]
  - chardet [required: >=3.0.2,<5, installed: 4.0.0]
  - idna [required: >=2.5,<3, installed: 2.10]
  - urllib3 [required: >=1.21.1,<1.27, installed: 1.26.4]
```

检查包的安全性
```bash
(pipenv_test) pipenv_test$ pipenv check
Checking PEP 508 requirements…
Passed!
Checking installed package safety…

```

卸载包
```bash
(pipenv_test) pipenv_test$ pipenv uninstall requests
Uninstalling requests…
Found existing installation: requests 2.25.1
Uninstalling requests-2.25.1:
  Successfully uninstalled requests-2.25.1

Removing requests from Pipfile…
Locking [dev-packages] dependencies…
Locking [packages] dependencies…
Updated Pipfile.lock (db4242)!

(pipenv_test) pipenv_test$ pip freeze	# 依赖的包不删除
certifi==2020.12.5
chardet==4.0.0
idna==2.10
requests==2.25.1
urllib3==1.26.4

```


## 虚拟环境的文件位置

默认情况下，虚拟环境及其安装的包都会放到`/home/$username/.local/share/virtualenvs`目录下，修改目录有以下几种方式:
* `export PIPENV_VENV_IN_PROJECT=1`设置这个环境变量，pipenv会在当前目录下创建`.venv`目录作为虚拟环境;
* 自己在项目目录下手动创建`.venv`的目录，然后运行`pipenv install`会在`.venv`下创建虚拟环境;
* 设置`WORKON_HOME`到其他的地方(如果当前目录下已经有`.venv`会失效);

```bash
pipenv_test$ mkdir .venv
pipenv_test$ pipenv install
```


## pipenv多个源使用
```TOML
[[source]]
name = "aliyun"
url = "https://mirrors.aliyun.com/pypi/simple"
verify_ssl = true

[[source]]
name = "pypi"
url = "https://pypi.python.org/simple"
verify_ssl = true

[dev-packages]

[packages]
requests = "*"
retrying = {version="*", index="pypi"}

```
如果指定多个source，pipenv会默认按照源的顺序指定，上面的配置的实际执行效果如下(通过`pipenv install -v`执行):
```bash
Installing 'requests'
$ $HOME/tmp/pipenv_test/.venv/bin/python -m pip install --verbose --upgrade --require-hashes --no-deps --exists-action=i -r /tmp/pipenv-y1ium7u0-requirements/pipenv-z4q270rq-requirement.txt -i https://mirrors.aliyun.com/pypi/simple --extra-index-url https://pypi.python.org/simple --extra-index-url https://pypi.python.org/simple
Using source directory: '$HOME/tmp/pipenv_test/.venv/src'
Writing supplied requirement line to temporary file: 'retrying==1.3.3 --hash=sha256:08c039560a6da2fe4f2c426d0766e284d3b736e355f8dd24b37367b0bb41973b'
Installing 'retrying'
$ $HOME/tmp/pipenv_test/.venv/bin/python -m pip install --verbose --upgrade --require-hashes --no-deps --exists-action=i -r /tmp/pipenv-y1ium7u0-requirements/pipenv-0xkhovdg-requirement.txt -i https://pypi.python.org/simple --extra-index-url https://mirrors.aliyun.com/pypi/simple --extra-index-url https://mirrors.aliyun.com/pypi/simple
Using source directory: '$HOME/tmp/pipenv_test/.venv/src'
```


## 参考
* https://pipenv.pypa.io/en/latest/
* https://dongwm.com/post/125/