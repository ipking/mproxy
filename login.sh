 if [ -z "`curl http://www.cqlove.win/user/fwqyz.php?user=$username\&pass=$password | grep ^1`" ] ;then

echo $(date +%Y年%m月%d日%k时%M分)"有新的客户端连接 $(date +%Y-%m-%d %k:%M) "ip:"$trusted_ip "端口:"$trusted_port "用户名:"$common_name" >>user_ok.log

exit 1
fi
echo $(date +%Y年%m月%d日%k时%M分) "用户登录失败" "账号:"${username} "密码:"${password}>>user_error.log
exit 0 
