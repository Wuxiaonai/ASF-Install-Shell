#!/bin/bash

#=================================================
#	System Required: CentOS 7
#	Description: ArchiSteamFarm一键挂卡脚本(ASF-Install-Shell挂卡脚本)
#	Version: 0.0.5 
#	Author: Kiyotaka233
#	Date: 2019/01/06
#=================================================

sh_ver="0.0.5"

ArchiSteamFarmFile="/usr/bin/ArchiSteamFarm/ArchiSteamFarm"
BotFile="/usr/bin/ArchiSteamFarm/config/Bot.json" 

checkRoot(){
	[[ $EUID != 0 ]] && \
	dialog --title "ASF-Install-Shell挂卡脚本" \
	--msgbox "请使用ROOT账号或使用sudo su命令获取临时的ROOT权限" 10 60 && \
	exit 1
}

checkSystem(){

	sys_bit=$(uname -m)

	if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
		asf_bit="32"
	elif [[ $sys_bit == "x86_64" ]]; then
		asf_bit="64"
	else
		dialog --title "ASF-Install-Shell挂卡脚本" \
		--msgbox "暂时不支持您的系统。" 10 60 && exit 1
	fi

	# 检测方法RedHat系
	if [[ -f /usr/bin/yum && -f /bin/systemctl ]]; then
		cmd="yum"
		if [[ -f /bin/systemctl ]]; then
			systemd=true
		fi
	else
		dialog --title "ASF-Install-Shell挂卡脚本" \
		--msgbox "暂时不支持您的系统。" 10 60 && exit 1
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
	" 15 60
	result=$?
	if [ $result -eq 0 ] ; then
		checkRoot
		checkSystem
	else exit 1
	fi
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
	
	dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "准备完成！" 10  60
}

installArchiSteamFarm(){
	#安装 ArchiSteamFarm
	cd /tmp
	echo "正在下载ArchiSteamFarm，请耐心等待。。。。。。"
	wget https://github.com/JustArchiNET/ArchiSteamFarm/releases/download/3.4.1.7/ASF-linux-x64.zip -O ASF-linux-x64.zip
	echo "正在解压ArchiSteamFarm，请耐心等待。。。。。。"
	unzip ASF-linux-x64.zip -d /usr/bin/ArchiSteamFarm/
	rm -f /tmp/ASF-linux-x64.zip

	if [ ! -f "$ArchiSteamFarmFile" ]; then 
		dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "ArchiSteamFarm安装失败，请重试！" 10 60
	else
		dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "ArchiSteamFarm安装完成！" 10 60
	fi 
}

enterSteamID(){
	cat /dev/null >/tmp/steam.id
	dialog --title "SteamLogin" --backtitle "配置 ArchiSteamFarm" --clear --inputbox \
	"您的Steam账户用户名:" 15 60 "" 2>/tmp/steam.id

	result=$?
	if [ $result -eq 1 ] ; then
		configArchiSteamFarm	
	elif [ $result -eq 255 ]; then
		closeScript
	fi
	enterSteamPassword
}

enterSteamPassword(){
	cat /dev/null >/tmp/test.password
	dialog --insecure --title "SteamPassword" --backtitle "配置 ArchiSteamFarm" --clear --passwordbox \
	"您的Steam账户密码:" 15 60 "" 2>/tmp/steam.pwd
	result=$?
	if [ $result -eq 1 ] ; then
		enterSteamID
	elif [ $result -eq 255 ]; then
		closeScript
	fi
	finishEnter
}

finishEnter(){
	dialog --title "请检查信息是否正确！" --backtitle "配置 ArchiSteamFarm" --clear --yesno \
	"账号: $(cat /tmp/steam.id)\n 密码: $(cat /tmp/steam.pwd)\n" 15 60
	result=$?
	if [ $result -eq 1 ] ; then
		enterSteamID
	elif [ $result -eq 255 ]; then
		closeScript
	fi
}

basicSetting(){
	enterSteamID
	echo -e "{
	"\"SteamLogin\"": "\"$(cat /tmp/steam.id)\"",
	"\"SteamPassword\"": "\"$(cat /tmp/steam.pwd)\"",
	"\"Enabled\"": true,
	" > /usr/bin/ArchiSteamFarm/config/Bot.json
	rm -f /tmp/steam.id /tmp/steam.pwd
}

setStartOnLaunch(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "StartOnLaunch（随程序启动）- bool：默认值为true。该属性定义bot是否在ASF启动后自动启用。通常你会想将其保持在true，如果决定将该属性变更为false，那么需要通过!start在ASF启动后手动启用bot。除非你有理由修改该属性，请将其保持默认。" 20  60	
	dialog --title "高级设置" --menu "StartOnLaunch(随程序启动)" 15 60 2 \
	true "开启 (默认值) " \
	false "关闭" 2> /tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"StartOnLaunch\"": "$(cat /tmp/asf.set)"," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

setCardDropsRestricted(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "CardDropsRestricted（卡牌掉落限制） - bool：默认值为false。该属性定义账户是否限制卡牌掉落。卡牌掉落限制意味着该账号只有在游戏游玩2小时以上才开始掉落卡牌。可惜目前并没有任何魔法手段来侦测此项，所以ASF只能依赖于用户的判断来设定。该属性影响所使用的卡牌掉落算法。设置合理会最大化受益并最大程度减少挂卡的时间。不过目前关于该选项究竟设置true还是false为好没有明确的定论，如果用户不确定是否该设置此项，建议将其保持默认值false，如果你留意到2小时内没有任何卡牌掉落，可以将其修改到true以加速掉落速度。貌似注册较早的账号不需要限制卡牌掉落时间，但这仅仅是理论而已，不该作为规则来用。" 20  60
	dialog --title "高级设置" --menu "CardDropsRestricted（卡牌掉落限制）" 15 60 2 \
	true "开启" \
	false "关闭 (默认值)" 2> /tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"CardDropsRestricted\"": "$(cat /tmp/asf.set)"," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

setFarmOffline(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "FarmOffline（离线挂卡） - bool：默认值为false。离线挂卡对主账号来说极为有用。要知道挂卡会让你的Steam状态显示“当前正在游戏”，这可能会误导你的朋友，让他们以为你真的在玩这款游戏。离线挂卡就能解决这个问题，在你用ASF挂卡时，账号不会显示正在玩某款游戏。这功能归功于ASF本身不需要登陆Steam社区的特性，其实该账号的确在玩这款游戏，只不过是处在“半离线”的模式下。离线挂卡依然会增加被挂游戏的游戏时长，并会在个人资料的“最新动态”中显示出来。另外，为bot启用离线挂卡特性会让其不响应指令（直接），这一点在启用副帐号时较为重要。查看：HandleOfflineMessages" 20  60
	dialog --title "高级设置" --menu "FarmOffline（离线挂卡）" 15 60 2 \
	true "开启" \
	false "关闭 (默认值)" 2> /tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"FarmOffline\"": "$(cat /tmp/asf.set)"," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

setHandleOfflineMessages(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "HandleOfflineMessages（处理离线信息） - bool：默认值为false。当离线挂卡特性启用时，因为并未登陆Steam社区，bot将不会接受来自SteamMasterID的指令。然而，其依然能接收离线信息，也可以进行回复。如果你为副账号使用了离线挂卡特性，将HandleOfflineMessages属性设置为true就可以给离线的bot发送指令。要留心这项特性基于steam离线信息，并会在自动回复后将其标记为已读，因此该选项并不推荐给主账号使用，因为ASF会强制读取并标记所有的离线信息以监听离线指令，这会影响朋友给你发送的离线信息。如果你不确定是否需要启用该特性，请将其保持默认值false。" 20  60
	dialog --title "高级设置" --menu "HandleOfflineMessages（处理离线信息）" 15 60 2 \
	true "开启" \
	false "关闭 (默认值)" 2> /tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"HandleOfflineMessages\"": "$(cat /tmp/asf.set)"," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

setAcceptGifts(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "AcceptGifts（接受礼物） - bool：默认值为false。一旦启用后，ASF将自动接收bot收到的所有礼物，这不仅仅涉及SteamMasterID，也包括其他的账号发来的礼物。如果bot已经拥有该游戏，那么就会被收入库存之中。该选项只推荐为副账号设置，通常你不会想让主账号自动接收所有的礼物。须留意那些通过电子邮件发送的礼物并不通过客户端渠道，所以ASF不会自动接收那些礼物，必须直接将礼物通过账号发送给其他bot才行。如果你不确定是否该启用这项特性，请将其保持默认值false。" 20  60
	dialog --title "高级设置" --menu "AcceptGifts（接受礼物）" 15 60 2 \
	true "开启" \
	false "关闭 (默认值)" 2> /tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"AcceptGifts\"": "$(cat /tmp/asf.set)"," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

setShutdownOnFarmingFinished(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "ShutdownOnFarmingFinished（挂卡结束后关闭） - bool：默认值为false。ASF在启动后会一直“占据”账号。当指定账号挂卡结束后，ASF还会进行周期性检查（IdleFarmingPeriod设定的小时数），如果该账号添加了新游戏，那么将会继续进行挂卡，这过程不用重启进程。这对多数用户来说很有用，毕竟ASF能够自动继续挂卡。然而，你可能会想在账号挂卡结束后停止该进程，那可以将该属性设置为true来实现。启用之后，ASF在挂卡完毕后会注销账号，不会再周期性检查或是启用账号。当全部bot挂卡完毕后，ASF进程也将完全退出。如果你不确定是否该启用这项特性，请将其保持默认值false。" 20  60
	dialog --title "高级设置" --menu "ShutdownOnFarmingFinished（挂卡结束后关闭）" 15 60 2 \
	true "开启" \
	false "关闭 (默认值)" 2> /tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"ShutdownOnFarmingFinished\"": "$(cat /tmp/asf.set)"," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

setShutdownOnFarmingFinished(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "ShutdownOnFarmingFinished（挂卡结束后关闭） - bool：默认值为false。ASF在启动后会一直“占据”账号。当指定账号挂卡结束后，ASF还会进行周期性检查（IdleFarmingPeriod设定的小时数），如果该账号添加了新游戏，那么将会继续进行挂卡，这过程不用重启进程。这对多数用户来说很有用，毕竟ASF能够自动继续挂卡。然而，你可能会想在账号挂卡结束后停止该进程，那可以将该属性设置为true来实现。启用之后，ASF在挂卡完毕后会注销账号，不会再周期性检查或是启用账号。当全部bot挂卡完毕后，ASF进程也将完全退出。如果你不确定是否该启用这项特性，请将其保持默认值false。" 20  60
	dialog --title "高级设置" --menu "ShutdownOnFarmingFinished（挂卡结束后关闭）" 15 60 2 \
	true "开启" \
	false "关闭 (默认值)" 2> /tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"ShutdownOnFarmingFinished\"": "$(cat /tmp/asf.set)"," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

setCustomGamePlayedWhileIdle(){
	cat /dev/null > /tmp/asf.set
	dialog --title "高级设置" --msgbox "CustomGamePlayedWhileIdle（自定义空置游戏） - string：默认值为null。ASF空置时意味着无事可做（比如账号挂卡结束），其依然能显示“非Steam游戏中：CustomGamePlayerdWhileIdle”。默认值null禁用该特性。" 20  60
	dialog --title "CustomGamePlayedWhileIdle（自定义空置游戏）" --backtitle "高级设置" --clear --inputbox \
	"CustomGamePlayedWhileIdle:" 15 60 "贪玩蓝月-传奇大作两周年庆典，古天乐王者归来，全新形象强势代言贪玩蓝月，新版1.85传奇精心打造，传承经典热血延续。" 2>/tmp/asf.set

	result=$? 
	if [ $result -eq 0 ] ; then 
		echo -e "	"\"CustomGamePlayedWhileIdle\"": "\"$(cat /tmp/asf.set)\""," >> /usr/bin/ArchiSteamFarm/config/Bot.json	
	elif [ $result -eq 255 ]; then 
		closeScript
	fi 
	rm -f /tmp/asf.set
}

advancedSettings(){
	setStartOnLaunch
	setCardDropsRestricted
	setFarmOffline
	setHandleOfflineMessages
	setAcceptGifts
	setShutdownOnFarmingFinished
	setCustomGamePlayedWhileIdle
}

chooseSettingMode(){
	dialog --title "配置 ArchiSteamFarm" --backtitle "ASF-Install-Shell挂卡脚本" --clear --yesno \
	"
	是否需要开启高级设置？(小白推荐选否)
	　　　∩∩
	　　（´･ω･）
	　  ＿|　⊃／(＿＿_
	　／ └-(＿＿＿_／
	　￣￣￣￣￣￣￣
	" 15 60
	result=$?
	if [ $result -eq 0 ] ; then
		advancedSettings
	elif [ $result -eq 255 ]; then
		closeScript
	fi
}

configArchiSteamFarm(){
	if [ ! -f "$ArchiSteamFarmFile" ]; then
		dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "请先安装ArchiSteamFarm，再运行ArchiSteamFarm！" 10 60
	else
		cd /usr/bin/ArchiSteamFarm
		chmod 777 ArchiSteamFarm
		cd /usr/bin/ArchiSteamFarm/config
		rm -f ASF.db Bot.db Bot.bin
		touch /usr/bin/ArchiSteamFarm/config/Bot.json
		basicSetting
		chooseSettingMode	
		echo -e "	"\"DismissInventoryNotifications\"": true" >> /usr/bin/ArchiSteamFarm/config/Bot.json			
		echo -e "}" >> /usr/bin/ArchiSteamFarm/config/Bot.json
		dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "配置成功！" 10 60
	fi 
} 

runArchiSteamFarm(){
	if [ ! -f "$ArchiSteamFarmFile" ]; then
		dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "请先安装ArchiSteamFarm，再运行ArchiSteamFarm！" 10 60
	else
		if [ ! -f "$BotFile" ]; then
			dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "请先配置ArchiSteamFarm挂卡账户，再运行ArchiSteamFarm！" 10 60
		else 
			cd /usr/bin/ArchiSteamFarm
			./ArchiSteamFarm
		fi
	fi
}

uninstallArchiSteamFarm(){
	rm -rf /usr/bin/ArchiSteamFarm
	if [ ! -f "$ArchiSteamFarmFile" ]; then
		dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "ArchiSteamFarm卸载成功！" 10 60
	else
		dialog --title "ASF-Install-Shell挂卡脚本" --msgbox "ArchiSteamFarm卸载失败，请重试！" 10 60
	fi
}

closeScript(){
	dialog --title "退出脚本" --backtitle "ASF-Install-Shell挂卡脚本" --clear --yesno \
	"
	是否退出脚本？
	　　　∩∩
	　　（´･ω･）
	　  ＿|　⊃／(＿＿_
	　／ └-(＿＿＿_／
	　￣￣￣￣￣￣￣
	" 15 60
	result=$?
	if [ $result -eq 0 ] ; then
		rm -f /tmp/steam.id /tmp/steam.pwd /tmp/asf.mode /tmp/asf.set		
		kill $$
	elif [ $result -eq 255 ]; then
		exit 255;
	fi
}

mainMenu(){
	cat /dev/null > /tmp/asf.mode
	dialog --title "Kiyotaka233 | ArchiSteamFarm一键云挂卡" \
	--menu "[v${sh_ver}]" 15 60 5 \
	1 "配置运行环境 (第一次运行脚本请选择这个٩( 'ω' )و )" \
	2 "安装 ArchiSteamFarm" \
	3 "配置 ArchiSteamFarm" \
	4 "运行 ArchiSteamFarm" \
	5 "卸载 ArchiSteamFarm " 2> /tmp/asf.mode
	
	result=$?
	if [ $result -eq 1 ] ; then
		closeScript
	elif [ $result -eq 255 ]; then
		closeScript
	fi

	case "$(cat /tmp/asf.mode)" in
		1)
		installArchiSteamFarmInit
		;;
		2)
		installArchiSteamFarm
		;;
		3)
		configArchiSteamFarm
		;;
		4)
		runArchiSteamFarm
		;;
		5)
		uninstallArchiSteamFarm
		;;
	esac

	rm -f /tmp/asf.mode
}

initScript
while :; do
	mainMenu
done
