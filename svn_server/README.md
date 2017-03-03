## 自行构建的apache svn server docker


### Dockerfile links

- [latest (Dockfile)](https://code.aliyun.com/bj_renyong/mydockfile/raw/master/svn_server/Dockerfile)


### 安装的软件
	1. 基于centos:6
	2. sshd
	3. apache
	4. svn
	5. mod_dav_svn


### 如何使用这个镜像

示例：

    docker run -d -p 80:80 -p 10122:22 -e TZ="Asia/Shanghai" -v /etc/localtime:/etc/localtime:ro -P --name=mysvn registry.cn-hangzhou.aliyuncs.com/bj_renyong/mysvn

这个docker涉及的配置：

| 配置   | 类型   | 说明             |
| ---- | ---- | -------------- |
| 80   | 端口   | apache web访问接口 |
| 22   | 端口   | ssh访问接口        |

----------

### 权限配置

登入docker

创建帐号和密码：

    htpasswd /var/www/svn/passwd 用户名

用户授权：

    vi /var/www/svn/authz

让我这个用户拥有最大的权限：

    [repo1:/]
    renyong=rw

----------

### SVN仓库备份

可通过ssh登录上去进行备份

#### svn备份方案示例

**需求**

1. 对SVN仓库、帐号信息、授权信息每天进行一次全量备份；备份过程中的日志输出到日志文件，以便出现问题时排查。

2. 备份数据归档压缩后上传到另一台备份服务器；备份服务器保留最近一周每天的全量备份数据。




**方案**

- 需要安装缺失的组件：


    yum install -y rsync openssh-clients expect crontabs
- 编写文件svn_backup_full.sh，部署在/usr/local/src/svn_backup目录下，并赋予这个脚本执行权限


- 编写/etc/logrotate.d/svnbackup，用于管理备份过程中的日志

```
    /var/log/svnbackup.log {
      missingok
      notifempty
      size 1M
      weekly
      rotate 5
      create 0600 root root
    }
```

- 配置crontab，每天凌晨3:20分执行全量备份：



```
20 3 * * * /bin/sh /usr/local/src/svn_backup/svn_backup_full.sh >> /var/log/svnbackup.log 2>&1
```

- 解决docker中crontab无法执行的问题
  docker官方提供的centos6镜像中crontab即使安装了也没法执行，解决办法：编辑/etc/pam.d/crond，将其中的required修改为sufficient，然后重启服务crontab:

  ```
  crond -i
  ```

  现在发现每次重启svn docker，都需要进去手动执行crond -i，否则定时任务不会启动，有待改进！


备份服务器维护备份数据，删除过期文件











