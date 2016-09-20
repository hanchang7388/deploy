#!/bins/sh
#!/usr/bin/expect
#############################################
#部署kjw-portal
#############################################
echo "Deploy kjw-portal........"
# 读取配置文件
while read line;do
    eval "$line"
done < config.txt

# 切换到部署根目录
cd /tmp/kjw-deploy/

# 传入ftp的地址
kjw_portal_ftp_path=$1

# 判断是否以/结尾,如果不是主动加上
if [ "${kjw-portal_ftp_path: -1}" != "/" ]; then
	kjw_portal_ftp_path=$kjw_portal_ftp_path"/"
fi

# 下载kjw-portal的zip包
cd temp/
rm -rf kjw-portal.zip
wget $kjw_portal_ftp_path"kxd-kjw-portal.zip" 

# 将zip包传到相应的服务器上面
expect -f ../scputil.sh true $root_username $kjw_portal_ip $root_password kxd-kjw-portal.zip $tomcat_deploy_path

# 解压并替换相应的文件

expect <<-EOF
spawn ssh -l $username $kjw_portal_ip
expect "*password:"
send "$password\n"
expect "$"
send "su - root\n"
expect "Password:"
send "$root_password\n"
expect "#"
send "cd /usr/share/tomcat/webapps/\n"
expect "#"
send "rm -rf kxd-kjw-portal\n"
expect "#"
send "unzip -d kxd-kjw-portal kxd-kjw-portal.zip\n"
expect "#"
send "cd /usr/share/tomcat/webapps/kxd-kjw-portal/WEB-INF/classes/properties\n"
expect "#"
send "sed -i s/^dubbo.registry.address=.*/dubbo.registry.address=redis:\\\\\\\\/\\\\\\\\/$dubbo_server_ip:6379/ dubbo.properties\n"
expect "#"
send "sed -i s/^dubbo.monitor.address=.*/dubbo.monitor.address=dubbo:\\\\\\\\/\\\\\\\\/$dubbo_server_ip:7070\\\\\\\\/com.alibaba.dubbo.monitor.MonitorService/ dubbo.properties\n"
expect "#"
send "rm -rf kxd-kjw-portal.zip\n"
expect "#"
send "exit\n"
expect eof
EOF
sleep 2s
echo "Deploy kjw-portal Success"

