#!/bin/bash

#---------------设定变量---------------------------
# SVN仓库名
svn_repo="repo1"
# SVN仓库所在根路径
svn_root="/var/www/svn"
# SVN仓库备份临时根路径
backup_temp_root="/var/tmp/repos-backup"
# 归档文件名
backup_tar_name="${svn_repo}_"`date +%Y%m%d`".tar.gz"

# 备份服务器登录用户名
backup_user="root"
# 备份服务器登录密码
backup_password="richenlin"
# 备份服务器host
backup_host="bev4.enlink-mob.com"
# 备份服务器端口
backup_port="6688"
# 备份服务器备份路径
backup_dir="/usr/local/data/backup_bev6_svn"

# 清空备份临时路径
rm -rf "${backup_temp_root}/*"
# svn全量备份到临时路径
svnadmin hotcopy "${svn_root}/${svn_repo}" "${backup_temp_root}/${svn_repo}"
# 备份svn帐号文件
cp "${svn_root}/passwd" "${backup_temp_root}/passwd"
# 备份授权文件
cp "${svn_root}/authz" "${backup_temp_root}/authz"

# 切换路径
cd "${backup_temp_root}"
# 将备份数据归档
tar zcvf "${backup_tar_name}" ${svn_repo} passwd authz

# 将归档数据传到目的服务器
expect -c "
  set timeout 30;
  spawn scp -P ${backup_port} ${backup_tar_name} ${backup_user}@${backup_host}:${backup_dir};
  expect {
    *yes/no*   {send \"yes\r\"; exp_continue}
    *password* {send \"${backup_password}\r\"; exp_continue}
    *Password* {send \"${backup_password}\r\";}
  } ;"
