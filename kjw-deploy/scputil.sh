#!/usr/bin/expect
set iscopytoremote [lindex $argv 0]
set loginname [lindex $argv 1]
set ipaddress [lindex $argv 2]
set password [lindex $argv 3]
set filepath [lindex $argv 4]
set destfilepath [lindex $argv 5]
if { "$iscopytoremote" == "true" } {
 spawn scp $filepath $loginname@$ipaddress:$destfilepath
 expect "*password:"
 send "$password\n"
} else {
   spawn scp $loginname@$ipaddress:$filepath $destfilepath
   expect "*password:"
   send "$password\n"
}
expect eof
