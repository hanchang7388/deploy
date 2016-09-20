#!/bins/sh	
if [ -e /usr/bin/expect ]; then
	echo "You Have Expect Command, Skip Installation......"
else
	#安装tcl
	echo "Install Exepect, Please Wait......"
	yum install expect -y
fi