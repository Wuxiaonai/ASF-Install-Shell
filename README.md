# Asf_Install_Shell
[![](https://img.shields.io/github/issues/Kiyotaka233/ASF-Install-Shell.svg)](https://github.com/Kiyotaka233/ASF-Install-Shell/issues)
[![](https://img.shields.io/github/forks/Kiyotaka233/ASF-Install-Shell.svg)](https://github.com/Kiyotaka233/ASF-Install-Shell/network/members)
[![](https://img.shields.io/github/stars/Kiyotaka233/ASF-Install-Shell.svg)](https://github.com/Kiyotaka233/ASF-Install-Shell/stargazers)
[![](https://img.shields.io/github/license/Kiyotaka233/ASF-Install-Shell.svg)](https://mit-license.org/)
> 一个在 Linux 中的自动化安装ArchiSteamFarm的脚本。 

![](Logo.png)

## 下载安装  
### 平台支持  
Asf_Install_Shell在以下平台中可用：  
   * Linux(CentOS 7+)  
### Linux 安装脚本   
使用前需要先安装dialog和screen  
```sh
yum -y install dialog screen
```

```sh
sudo su 
wget https://github.com/Kiyotaka233/ASF-Install-Shell/releases/download/v0.0.5/asf_linux.sh -O asf_linux.sh
chmod 777 asf_linux.sh
screen -U -S ASF
./asf_linux.sh
```

## 使用示例

有关更多示例和用法, 请参阅wiki。

## 更新日志
> 列出了常规版本的功能升级记录，未列出的版本通常为 bug 修复。

* V0.0.5
    * 一键部署ArchiSteamFarm所需要的环境
	* 安装ArchiSteamFarm
	* 配置ArchiSteamFarm
        - [x] 基本配置
        - [x] 挂卡（高级设置）
	* 卸载ArchiSteamFarm

## 作者

Chenxuan – [@Telegram](https://t.me/Chenxuan_Zhao)