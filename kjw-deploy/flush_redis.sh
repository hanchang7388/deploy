#!/bin/sh
cd /usr/share/redis-server/redis/src/;./redis-cli << EOF
auth 0ec97cd28f4684ce2f58f233a5c5292d11a66bcd
flushdb
keys *
exit
EOF
echo "redis fulsh db success"
