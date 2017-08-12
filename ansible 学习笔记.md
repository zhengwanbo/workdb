
# ansible 学习笔记

## 一、基础知识：

    1. 简介

        ansible基于python开发，集合了众多运维工具的优点，实现了批量系统配置、批量程序部署、批量运行命令等功能。ansible是基于模块工作的，本身没有批量部署的能力。
        真正具有批量部署的是ansible运行的模块，ansible只是一个框架

        (1) 连接插件connection plugins: 负责和被监控端实现通信；
        (2) host inventory: 指定操作的主机，是一个配置文件里面定义监控的主机
        (3) 各种模块核心模块、command模块、自定义模块；
        (4) 借助于插件完成记录日志邮件等功能；
        (5) playbook: 剧本执行多个任务时，非必须可以让节点一次性运行多个任务。

    2、特性：

        (1) no agents: 不需要在被管理主机上安装任务agent
        (2) no server: 无服务器端，使用时，直接运行命令即可
        (3) modules in any languages: 基于模块工作，可使用任意语言开发模块
        (4) yaml not code：使用yaml语言定制剧本playbook
        (5) ssh by default：基于SSH工作
        (6) strong multi-tier solution: 可实现多级指挥

    3、优点：

        (1) 轻量级，无需在客户端安装agent，更新时，只需要在操作机上进行一次更新即可；
        (2) 批量任务可以写成脚本，而且不用分发到远程就可以执行
        (3) 使用python编写，维护简单
        (4) 支持sudo

 

## 二、ansible安装

    1.1 rpm包安装
        epel源：

```
            [epel]
            name=Extra Packages for Enterprise Linux 6 - $basearch
            baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
            #mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
            failovermethod=priority
            enabled=1
            gpgcheck=0
            gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

            [epel-debuginfo]
            name=Extra Packages for Enterprise Linux 6 - $basearch - Debug
            baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch/debug
            #mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch
            failovermethod=priority
            enabled=0
            gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
            gpgcheck=0

            [epel-source]
            name=Extra Packages for Enterprise Linux 6 - $basearch - Source
            baseurl=http://download.fedoraproject.org/pub/epel/6/SRPMS
            #mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch
            failovermethod=priority
            enabled=0
            gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
            gpgcheck=0

        [root@localhost ~]# yum install ansible -y
        
```

1.2 简单配置

> vim /etc/ansible/ansible.cfg    默认配置文件，读取配置文件的顺序是当前目录——当前用户家目录——/etc/ansible/ansible.cfg（该顺序未验证，建议在统一的地方配置，以免混乱）
> #remote_user = root    默认使用的远程连接用户
vim /etc/ansible/hosts    Inventory文件的默认位置，指定所要管理的主机安装

 

1.3 ssh密钥登陆

> ansilbe采用ssh的方式管理节点，为了方便管理，使用密钥方式面密码登陆被管理节点。
1、生成rsa格式密钥
    ssh-keygen -t rsa

> 2、把公钥写入到远端主机的~/.ssh/authorized_keys
    mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
    ssh-copy-id -i ~/.ssh/authorized_keys username@192.168.1.50
> 3、管理机设置默认远程用户
    vim /etc/ansible/ansible.cfg
    remote_user = username

1.4 ansible命令
> 1、ansible    临时的一次性操作
Usage: ansible <host-pattern> [options]
host-pattern可以是域名，IP，也可以在/etc/ansible/hosts指定
options
    -m    后接模块
    -a    后接模块参数
    -u    指定用户名
    -f    启动的并发线程数

> ansible all -m ping
ansible all -m copy -a "src=/etc/fstab dest=/tmp/fatab owner=root group=root mode=644 backup=yes"

常用命令:
> 1、ansible-doc    查看模块文档
    ansible-doc 模块名    模块说明
    ansible-doc -s 模块名    简要说明  
> 2、ansible-playbook    读取事先写好的playbook，可以理解为按一定条件组成的ansible任务集
    Usage: ansible-playbook playbook.yml
> 3、ansible-console    进入类似于shell的交互模式

## 三、常用模块介绍

    copy模块
        目的：把主控本地文件拷贝到远程节点上

```
        [root@localhost ~]# ansible 192.168.118.14 -m copy -a "src=/root/bigfile dest=/tmp"
        192.168.118.14 | SUCCESS => {
            "changed": true, 
            "checksum": "8c206a1a87599f532ce68675536f0b1546900d7a", 
            "dest": "/tmp/bigfile", 
            "gid": 0, 
            "group": "root", 
            "md5sum": "f1c9645dbc14efddc7d8a322685f26eb", 
            "mode": "0644", 
            "owner": "root", 
            "size": 10485760, 
            "src": "/root/.ansible/tmp/ansible-tmp-1467946691.02-193284383894106/source", 
            "state": "file", 
            "uid": 0
        }
```
    file模块
        目的：更改指定节点上文件的权限、属主和属组

```
            [root@localhost ~]# ansible 192.168.118.14 -m file -a "dest=/tmp/bigfile mode=777 owner=root group=root"
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "gid": 0, 
                "group": "root", 
                "mode": "0777", 
                "owner": "root", 
                "path": "/tmp/bigfile", 
                "size": 10485760, 
                "state": "file", 
                "uid": 0
            }
```
    cron模块
        目的：在指定节点上定义一个计划任务，每三分钟执行一次。

```
            [root@localhost ~]# ansible all -m cron -a 'name="Cron job" minute=*/3 hour=* day=* month=* weekday=* job="/usr/bin/ntpdate tiger.sina.com.cn"'
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "envs": [], 
                "jobs": [
                    "Cron job"
                ]
            }
            192.168.118.13 | SUCCESS => {
                "changed": true, 
                "envs": [], 
                "jobs": [
                    "Cron job"
                ]
            }    
```
    group模块
        目的：在远程节点上创建一个组名为ansible，gid为2016的组

```
            [root@localhost ~]# ansible 192.168.118.14 -m group -a "name=ansible gid=2016"
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "gid": 2016, 
                "name": "ansible", 
                "state": "present", 
                "system": false
            }
```
    user模块
        目的：在指定节点上创建一个用户名为ansible，组为ansible的用户

```
            [root@localhost ~]# ansible 192.168.118.14 -m user -a "name=ansible uid=2016 group=ansible state=present"
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "comment": "", 
                "createhome": true, 
                "group": 2016, 
                "home": "/home/ansible", 
                "name": "ansible", 
                "shell": "/bin/bash", 
                "state": "present", 
                "system": false, 
                "uid": 2016
            }
```
        删除远端节点用户，注意：删除远程用户，但是不会删除该用户的家目录

```
            [root@localhost ~]# ansible 192.168.118.14 -m user -a "name=ansible state=absent"
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "force": false, 
                "name": "ansible", 
                "remove": false, 
                "state": "absent"
            }    
```
    yum 模块
        目的：在远程节点安装vsftpd

```
            [root@localhost ~]# ansible 192.168.118.14 -m yum -a 'name=vsftpd state=present'
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "msg": "", 
                "rc": 0, 
                "results": [
                    "Loaded plugins: fastestmirror\nSetting up Install Process\nLoading mirror speeds from cached hostfile\nResolving Dependencies\n--> Running transaction check\n---> Package vsftpd.x86_64 0:2.2.2-14.el6 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package          Arch             Version                  Repository     Size\n================================================================================\nInstalling:\n vsftpd           x86_64           2.2.2-14.el6             yum           152 k\n\nTransaction Summary\n================================================================================\nInstall       1 Package(s)\n\nTotal download size: 152 k\nInstalled size: 332 k\nDownloading Packages:\nRunning rpm_check_debug\nRunning Transaction Test\nTransaction Test Succeeded\nRunning Transaction\n\r  Installing : vsftpd-2.2.2-14.el6.x86_64                                   1/1 \n\r  Verifying  : vsftpd-2.2.2-14.el6.x86_64                                   1/1 \n\nInstalled:\n  vsftpd.x86_64 0:2.2.2-14.el6                                                  \n\nComplete!\n"
                ]
            }
```
        卸载写法：

```
            [root@localhost ~]# ansible 192.168.118.14 -m yum -a 'name=vsftpd state=removed'
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "msg": "", 
                "rc": 0, 
                "results": [
                    "Loaded plugins: fastestmirror\nSetting up Remove Process\nResolving Dependencies\n--> Running transaction check\n---> Package vsftpd.x86_64 0:2.2.2-14.el6 will be erased\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package          Arch             Version                 Repository      Size\n================================================================================\nRemoving:\n vsftpd           x86_64           2.2.2-14.el6            @yum           332 k\n\nTransaction Summary\n================================================================================\nRemove        1 Package(s)\n\nInstalled size: 332 k\nDownloading Packages:\nRunning rpm_check_debug\nRunning Transaction Test\nTransaction Test Succeeded\nRunning Transaction\n\r  Erasing    : vsftpd-2.2.2-14.el6.x86_64                                   1/1 \n\r  Verifying  : vsftpd-2.2.2-14.el6.x86_64                                   1/1 \n\nRemoved:\n  vsftpd.x86_64 0:2.2.2-14.el6                                                  \n\nComplete!\n"
                ]
            }
```
    service模块

```
        启动
            [root@localhost ~]# ansible 192.168.118.14 -m service -a 'name=vsftpd state=started enabled=yes'
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "enabled": true, 
                "name": "vsftpd", 
                "state": "started"
            }                
        停止
            [root@localhost ~]# ansible 192.168.118.14 -m service -a 'name=vsftpd state=stopped enabled=yes'
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "enabled": true, 
                "name": "vsftpd", 
                "state": "stopped"
            }    
```
    ping模块
```

            [root@localhost ~]# ansible 192.168.118.14 -m ping
            192.168.118.14 | SUCCESS => {
                "changed": false, 
                "ping": "pong"
            }
```
    command模块

```
            [root@localhost ~]# ansible 192.168.118.14 [-m command] -a 'w'    # -m command可以省略就表示使用命名模块
            192.168.118.14 | SUCCESS | rc=0 >>
             14:00:32 up  3:51,  2 users,  load average: 0.00, 0.00, 0.00
            USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
            root     pts/0    192.168.118.69   18:09    3:29   0.12s  0.12s -bash
            root     pts/1    192.168.118.13   14:00    0.00s  0.04s  0.00s /bin/sh -c LANG
```
    raw模块
```
        主要的用途是在command中添加管道符号

            [root@localhost ~]# ansible 192.168.118.14 -m raw -a 'hostname | tee'
            192.168.118.14 | SUCCESS | rc=0 >>
            localhost.localdomain
```    
    get_url模块

        目的：将http://192.168.118.14/1.png 下载到本地

```
            [root@localhost ~]# ansible 192.168.118.14 -m get_url -a 'url=http://192.168.118.14/1.png dest=/tmp'
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "checksum_dest": null, 
                "checksum_src": "ba5cb18463ecfa13cdc0b611c9c10875275d883e", 
                "dest": "/tmp/1.png", 
                "gid": 0, 
                "group": "root", 
                "md5sum": "8c0df0b008eb5735dc955171d6d9dd73", 
                "mode": "0644", 
                "msg": "OK (14987 bytes)", 
                "owner": "root", 
                "size": 14987, 
                "src": "/tmp/tmpY2lqHF", 
                "state": "file", 
                "uid": 0, 
                "url": "http://192.168.118.14/1.png"
            }    
```
    synchronize模块

        目的：将主空方目录推送到指定节点/tmp目录下

```
            [root@localhost ~]# ansible 192.168.118.14 -m synchronize -a 'src=/root/test dest=/tmp/ compress=yes'
            192.168.118.14 | SUCCESS => {
                "changed": true, 
                "cmd": "/usr/bin/rsync --delay-updates -F --compress --archive --rsh 'ssh  -S none -o StrictHostKeyChecking=no' --out-format='<<CHANGED>>%i %n%L' \"/root/test\" \"192.168.118.14:/tmp/\"", 
                "msg": ".d..t...... test/\n<f+++++++++ test/abc\n", 
                "rc": 0, 
                "stdout_lines": [
                    ".d..t...... test/", 
                    "<f+++++++++ test/abc"
                ]
            }
```
## 四、ansible playbooks

    4.1 http安装：

```
            - hosts: web
              vars:
                http_port: 80
                max_clients: 256
              remote_user: root

              tasks:
              - name: ensure apache is at the latest version
                yum: name=httpd state=latest
              - name: ensure apache is running
                service: name=httpd state=started
```
    4.2 mysql安装

```
            - hosts: 192.168.118.14
              vars:
                remote_user: root
                max_clients: 256
                mysql_name: "mysql-server"
              tasks:
              - name: ensure install mysql
                yum: name="{{mysql_name}}" state=present
              - name: ensure apache is running
                service: name=mysqld state=started    
```
1. handlers
    用于当关注的资源发生变化时采取一定的操作.


    “notify”这个action可用于在每个play的最后被触发，这样可以避免多次有改变发生时每次都执行指定的操作，取而代之，仅在所有的变化发生完成后一次性地执行指定操作。在notify中列出的操作称为handler，也即notify中调用handler中定义的操作。

```
          1 - hosts: web
          2   remote_user: root
          3   tasks:
          4   - name: install apache
          5     yum: name=httpd
          6   - name: install config
          7     copy: src=/etc/httpd/conf/httpd.conf dest=/etc/httpd/conf/httpd.conf
          8     notify:
          9     - restart httpd        # 这触发 restart httpd 动作
         10   - name: start httpd
         11     service: name=httpd state=started
         12   handlers:
         13   - name: restart httpd
         14     service: name=httpd state=restarted
```
    注意：测试使用ansible2.1版本，每执行一次如上脚本，- name: start httpd都会执行一次，因此可以不用使用handlers

2. 调用setup模块中的变量

          1 - hosts: web
          2   remote_user: root
          3   tasks:
          4   - name: copy file
          5     copy: content="{{ansible_all_ipv4_addresses}}" dest=/tmp/a.txt
3. when 条件判断

```
          1 - hosts: all
          2   remote_user: root
          3   vars:
          4   - username: test
          5   tasks:
          6   - name: create {{ username }} user.
          7     user: name={{ username }}
          8     when: ansible_fqdn == "localhost.localdomain"    # 当条件匹配到，才会创建test用户
```
4. 使用with_items进行迭代

```
          1 - hosts: web
          2   remote_user: root
          3   tasks:
          4   - name: yum install packages
          5     yum: name={{ item.name }} state=present
          6     with_items:
          7       - { name: 'mysql-server' }
          8       - { name: 'vsftpd' }
```
5. template 使用

    使用场景： 当多个服务修改的参数不一致时。

拷贝/etc/httpd/conf/httpd.conf到指定目录，修改Listen使用变量
        Listen {{ http_port }}

在ansible hosts中定义变量
         14 [web]
         15 192.168.2.12 http_port=8000


剧本写法：
          8   - name: install config
          9     template: src=/root/temp/{{http_name}}.j2 dest=/etc/httpd/conf/httpd.conf     # 使用template模块

```
[root@ansible ~]# cat httpd.yml 
- hosts: all
  remote_user: root
  tasks:
  - name: install http
    yum: name=httpd state=present
  - name: copy file
    template: src=/root/httpd.j2 dest=/etc/httpd/conf/httpd.conf 
    notify:
    - restart httpd
  - name: restart httpd
    service: name=httpd state=started

  handlers:
  - name: restart httpd
    service: name=httpd state=restarted
```

[web]
192.168.118.14 ansible_ssh_user=root ansible_ssh_pass=123456 ansible_ssh_port=22 http_port=8888 maxClients=50
[myhost]
192.168.118.49 ansible_ssh_user=root ansible_ssh_pass=123456 ansible_ssh_port=22 http_port=9999 maxClients=100
6. tag的使用
    
    使用场景：当一个playbook只需要执行某一个步骤的时候定义

剧本写法

          9     template: src=/root/temp/{{http_name}}.j2 dest=/etc/httpd/conf/httpd.conf
         10     tags:
         11     - conf
7. roles的用法：

```
        mkdir -pv ansible_playbooks/roles/web/{templates,files,vars,tasks,meta,handlers}
        cp -a /etc/httpd/conf/httpd.conf files/
        vim tasks/main.yml
          1 - name: install httpd
          2   yum: name=httpd
          3 - name: install configuration file
          4   copy: src=httpd.conf dest=/etc/httpd/conf/httpd.conf
          5   tags:
          6   - conf
          7   notify:
          8   - restart httpd
          9 - name: start httpd
         10   service: name=httpd state=started

         vim handlers/main.yml
          1 - name: restart httpd
          2   service: name=httpd state=restarted

        [root@server1 ansible_playbooks]# ls
        roles  site.yml
        [root@server1 ansible_playbooks]# vim site.yml
          1 - hosts: web
          2   remote_user: root
          3   roles:
          4   - web
        [root@server1 ansible_playbooks]ansible-playbook site.yml
```