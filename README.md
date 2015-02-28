# hadoop & spark install toolkit
快速安装高可用 Hadoop & Spark 集群，设置基本配置，让大家迅速上手


## 机器
分两类：master, slave

__master 要求：__
* sshd, python 2, fabric
* 3台即可，建议硬件、软件配置完全相同
* 对硬件性能要求不高，一般服务器都可以满足

**slave 要求：**
* sshd
* 建议3~100台，硬件、软件配置完全相同，存储、CPU、内存越大越好，参考 hadoop, spark 对硬件要求


## 安装过程
1. 下载本项目所有内容到一台 master 机器
2. 编辑配置文件：conf/hosts、conf/config
3. 如果有其它 master 机器，拷贝此目录到其它的 master 机器
4. 去所有的 master 机器，执行如下命令：
`./init-master.sh`
5. 选择一台 master 机器（需要下载安装包），执行如下操作：
```bash
./init-all.sh
```

手工下载软件包到 packages 目录

如果配置了多台 master，则需要安装 zookeeper：
```
./install zookeeper
```

安装其它组件：
```
./install hadoop
./install spark
```

## 启动服务

进入 master 机器的安装目录，比如 /usr/local/myhadoop/
执行 admin.sh 会看到帮助信息
```
> ./admin.sh
Usage: ./admin.sh {zookeeper|hadoop|spark} {start|stop}
```


## TODO 其它辅助
ntp 服务器
Mysql
DNS


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


