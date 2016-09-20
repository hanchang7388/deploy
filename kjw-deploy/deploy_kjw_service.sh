#!/bins/sh
#!/usr/bin/expect
#############################################
#部署kjw-service
#############################################
echo "Deploy kjw-service........"
# 读取配置文件
while read line;do
    eval "$line"
done < config.txt

echo $kjw_service_ip

# 切换到部署根目录
cd /tmp/kjw-deploy/

# 传入ftp的地址
kjw_service_ftp_path=$1

# 判断是否以/结尾,如果不是主动加上
if [ "${kjw_service_ftp_path: -1}" != "/" ]; then
	kjw_service_ftp_path=$kjw_service_ftp_path"/"
fi

# 下载kjw-service的zip包
cd /tmp/kjw-deploy/temp
rm -rf kxd-kjw-service.zip
wget $kjw_service_ftp_path"kxd-kjw-service.zip" 

# 将zip包传到相应的服务器上面
expect -f ../scputil.sh true $root_username $kjw_service_ip $root_password kxd-kjw-service.zip $service_deploy_path

# 解压并替换相应的文件
expect <<-EOF
spawn ssh -l $username $kjw_service_ip
expect "*password:"
send "$password\n"
expect "$"
send "su - root\n"
expect "Password:"
send "$root_password\n"        
expect "#"
send "cd /usr/share/\n"
expect "#"
send "rm -rf kxd-kjw-service\n"
expect "#"
send "unzip -d kxd-kjw-service kxd-kjw-service.zip\n"
expect "#"
send "cd /usr/share/kxd-kjw-service/conf/properties\n"
expect "#"
send "sed -i s/db.url=.*/db.url=jdbc:oracle:thin:@$oracle_server_ip:1521:ora10g/ application-env.properties\n"
expect "#"
send "sed -i s/mongodb.host=.*/mongodb.host=$mongo_server_ip/ application-env.properties\n"
expect "#"
send "sed -i s/^dubbo.registry.address=.*/dubbo.registry.address=redis:\\\\\\\\/\\\\\\\\/$dubbo_server_ip:6379/ dubbo.properties\n"
expect "#"
send "sed -i s/^dubbo.monitor.address=.*/dubbo.monitor.address=dubbo:\\\\\\\\/\\\\\\\\/$dubbo_server_ip:7070\\\\\\\\/com.alibaba.dubbo.monitor.MonitorService/ dubbo.properties\n"
expect "#"
send "rm -rf /usr/share/kxd-kjw-service.zip\n"
expect "#"
send "exit\n"
expect eof
EOF
sleep 2s
echo "Deploy kjw-service success......"
