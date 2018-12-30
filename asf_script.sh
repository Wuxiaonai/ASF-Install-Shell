#!/bin/bash

#=================================================
#	System Required: CentOS 7
#	Description: ArchiSteamFarm一键挂卡脚本
#	Version: 0.0.4 
#	Author: 血小板が可爱い
#	Date: 2018/12/30
#=================================================

sh_ver="0.0.4"

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

Error="${red}[错误]${none}"
Warning="${red}[警告]${none}"

ArchiSteamFarmFile="/root/ASF/ArchiSteamFarm" 
Account1File="/root/ASF/config/Account1.json" 

checkRoot(){
	[[ $EUID != 0 ]] && echo -e "${Error} 请使用ROOT账号或使用${green}sudo su${none}命令获取临时的ROOT权限" && exit 1
}

checkSystem(){

	sys_bit=$(uname -m)

	if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
		asf_bit="32"
	elif [[ $sys_bit == "x86_64" ]]; then
		asf_bit="64"
	else
		echo -e "暂时不支持您的系统^_^。" && exit 1
	fi

	# 检测方法RedHat系
	if [[ -f /usr/bin/yum && -f /bin/systemctl ]]; then
		cmd="yum"
		if [[ -f /bin/systemctl ]]; then
			systemd=true
		fi
	else
		echo -e "暂时不支持您的系统。" && exit 1
	fi
}

initScript(){
	dialog --title "欢迎使用" --backtitle "ASF-Install-Shell挂卡脚本" --clear --yesno \
	"
	是否需要运行挂卡脚本？
　　　∩∩
　　（´･ω･）
　  ＿|　⊃／(＿＿_
　／ └-(＿＿＿_／
　￣￣￣￣￣￣￣
" 16 51
	result=$?
	if [ $result -eq 1 ] ; then
	exit 1;
	elif [ $result -eq 255 ]; then
	exit 255;
	fi
	checkRoot
	checkSystem
	cd /root
	clear
}

installArchiSteamFarmInit(){
    #设置DNS
	echo "正在设置DNS"
	echo -e "nameserver 1.1.1.1" > /etc/resolv.conf
	echo -e "nameserver 9.9.9.9" >> /etc/resolv.conf

	#系统更新
	echo "正在运行系统更新"
	rm -f /var/run/yum.pid
	yum -y update && yum -y upgrade

	#安装软件
	echo "正在安装所需软件"
	rpm --import http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	yum-config-manager --add-repo http://download.mono-project.com/repo/centos7/
	yum -y install mono-complete 
	yum -y install wget
	yum -y install icu 
	yum -y install unzip zip 
	yum -y install vim 
	yum -y install gcc 
	yum -y install yum-utils
	yum -y install screen 
	yum -y install ntp
	yum -y install ntpdate
	
	#校准服务器时间
	echo "正在校准服务器时间"
	ntpdate ntp1.aliyun.com
	
	#清理安装缓存
	echo "正在清理安装缓存"
	yum -y clean all
	
	echo "安装完成！"
}

installArchiSteamFarm(){
	#安装 ArchiSteamFarm
	cd /root
	echo "正在下载ArchiSteamFarm，请耐心等待。。。。。。"
	wget https://github.com/JustArchiNET/ArchiSteamFarm/releases/download/3.4.1.7/ASF-linux-x64.zip -O ASF-linux-x64.zip
	echo "正在解压ArchiSteamFarm，请耐心等待。。。。。。"
	unzip ASF-linux-x64.zip -d ASF/
	rm -f /root/ASF-linux-x64.zip
	
	if [ ! -f "$ArchiSteamFarmFile" ]; then 
		echo "ArchiSteamFarm安装失败，请重试！"
	else
		echo "ArchiSteamFarm安装完成！"
	fi 
}

enterSteamID(){
cat /dev/null >/tmp/test.username
dialog --title "SteamLogin" --backtitle "基本配置" --clear --inputbox \
"您的Steam账户用户名:" 16 51 "" 2>/tmp/test.username
result=$?
if [ $result -eq 1 ] ; then
yesno
elif [ $result -eq 255 ]; then
exit 255;
fi
enterSteamPassword
}

enterSteamPassword(){
cat /dev/null >/tmp/test.password
dialog --insecure --title "SteamPassword" --backtitle "基本配置" --clear --passwordbox \
"您的Steam账户密码:" 16 51 "" 2>/tmp/test.password
result=$?
if [ $result -eq 1 ] ; then
enterSteamID
elif [ $result -eq 255 ]; then
exit 255;
fi
finishEnter
}

finishEnter(){
dialog --title "请检查信息是否正确！" --backtitle "基本配置" --clear --yesno \
"账号: $(cat /tmp/test.username)\n 密码: $(cat /tmp/test.password)\n" 16 51
result=$?
if [ $result -eq 1 ] ; then
username
elif [ $result -eq 255 ]; then
exit 255;
fi
}

configArchiSteamFarm(){
	if [ ! -f "$ArchiSteamFarmFile" ]; then
		echo "请先安装ArchiSteamFarm，再配置ArchiSteamFarm！"
	else
		cd /root/ASF
		chmod 777 ArchiSteamFarm
		enterSteamID
		cd /root/ASF/config
		touch Account1.json
		echo -e "{
	"\"SteamLogin\"": "\"$(cat /tmp/test.username)\"",
	"\"SteamPassword\"": "\"$(cat /tmp/test.password)\"",
	"\"Enabled\"": true,
	"\"IsBotAccount\"": false,
	"\"AcceptGifts\"":true,
    "\"OnlineStatus\"":1,
	"\"GamesPlayedWhileIdle\"":[
        570,
        730,
        55100,
        55150,
        207610,
        222880,
        231430,
        233130,
        236870,
        238320,
        261110,
        271590,
        286570,
        292030,
        304390,
        323580,
        359550,
        365450,
        368500,
        431960,
        433850,
        578080
    ],
    "\"FarmingOrders\"":[
        9
    ],
    "\"AutoSteamSaleEvent\"":true
}" > /root/ASF/config/Account1.json
		echo "挂卡账户配置成功！"
	fi 
} 

runArchiSteamFarm(){
	if [ ! -f "$ArchiSteamFarmFile" ]; then
		echo "请先安装ArchiSteamFarm，再运行ArchiSteamFarm！"
	else
		if [ ! -f "$Account1File" ]; then
			echo "请先配置ArchiSteamFarm挂卡账户，再运行ArchiSteamFarm！"
		else 
			cd /root/ASF/
			./ArchiSteamFarm
		fi
	fi
}

uninstallArchiSteamFarm(){
	rm -rf /root/ASF
	if [ ! -f "$ArchiSteamFarmFile" ]; then
		echo "ArchiSteamFarm卸载成功！"
	else
		echo "ArchiSteamFarm卸载失败，请重试！"
	fi
}

initScript
while :; do
	echo && echo -e "  
---- 血小板が可爱い | ArchiSteamFarm一键云挂卡----
${red}[v${sh_ver}]${none}
————————————————————————

${green} 0.${none} 配置运行环境 (第一次运行脚本请选择这个٩( 'ω' )و )
${green} 1.${none} 安装 ArchiSteamFarm
${green} 2.${none} 配置 ArchiSteamFarm
${green} 3.${none} 运行 ArchiSteamFarm
${green} 4.${none} 卸载 ArchiSteamFarm 

————————————————————————
按${red}[ Ctrl + C ]${none}退出脚本" && echo
	stty erase '^H' && read -p "请输入数字 [0-4]:" num
	case "$num" in
		0)
		installArchiSteamFarmInit
		;;
		1)
		installArchiSteamFarm
		;;
		2)
		configArchiSteamFarm
		;;
		3)
		runArchiSteamFarm
		;;
		4)
		uninstallArchiSteamFarm
		;;
	esac
done
