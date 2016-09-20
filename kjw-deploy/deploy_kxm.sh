#!/bins/sh
#!/usr/bin/expect
#############################################
#部署kjw-portal
#############################################
echo "Deploy kxm........"
# 读取配置文件
while read line;do
    eval "$line"
done < config.txt

# 切换到部署根目录
cd /tmp/kjw-deploy/

# 先部署数据库
db_script_path=$kjw_db_ftp_path

# 判断是否以/结尾,如果不是主动加上
if [ "${db_script_path: -1}" != "/" ]; then
	db_script_path=$db_script_path"/"
fi

wget -r $db_script_path
# 切换到脚本目录
cd ${db_script_path/ftp:\/\//}

# 连接到本地oracle数据库执行脚本
echo "quit" | sqlplus sys/sys as sysdba @InstallUpgradeDB.sql


# 下载kxm的zip包
cd /tmp/kjw-deploy/temp
rm -rf kxd-aio-admin.zip
wget $kxm_project_ftp_path"kxd-aio-admin.zip" 

# 将zip包传到相应的服务器上面
expect -f ../scputil.sh true $root_username $kxm_ip $root_password kxd-aio-admin.zip $tomcat_deploy_path

# 解压并替换相应的文件

expect <<-EOF
spawn ssh -l $username $kxm_ip
expect "*password:"
send "$password\n"
expect "$"
send "su - root\n"
expect "Password:"
send "$root_password\n"
expect "#"
send "cd /usr/share/tomcat/webapps/\n"
expect "#"
send "rm -rf kxm\n"
expect "#"
send "unzip -d kxm kxdd-aio-admin.zip\n"
expect "#"
send "cd /usr/share/tomcat/webapps/kxm/WEB-INF/classes/properties\n"
expect "#"
send "sed -i s/kxm.db.url=.*/kxm.db.url=jdbc:oracle:thin:@$oracle_server_ip:1521:ora10g/ application-env.properties\n"
expect "#"
send "cd /usr/share/tomcat/webapps/kxd-kjw-admin/WEB-INF/classes\n"
expect "#"
send "sed -i s/\\\\<ip\\\\>.*/\\\\<ip\\\\>$redis_server_ip\\\\<\\\\\\\\/ip\\\\>/ caches.xml\n"
expect "#"
send "exit\n"
expect eof
EOF
sleep 2s
echo "Deploy kxm Success"

