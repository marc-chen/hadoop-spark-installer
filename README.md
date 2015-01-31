# hadoop & spark install toolkit
快速安装高可用 Hadoop & Spark 集群，设置基本配置，让大家迅速上手


## 机器
分两台：master, slave

####master 要求：
* sshd, python 2, fabric
* 3台即可，建议硬件、软件配置完全相同
* 对硬件性能要求不高，一般服务器都可以满足

####slave 要求：
* sshd
* 建议3~100台，硬件、软件配置完全相同，存储、CPU、内存越大越好，参考 hadoop, spark 对硬件要求


## 安装过程
1. 准备机器，写入配置文件 conf/hosts
2. master, slave 分别做简单初始化
3. 编辑配置文件 conf/config，这是必须的最基本配置
4. 选一台 master 做为主安装服务器，执行如下操作：
```bash
    ./install set env
    ./install install zookeeper
    ./install install hadoop
```
5. 在其它 master 上执行操作：
```bash
    ./install set pwd-less-ssh (TODO)
```

## 启动服务

TODO 启动 zookeeper

TODO 启动 hadoop



## 其它辅助
ntp 服务器 TODO



## 适用OS
+ Ubuntu 14.04.1 LTS
+ TODO: Centos 6


## WARN
操作不可逆
TODO: 提供删除脚本，但有些操作不是完全可逆，比如配置用户名、hosts，需要保存之前的状态才能做到准确撤销


## 修改的OS配置：
hostname
/etc/hosts
/etc/profile -> JAVA_HOME
ssh
使用的目录：


