apt-get update
apt-get -y install iptables openvpn openssl lzop git curl gcc wget
myip=`wget -O - http://ipecho.net/plain`

cd /etc/openvpn/


wget https://yzdxqg.wodemo.net/down/20160618/401578/easy-rsa.tar.gz

echo '开始下载项目'
git clone https://github.com/2422494482/mproxy.git
echo '开始导入证书'
tar -zxvf easy-rsa.tar.gz
#cp -r /easy-rsa /etc/openvpn
echo '正在编译mproxy'
gcc -o ./mp ./mproxy/mproxy.c
echo
echo 
echo "写入tcp配置文件"
echo "
local 0.0.0.0
port 443
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
ifconfig-pool-persist ipp.txt
server 10.0.0.0 255.255.0.0
push \"redirect-gateway\"
push \"dhcp-option DNS 114.114.114.114\"
push \"dhcp-option DNS 114.114.115.115\"
client-to-client
client-cert-not-required
username-as-common-name
script-security 3 system
auth-user-pass-verify /etc/openvpn/login.sh via-env
client-disconnect /etc/openvpn/logout.sh
keepalive 20 60
comp-lzo
max-clients 50000
persist-key
persist-tun
status openvpn-status.txt
log-append openvpn.log
verb 3
mute 20
">server.conf
echo "tcp配置文件制作完毕"
echo
echo 
echo "写入udp配置文件"
echo "

local 0.0.0.0
port 137
proto udp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
ifconfig-pool-persist ipp.txt
server 10.1.0.0 255.255.0.0
push "redirect-gateway"
push "dhcp-option DNS 114.114.114.114"
push "dhcp-option DNS 114.114.115.115"
client-to-client
client-cert-not-required
username-as-common-name
script-security 3 system
auth-user-pass-verify /etc/openvpn/login.sh via-env
client-disconnect /etc/openvpn/logout.sh
keepalive 20 60
comp-lzo
max-clients 50000
persist-key
persist-tun
status openvpn-status.txt
log-append openvpn.log
verb 3
mute 20
">server_udp.conf
echo
sleep 3
clear
cp ./mproxy/login.sh ./login.sh
cp ./mproxy/logout.sh ./logout.sh
chmod u+x ./*.sh ./mp
echo "#!/bin/sh
################################
iptables -F
service iptables save
service iptables restart
iptables -t nat -A POSTROUTING -s 192.66.0.0/16 -o eth0 -j MASQUERADE

iptables -A INPUT -p TCP --dport 443 -j ACCEPT #OpenVPN服务端口，可自定义，不可冲突

iptables -A INPUT -p TCP --dport 8080 -j ACCEPT #squid转发端口，可自定义（代理端口）

iptables -A INPUT -p TCP --dport 137 -j ACCEPT

iptables -A INPUT -p TCP --dport 138 -j ACCEPT

iptables -A INPUT -p TCP --dport 22 -j ACCEPT

iptables -t nat -A POSTROUTING -j MASQUERADE

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -j DNAT --to-destination $myip:443

service iptables save

service iptables restart
echo 'net.ipv4.ip_forward=1' >/etc/sysctl.conf
sysctl -p
service openvpn restart
/etc/openvpn/mp -d 8080
/etc/openvpn/mp -l 138 -d
/etc/openvpn/mp -l 137 -d
">/bin/i
chmod a+x /bin/i
i
## ovpn生成
echo 
echo "正在生成移动线路.ovpn配置文件..."
echo "
# 本文件由系统自动生成
client
dev tun
proto tcp
remote wap.10086.cn 80
########免流代码########
http-proxy-option EXT1 \"openvpn 127.0.0.1:443\"
http-proxy-option EXT1 \"X-Online-Host: wap.10086.cn\" 
http-proxy-option EXT1 \"Host: wap.10086.cn\"
http-proxy $myip 8080
########免流代码########
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
ns-cert-type server
redirect-gateway
keepalive 20 60
comp-lzo
verb 3
mute 20
route-method exe
route-delay 2
## 证书
<ca>
`cat ./easy-rsa/2.0/keys/ca.crt`
</ca>
<cert>
`cat ./easy-rsa/2.0/keys/client.crt`
</cert>
<key>
`cat ./easy-rsa/2.0/keys/client.key`
</key>
" >ovpn.ovpn
echo "配置文件制作完毕"
echo "正在创建下载链接：" echo '=========================================================================='
echo ''
echo "上传文件："
curl --upload-file ./ovpn.ovpn https://transfer.sh/openvpn.ovpn
echo ''
echo "上传成功"
echo "请复制“https://transfer.sh/..”链接到浏览器OpenVPN成品配置文件"
echo 
echo '正在设置Cron重启脚本'
#echo '59 23 * * * root service openvpn soft-restart' >>/etc/crontab
echo '=========================================================================='
echo 您的IP是：$myip
echo 正在制作重启脚本
cd /root
echo "
service openvpn restart
/etc/openvpn/mp -d 8080
/etc/openvpn/mp -l 138 -d
/etc/openvpn/mp -l 137 -d
iptables -t nat -A POSTROUTING -s 192.66.0.0/16 -o eth0 -j MASQUERADE

iptables -A INPUT -p TCP --dport 443 -j ACCEPT #OpenVPN服务端口，可自定义，不可冲突

iptables -A INPUT -p TCP --dport 8080 -j ACCEPT #squid转发端口，可自定义（代理端口）

iptables -A INPUT -p TCP --dport 137 -j ACCEPT

iptables -A INPUT -p TCP --dport 138 -j ACCEPT

iptables -A INPUT -p TCP --dport 22 -j ACCEPT

iptables -t nat -A POSTROUTING -j MASQUERADE

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -j DNAT --to-destination $myip:443

service iptables save

service iptables restart
" >restart.sh
chmod u+x ./*.sh
