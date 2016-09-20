#!/bins/sh
#####################################################
# 需要传入两个参数
# 参数1：数据为下载的ftp地址
#####################################################
echo "Upgrade KJW Database........"
# 切换到部署根目录
cd /tmp/kjw-deploy/

# 传入ftp的地址
db_script_path=$1

# 判断是否以/结尾,如果不是主动加上
if [ "${db_script_path: -1}" != "/" ]; then
	db_script_path=$db_script_path"/"
fi

# 下载sql文件到temp目录当前
cd temp
rm -rf * 
# 因为是最先执行数据库操作所以这里可以删除所有
wget -r $db_script_path

# 切换到脚本目录
cd ${db_script_path/ftp:\/\//}

# 连接到本地oracle数据库执行upgrade脚本
sqlplus sys/sys as sysdba << EOF
@InstallUpgradeDB.sql;
exit;
EOF

# 导工作日表/buxuyao,zhushidiao
:<<!
cd /tmp/kjw-deploy/
sqlplus sys/sys as sysdba << EOF
@T_XT_WORK_DAY.sql;
commit;
exit;
EOF
!

echo "Upgrade KJW Database Success........" 
