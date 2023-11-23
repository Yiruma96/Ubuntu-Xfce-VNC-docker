# 基础镜像
FROM ubuntu:22.04
# 维护者信息
MAINTAINER mfxie <mfxie@163.com>

# 环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    SIZE=2560x1440 \
    PASSWD=123456 \
    TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=${LANG} \
    LANGUAGE=${LANG}

USER root
WORKDIR /root

# 设定密码
RUN echo "root:$PASSWD" | chpasswd

# 安装
RUN apt-get -y update && \
    # tools
    apt-get install -y build-essential bison libtool python3 xz-utils autoconf automake git pkg-config python3-dev ftp python3-pip texinfo ninja-build firefox firefox-locale-zh-hans cmake libssl-dev openjdk-11-jdk openjdk-11-jre vim git subversion wget curl net-tools locales bzip2 unzip iputils-ping traceroute ttf-wqy-microhei gedit ibus-pinyin tigervnc-standalone-server && \
    locale-gen zh_CN.UTF-8 && \
    # ssh
    apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh && \
    mkdir -p /root/.vnc && \
    echo $PASSWD | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    # xfce
    apt-get install -y xfce4 xfce4-terminal && \
    apt-get purge -y pm-utils xscreensaver* && \
    # xrdp
    apt-get install -y xrdp && \
    echo "xfce4-session" > ~/.xsession && \
    # clean
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 配置xfce图形界面
ADD ./xfce/ /root/

# 创建脚本文件
RUN echo "#!/bin/bash\n" > /root/startup.sh && \
    # 修改密码
    echo 'touch /root/.Xauthority' >> /root/startup.sh && \
    echo 'if [ $PASSWD ] ; then' >> /root/startup.sh && \
    echo '    echo "root:$PASSWD" | chpasswd' >> /root/startup.sh && \
    echo '    echo $PASSWD | vncpasswd -f > /root/.vnc/passwd' >> /root/startup.sh && \
    echo 'fi' >> /root/startup.sh && \
    # SSH
    echo "/usr/sbin/sshd -D & source /root/.bashrc" >> /root/startup.sh && \
    # VNC
    #echo 'vncserver -kill :0' >> /root/startup.sh && \                          # 1.10.1
    #echo '/usr/libexec/vncserver :0' >> /root/startup.sh && \                   # 1.12.0
    # echo 'vncserver :0' >> /root/startup.sh && \
    # echo "rm -rfv /tmp/.X*-lock /tmp/.X11-unix" >> /root/startup.sh && \
    echo 'vncserver :0 -geometry $SIZE -localhost no' >> /root/startup.sh && \
    echo 'tail -f /root/startup.sh' >> /root/startup.sh && \
    # 可执行脚本
    chmod +x /root/startup.sh

# 用户目录不使用中文
RUN LANG=C xdg-user-dirs-update --force


# 导出特定端口
EXPOSE 22 80 443 5900 3389 6001 6002 6003 6004 6005 6006 6007 6008 6009

# 启动脚本
CMD ["/root/startup.sh"]

