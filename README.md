# Asf_Install_Shell

[![](https://img.shields.io/github/issues/Kiyotaka233/ASF-Install-Shell.svg)](https://github.com/Kiyotaka233/ASF-Install-Shell/issues)
[![](https://img.shields.io/github/forks/Kiyotaka233/ASF-Install-Shell.svg)](https://github.com/Kiyotaka233/ASF-Install-Shell/network/members)
[![](https://img.shields.io/github/stars/Kiyotaka233/ASF-Install-Shell.svg)](https://github.com/Kiyotaka233/ASF-Install-Shell/stargazers)
[![](https://img.shields.io/github/license/Kiyotaka233/ASF-Install-Shell.svg)](https://mit-license.org/)
> 一个在 Linux 中的自动化安装ArchiSteamFarm的脚本。 

![](Logo.png)

[TOC]

## 下载安装

使用前需要先安装dialog和screen  

### CentOS

```sh
yum -y install dialog screen
```

### Ubuntu / Debian

```sh
apt-get -y install dialog screen
```

### 下载、运行脚本

```sh
sudo su 
wget https://github.com/Kiyotaka233/ASF-Install-Shell/releases/download/v0.1.0/asf.sh -O asf.sh
chmod 744 asf.sh
screen -U -S ASF
./asf.sh
```

## 使用示例

有关更多示例和用法, 请参阅[wiki](https://github.com/Kiyotaka233/ASF-Install-Shell/wiki)。

## 平台支持  

Asf_Install_Shell在以下平台中可用：  

- Ubuntu  
  - Ubuntu 14.04  
    - Ubuntu 16.04  
    - Ubuntu 18.04  
- Debian  
  - Debian 8  
    - Debian 9  
- Raspbian  
  - Raspbian 8
    - Raspbian 9
- CentOS
  - CentOS 6
    - CentOS 7
- Fedora
  - Fedora 27

## 更新日志

> 列出了常规版本的功能升级记录，未列出的版本通常为 bug 修复。

* V0.1.0
    * 一键部署ArchiSteamFarm所需要的环境
	* 加入传入参数 (./asf.sh -h)
	* 支持更多系统

* V0.0.5
    * 一键部署ArchiSteamFarm所需要的环境
	* 安装ArchiSteamFarm
	* 配置ArchiSteamFarm
        - [x] 基本配置
        - [x] 挂卡(高级设置)
	* 卸载ArchiSteamFarm  

## 贡献

可以随时新建一个Pull request 或者 issues 写下你的想法^_^  
请先阅读[参与者公约](https://www.contributor-covenant.org/zh-cn/version/1/4/code-of-conduct)  

## 维护

Chenxuan – [@Telegram](https://t.me/Chenxuan_Zhao)  

## 许可证

[MIT License](https://github.com/Kiyotaka233/ASF-Install-Shell/blob/master/LICENSE)  
Copyright (c) 2019 Kiyotaka  