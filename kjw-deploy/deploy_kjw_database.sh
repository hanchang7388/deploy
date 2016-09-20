#!/bins/sh
#####################################################
# 需要传入两个参数
# 参数1：数据为下载的ftp地址
#####################################################
p
echo "Deploy KJW Database........"
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

# 连接到本地oracle数据库执行脚本
sqlplus sys/sys as sysdba << EOF
create tablespace KJW logging datafile '/oracle/ora10/oradata/ora10g/KXD_KJW.dbf' size 200M autoextend on next 100M maxsize unlimited extent management local segment space management auto;
create tablespace KJW_IDX logging datafile '/oracle/ora10/oradata/ora10g/KXD_KJW_IDX.dbf' size 50M autoextend on next 10M maxsize unlimited extent management local segment space management auto;
drop user KXD_KJW cascade;
drop user DB_KXD_KJW cascade;
drop role DB_KXD_KJW_MIN;
exit;
EOF

:<<!
sqlplus sys/sys as sysdba << EOF
@InstallUpgradeDB.sql;
exit;
EOF
!

sqlplus sys/sys as sysdba <<EOF
@01_CREATE_DB_OR_USER.sql;
@02_ERP_SYS_CREATE_OR_ALTER_TABLE.sql;
@02_ERP_WORKFLOW_SYS_CREATE_OR_ALTER_TABLE.sql;
@02_KJW_SYS_CREATE_OR_ALTER_TABLE.sql;
@02_MEMBER_SYS_CREATE_OR_ALTER_TABLE.sql;
@03_ERP_SYS_COMMENTS_ON_TABLE.sql;
@03_KJW_SYS_COMMENTS_ON_TABLE.sql;
@03_MEMBER_SYS_COMMENTS_ON_TABLE.sql;
@04_ERP_SYS_INIT_OR_MODIFY_DATA.sql;
@04_KJW_SYS_INIT_OR_MODIFY_DATA.sql;
@06_SYS_ROLE_PERMISSION.sql;
@07_KXM_SYS_INIT_OR_MODIFY_DATA.sql;
commit;
exit;
EOF


# 导工作日表
cd /tmp/kjw-deploy/
sqlplus sys/sys as sysdba << EOF
@T_XT_WORK_DAY.sql;
commit;
exit;
EOF

echo "Deploy KJW Database Success........" 
