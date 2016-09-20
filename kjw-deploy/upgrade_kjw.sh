#!/bins/sh
#############################################
#开金网部署的主程序
#############################################
# 当前目录创建一个temp文件夹,下载的文件都放这里
if [ ! -d "temp" ]; then
  mkdir temp
fi
# 删除目录里所有文件
rm -rf temp/*

# 安装expect
sh install_expect.sh

# 读取配置文件
while read line;do
    eval "$line"
done < config.txt

# upgrade数据库
sh upgrade_kjw_database.sh $kjw_db_ftp_path

# 部署kjw-admin
sh deploy_kjw_admin.sh $kjw_project_ftp_path

# 部署kjw-portal
# sh deploy_kjw_portal.sh $kjw_project_ftp_path

# 部署kjw-service
sh deploy_kjw_service.sh $kjw_project_ftp_path

# 部署apache

# 重启应用
# sh start_application.sh

echo "Upgrade KJW Project Finish......"



