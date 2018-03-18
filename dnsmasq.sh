

sleep 3
echo " DNSmasq规则更新"
echo
echo -e "下载vokins广告规则"
wget --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf
echo
echo -e "下载easylistchina广告规则"
wget --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt
echo
echo -e "下载yhosts规则"
wget --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt
echo
echo -e "下载malwaredomainlist规则"
wget --no-check-certificate -q -O /tmp/mallist http://www.malwaredomainlist.com/hostslist/hosts.txt && sed -i "s/.$//g" /tmp/mallist
echo
echo -e "下载adaway规则"
wget --no-check-certificate -q -O /tmp/adaway https://adaway.org/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway2 http://winhelp2002.mvps.org/hosts.txt && sed -i "s/.$//g" /tmp/adaway2
wget --no-check-certificate -q -O /tmp/adaway3 http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway4 https://hosts-file.net/ad_servers.txt && sed -i "s/.$//g" /tmp/adaway4
#wget --no-check-certificate -q -O /tmp/adaway5 https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts
cat /tmp/adaway /tmp/adaway2 /tmp/adaway3 /tmp/adaway4 > /tmp/adaway.conf
rm -rf /tmp/adaway /tmp/adaway2 /tmp/adaway3 /tmp/adaway4 #/tmp/adaway5


echo
echo -e "合并dnsmasq、hosts缓存"
cat /tmp/ad.conf /tmp/easylistchina.conf  > /tmp/ad
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist > /tmp/noad
#echo
#echo -e "\e[1;36m 删除dnsmasq、hosts临时文件\e[0m"
rm -rf /tmp/ad.conf /tmp/easylistchina.conf /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist
#echo
#echo -e "\e[1;36m 删除被误杀的广告规则\e[0m"
#wget --no-check-certificate -q -O /tmp/adwhitelist https://raw.githubusercontent.com/clion007/dnsmasq/master/adwhitelist
#sed -i "/#/d" /tmp/adwhitelist
#while read -r
#do
#	sed -i "/$line/d" /tmp/noad
#	sed -i "/$line/d" /tmp/ad
#done < /tmp/adwhitelist
#rm -rf /tmp/adwhitelist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/::1/d' /tmp/ad
sed -i '/localhost/d' /tmp/ad
sed -i '/#/d' /tmp/ad
sed -i '/#/d' /tmp/noad
sed -i '/@/d' /tmp/noad
sed -i '/::1/d' /tmp/noad
sed -i '/localhost/d' /tmp/noad
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/ad
sed -i "s/  / /g" /tmp/ad
sed -i "s/  / /g" /tmp/noad
sed -i "s/	/ /g" /tmp/noad
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/noad
echo
echo -e "\e[1;36m 创建dnsmasq规则文件\e[0m"
echo "
############################################################
## 【Copyright (c) 2014-2017, clion007】                          ##
##                                                                ##
## 感谢https://github.com/vokins/hosts                            ##
##                                                                ##
####################################################################

# Localhost (DO NOT REMOVE) Start
address=/localhost/127.0.0.1
address=/localhost/::1
address=/ip6-localhost/::1
address=/ip6-loopback/::1
# Localhost (DO NOT REMOVE) End

# Modified DNS start" > /root/dns_file
echo
echo -e "\e[1;36m 创建hosts规则文件\e[0m"
echo "
############################################################
## 【Copyright (c) 2014-2017, clion007】                          ##
##                                                                ##
## 感谢https://github.com/vokins/hosts                            ##
##                                                                ##
####################################################################

# 默认hosts开始（想恢复最初状态的hosts，只保留下面两行即可）
127.0.0.1 localhost
::1	localhost
::1	ip6-localhost
::1	ip6-loopback
# 默认hosts结束

# 修饰hosts开始" > /root/hosts_file
echo
echo -e "\e[1;36m 删除dnsmasq'hosts重复规则及临时文件\e[0m"
sort /tmp/ad | uniq >> /root/dns_file
sort /tmp/noad | uniq >> /root/hosts_file
#rm -rf /tmp/ad /tmp/noad
echo "
# Modified DNS end" >> /root/dns_file
echo "vi
# 修饰hosts结束" >> /root/hosts_file
echo
sleep 3
if [ -s "/root/dns_file" ]; then
	if ( ! cmp -s /root/dns_file /tmp/etc/dnsmasq.user/dns_file ); then
		mv -f /root/dns_file /tmp/dnsmasq.user/dns_file
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到ad规则有更新......开始转换规则！"
		/usr/sbin/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: ad规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: ad本地规则和在线规则相同，无需更新！" && rm -f /root/dns_file
	fi	
fi
echo
if [ -s "/root/hosts_file" ]; then
	if ( ! cmp -s /root/hosts_file /tmp/hosts ); then
		mv -f /root/hosts_file /tmp/hosts 
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到noad规则有更新......开始转换规则！"
		/usr/sbin/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: noad规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: noad本地规则和在线规则相同，无需更新！" && rm -f /root/hosts_file
	fi	
fi
echo
echo -e "\e[1;36m 规则更新成功\e[0m"
echo
exit 0


