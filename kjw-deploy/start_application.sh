#!/bins/sh
#!/usr/bin/expect
echo "Start Application........"
# 读取配置文件
while read line;do
    eval "$line"
done < config.txt

# 组件数组中默认先加入kjw-portal的ip
app_arr=($kjw_portal_ip)

# 判断元素是否在数组中
check_if_exists_in_arr()
{

    for i in ${app_arr[@]}
    do
    	if [ "$i" == $1 ];then 
           return 1
        fi
    done
}


# 给数组中加追加元素
add_arr_element()
{
	item=$1
	current_length=${#app_arr[@]}
	arr_length=$current_length
	app_arr[arr_length]=$item
}


check_if_exists_in_arr $kjw_admin_ip

if [ $? != 1 ];then
	add_arr_element $kjw_admin_ip $app_arr
fi

echo $app_arr

# 将此文件传入redis机器
expect -f scputil.sh true $root_username $redis_server_ip $root_password flush_redis.sh /tmp
#刷新redis
expect <<-EOF
spawn ssh -l $username $redis_service_ip
expect "*password:"
send "$password\n"
expect "$"
send "su - root\n"
expect "Password:"
send "$root_password\n"
expect "#"
send "exit\n"
expect eof
EOF
