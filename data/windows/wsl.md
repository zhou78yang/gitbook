# WSL
WSL, Windows Subsystem Linux

## 更换WSL根目录
默认的根目录位置在用户目录下，具体在      
`C:\Users\{USER}\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu20.04onWindows_79rhkp1fndgsc\LocalState\rootfs`

查看wsl名称
```bash
> wsl --list -v
  NAME                   STATE           VERSION
* Ubuntu-20.04           Running         2
```
*分别表示：名称，状态，WSL版本*

导出镜像
```bash
> wsl --export Ubuntu-20.04 D:\Workspaces\ubuntu.tar
```

移除旧的分发
```bash
> wsl --unregister Ubuntu-20.04
```

导入镜像
```bash
> wsl --import Ubuntu-20.04 D:\Workspaces\ubuntu D:\Workspaces\ubuntu.tar --version 2
```

设为默认
```bash
> wsl --set-default Ubuntu-20.04
```

## 更改默认用户
新import的镜像将默认以root用户启动

官方文档：https://docs.microsoft.com/zh-cn/windows/wsl/wsl-config#change-the-default-user-for-a-distribution

```bash
<DistributionName> config --default-user <Username>
```
*注：可能需要到根目录下执行*