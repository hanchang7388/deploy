#!/bins/sh
#!/usr/bin/expect
#############################################
#部署kjw-admin
#############################################
echo "Deploy kjw-admin........"
# 读取配置文件
while read line;do
    eval "$line"
done < config.txt

echo $kjw_admin_ip

# 切换到部署根目录
cd /tmp/kjw-deploy/

# 传入ftp的地址
kjw_admin_ftp_path=$1

# 判断是否以/结尾,如果不是主动加上
if [ "${kjw_admin_ftp_path: -1}" != "/" ]; then
	kjw_admin_ftp_path=$kjw_admin_ftp_path"/"
fi

# 下载kjw-admin的zip包
cd temp/
rm -rf kxd-kjw-admin.zip
wget $kjw_admin_ftp_path"kxd-kjw-admin.zip" 

# 将zip包传到相应的服务器上面
expect -f ../scputil.sh true $root_username $kjw_admin_ip $root_password kxd-kjw-admin.zip $tomcat_deploy_path

# 解压并替换相应的文件

expect <<-EOF
spawn ssh -l $username $kjw_admin_ip
expect "*password:"
send "$password\n"
expect "$"
send "su - root\n"
expect "Password:"
send "$root_password\n"
expect "#"
send "cd /usr/share/tomcat/webapps/\n"
expect "#"
send "rm -rf kxd-kjw-admin\n"
expect "#"
send "unzip -d kxd-kjw-admin kxd-kjw-admin.zip\n"
expect "#"
send "chown -R tomcat:tomcat *\n"
expect "#"
send "cd /usr/share/tomcat/webapps/kxd-kjw-admin/WEB-INF/classes/properties\n"
expect "#"
send "sed -i s/^dubbo.registry.address=.*/dubbo.registry.address=redis:\\\\\\\\/\\\\\\\\/$dubbo_server_ip:6379/ dubbo.properties\n"
expect "#"
send "sed -i s/^dubbo.monitor.address=.*/dubbo.monitor.address=dubbo:\\\\\\\\/\\\\\\\\/$dubbo_server_ip:7070\\\\\\\\/com.alibaba.dubbo.monitor.MonitorService/ dubbo.properties\n"
expect "#"
send "cd /usr/share/tomcat/webapps/kxd-kjw-admin/WEB-INF/classes\n"
expect "#"
send "sed -i s/\\\\<ip\\\\>.*/\\\\<ip\\\\>$redis_server_ip\\\\<\\\\\\\\/ip\\\\>/ caches.xml\n"
expect "#"
send "rm -rf kxd-kjw-admin.zip\n"
expect "#"
send "exit\n"
expect eof
EOF
sleep 2s
echo "Deploy kjw-admin success......"
