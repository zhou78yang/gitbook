# 自建git服务器

## 部署
```bash
# 1. 安装git，创建git用户
sudo apt install git
sudo adduser git

# 2. 确定git主目录，添加.ssh/authorized_keys（注意，该文件的owner需要是git）
cd /home/git
mkdir .ssh
touch .ssh/authorized_keys
vim .ssh/authorized_keys 	# 将公钥填充进authorized_keys
sudo chown -R git:git .ssh/authorized_keys

# 3. 修改git用户配置
sudo vim /etc/passwd 	# 将git用户的shell指定为/usr/bin/git-shell

# 4. 在git用户目录下添加repository（同样要注意，repository的owner也需要是git）
git init --bare repo.git
sudo chown -R git:git repo.git
```

## 使用
法一：拉取空仓库
```bash
git clone git@{{your_host}}:repo.git
```

法二：现有本地仓库添加remote
```bash
git add remote {{remote_name}} git@{{your_host}}:repo.git
git push {{remote_name}} master		# 推送现有分支
```


参考资料：
https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/00137583770360579bc4b458f044ce7afed3df579123eca000
