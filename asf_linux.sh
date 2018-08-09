#!/bin/bash

#=================================================
#	System Required: RedHat/CentOS/Fedora
#	Description: ArchiSteamFarm一键挂卡
#	Version: 0.0.2 (Pre-release)
#	Author: 血小板が可爱い
#=================================================

sh_ver="0.0.2"

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

Error="${red}[错误]${none}"
Warning="${red}[警告]${none}"

ArchiSteamFarmFile="/root/ASF/ArchiSteamFarm" 

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
		echo -e "暂时不支持您的系统。" && exit 1
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

installArchiSteamFarmInit(){
    #设置DNS
	echo "正在设置DNS"
	echo "
	nameserver 1.1.1.1
	nameserver 1.0.0.1
	nameserver 223.5.5.5
	nameserver 223.6.6.6
	" >> /etc/resolv.conf
	
	#系统更新
	echo "正在运行系统更新"
	yum -y update && yum -y upgrade

	#校准服务器时间
	echo "正在校准服务器时间"
	yum -y install ntp ntpdate
	ntpdate ntp1.aliyun.com

	#安装软件
	echo "正在安装所需软件"
	yum -y install unzip zip vim gcc yum-utils screen
	rpm --import http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	yum-config-manager --add-repo http://download.mono-project.com/repo/centos7/
	yum -y install mono-complete
	
	#清理安装缓存
	yum -y clean all
	
	echo "安装完成"
}

installArchiSteamFarm(){
	#安装 ArchiSteamFarm
	echo "正在下载ArchiSteamFarm"
	wget https://github.com/JustArchi/ArchiSteamFarm/releases/download/3.2.0.5/ASF-linux-x64.zip
	echo "正在解压ArchiSteamFarm"
	unzip ASF-linux-x64.zip -d ASF/
	rm -f /root/ASF-linux-x64.zip
	
	if [ ! -f "$ArchiSteamFarmFile" ]; then 
		echo "ArchiSteamFarm安装失败，请重试"
	else
		echo "ArchiSteamFarm安装完成"
	fi 
}

configArchiSteamFarm(){
	cd /root/ASF
	echo "输入你的Steam帐号";
	read SteamID
	echo "输入你的密码";
	read Passord
	cd ASF/config
	touch Account1.json
	echo -e "{
	  "\"SteamLogin\"": "\"$SteamID\"",
	  "\"SteamPassword\"": "\"$Passord\"",
	  "\"Enabled\"": true,
	  "\"IsBotAccount\"": false,
	  "\"FarmOffline\"": true
	}" > /root/ASF/config/Account1.json
	echo "挂卡账户配置成功"
} 

runArchiSteamFarm(){
	echo -e "23.50.18.229 steamcommunity.com" >> /etc/hosts 
	echo && echo -e "
	————————————————————————
	开启ASF挂卡方法命令(先记下来之后再退出脚本)
	按${red}[ Ctrl + C ]${none}退出脚本
	${green}sudo screen -S ASF        ${none}
	${green}cd /root/ASF/             ${none}
	${green}chmod 777 ArchiSteamFarm  ${none}
	${green}./ArchiSteamFarm          ${none}
	
	————————————————————————" && echo 
	sleep 60s
}

uninstallArchiSteamFarm(){
	rm -rf /root/ASF
	echo "ArchiSteamFarm卸载成功"
}

checkRoot
checkSystem
cd /root
clear
while :; do
	echo && echo -e "  
	---- 血小板が可爱い | ArchiSteamFarm一键云挂卡----
	 ${red}[v${sh_ver}](Pre-release)${none}
	————————————————————————
	
	 ${green} 0.${none} 配置 ArchiSteamFarm 运行所需的环境
	 ${green} 1.${none} 安装 ArchiSteamFarm
	 ${green} 2.${none} 配置 ArchiSteamFarm
	 ${green} 3.${none} 运行 ArchiSteamFarm
	 ${green} 4.${none} 卸载 ArchiSteamFarm

	 ————————————————————————
	 按${red}[ Ctrl + C ]${none}退出脚本" && echo
	stty erase '^H' && read -p " 请输入数字 [0-4]:" num
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