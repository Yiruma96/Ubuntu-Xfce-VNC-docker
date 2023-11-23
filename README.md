# Overview

在`ubuntu:22.04`的基础上，安装中文桌面环境，支持SSH和VNC远程连接
```shell
docker build -t ubuntu-desktop .
docker run -d -p 6022:22 -p 6900:5900 -e PASSWD=123456 -e SIZE=2560x1440 ubuntu-desktop
```
