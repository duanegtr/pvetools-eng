![logo](https://upload-images.jianshu.io/upload_images/4171480-4fc23dfbe28b491a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# pvetools
proxmox ve tools script(debian9+ can use it).Including `email`, `samba`,` NFS  set zfs max ram`, `nested virtualization` ,`docker `, `pci passthrough` etc.
for english user,please look the end of readme.

This is a tool script written for proxmox ve (theoretically debian9+ can be used). Including `configuration mail`, `samba`, `NFS`, `zfs`, `nested virtualization`, `docker`, `hard disk passthrough` and other functions。



### Install

##### Chinese users:

###### Method 1: Command line installation

> Requires root account to run

Execute the following line by line in the terminal：

>It is strongly recommended to delete the enterprise source first：`rm /etc/apt/sources.list.d/pve-enterprise.list`

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/duanegtr/pvetools-eng.git
cd pvetools
./pvetools.sh
```

### One-click brainless installation:

```
echo "nameserver  8.8.8.8" >> /etc/resolv.conf && rm -rf pvetools && rm -rf /etc/apt/sources.list.d/pve-enterprise.list && export LC_ALL=en_US.UTF-8 && apt update && apt -y install git && git clone https://github.com/duanegtr/pvetools-eng.git && echo "cd /root/pvetools && ./pvetools.sh" > pvetools/pvetools && chmod +x pvetools/pvetools* && ln -s /root/pvetools/pvetools /usr/local/bin/pvetools && pvetools
```

###### Method 2: Download zip installation

![download](https://upload-images.jianshu.io/upload_images/4171480-49193f4b6f4040fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


- It is recommended to use method one to install. It is not recommended to directly download a single sh script for use, because then the updated function will not be available!

- If the network is unavailable or you have difficulty using the command line, you can use method 2 to download the zip package and copy it into the system for use.。

### Uninstall
1. Delete the downloaded pvetools directory


### Run

Enter the pvetools directory in the shell and enter
`
./pvetools.sh
`
* If prompted that there is no permission, enter `chmod +x ./*.sh`

### Main interface

![main](https://upload-images.jianshu.io/upload_images/4171480-501e3adb625c82fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![main1](https://upload-images.jianshu.io/upload_images/4171480-53fc13764f684c4c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



Just select the corresponding option as needed.

#### Configuration email instructions:

Only in the following interfaces, you need to use the tab key to select the content in the red box. For the rest, just press Enter without thinking.

![mail](https://upload-images.jianshu.io/upload_images/4171480-2ee76fb89c0f253e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



#### If this script helps you, please click the star in the upper right corner^_^

## QQ communication group: 878510703

![qq](http://upload-images.jianshu.io/upload_images/4171480-e0204ead0fb41d5e.jpg)

## If you think it’s good, please donate ^_^
![alipay](https://upload-images.jianshu.io/upload_images/4171480-04c3ebb5c11cfdf9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### v2.3.6

Releases：2023.02.16

new feature:

* Merge the repairs about pci passthrough submitted by netizen "for5million".

##### v2.3.5

Release time: 2022.09.14

new features:

* Fix the problem that docker cannot be installed and replace the installation source of alpine.

##### v2.3.2

Release time: 2022.07.14

new features:

* Added CPU frequency display above the temperature display.
* add cpu frequency display.


##### v2.3.1

Release time: 2022.07.13

* Adjust the power saving mode powersave to conservative.
* change cpufrequtils from 'powersave' to 'conservative'.


##### v2.3.0

Release time: 2022.05.30

new features:

* Fix the impact of the security update source address format change after pve7 (debian 11).
* fix pve7 (debian 11) security source address.

* Add the parameter `iommu=pt pcie_acs_override=downstream` in the configuration of hardware passthrough for pve7 and above versions
* add pve7　grub config `iommu=pt pcie_acs_override=downstream`

* Delete duplicate `set termencoding=unix` in default .vimrc
* delete .vimrc duplicate termencoding setting `set termencoding=unix`

*Add fix to remove subscription reminder
* add reinstall proxmox-widget-toolkit to fix remove subscription failure.

##### v2.2.9

Release time: 2022.05.29

new features:

* Increase the available space of automatic expansion of ROOT partition under common tools. For example, some users use dd and other methods to clone the system disk, and after replacing the large hard disk and restoring the image, they can expand the partition with one click.
* add auto expand / partition size.

##### v2.2.8

Release time: 2021.10.26

new features:

* Optimize the judgment and processing of subscription prompts in pve7.
* fix pve7 subscription note.

##### v2.2.7

Release time: 2021.10.14

new features:

* Add dark mode to pve interface under commonly used tools
* add proxmox ve darkmode interface to manyTools.

##### v2.2.6

Release time: 2021.09.09

new feature:

* Add support for pve7.
* add proxmox ve 7.x support.

##### v2.2.5

Release time: 2020.12.16

new features:

* Optimize the temperature installation prompt judgment logic after pve upgrade.
* update sensors data install.

##### v2.2.4

Release time: 2020.12.14

new features:

* Fix the temperature display interface to be highly adaptive.
* fix sensors display interface.

##### v2.2.3

Release time: 2020.12.09

new features:

* Added automatic backup function for conf files under /etc/pve/qemu-server. You can select the backup path and the number of backups to keep. It is recommended to back up to a virtual machine data disk other than the system partition, so that it can be easily restored after reinstalling the system.


##### v2.2.2

Release time: 2020.11.30

new features:

* According to the suggestion of group friend `Hi I am Cheese`, add the pve update source address as a non-subscription update source



##### v2.2.0

Release time: 2020.08.17

new features:

* Add USB device as system disk optimization, under 'Common Tools'.

##### v2.1.9

Release time: 2020.07.15

new features:

* Added N card vbios prompt function under 'Common Tools'.

##### v2.1.8

Release time: 2020.07.14

new features:

* Fixed the problem of CPU power saving and unable to restore frequency when restoring configuration.


##### v2.1.7

Release time: 2020.05.19

new features:

* Optimize the CPU power saving prompt and solve the problem of not installing cpufrequtils when running again after uninstalling.

##### v2.1.5

Release time: 2020.03.28

new features:

* Solve the problem that docker restart cannot start automatically.

##### v2.1.4

Release time: 2020.02.21

new features:

* Added the functions of releasing memory, speedtest, bbr\bbr+, and v2ray to common tools

##### v2.1.3

Release time: 2019.12.24

new features:

* Optimize the samba recycle bin configuration and automatically prompt whether to enable it when setting up a shared folder; you can add and cancel the recycle bin of a shared folder independently;
* Optimize the temperature display function of the web interface

##### v2.1.2

Release time: 2019.12.18

new features:

* Add samba recycle bin configuration

##### v2.1.1

Release time: 2019.12.16

new features:

* Add dns configuration to common tools


##### v2.1.0

Release time: 2019.12.09

new features:

* Added the ability to directly install omv in pve( [omvInPve](https://github.com/ivanhao/omvinpve))。

##### v2.0.9

Release time: 2019.12.04

new features:

* Added automatic configuration of samba shared folder permissions, no longer need to manually configure permissions; at the same time, deleting the shared folder will automatically restore the original user group permissions.
  It is recommended that users who have used it before can delete the old shared folder first, restore the permissions manually, and then use the tool configuration to add it.

##### v2.0.8

Release time: 2019.11.28

new features:

* Add the function of chroot custom installation path.
* Add the function of chroot docker migration.
 [wiki](https://github.com/duanegtr/pvetools-eng/wiki/m--1-%E9%85%8D%E7%BD%AEdocker-web%E7%95%8C%E9%9D%A2)

##### v2.0.7

Release time: 2019.11.25

new features:

* Add the function of installing NFS.

##### [](https://github.com/duanegtr/pvetools-eng#v206-1)v2.0.6

Release time: 2019.11.20

new features:

* Add commonly used tools, this version adds LAN scanning
* Fix dockerd startup bug
* 
##### [](https://github.com/duanegtr/pvetools-eng#v205)v2.0.5

release time：2019.11.14

new features:

* chroot optimization, increase the judgment of alpine version, optimize speed
* The downloading of packages in the Chinese environment has been changed to the domestic server
* Docker configures domestic sources
*portainer uses docker pull instead to pull the image (previously, tar package deployment was used, and downloading the package on github was too slow)
* Add chroot background management function to detect the operation of chroot
* Delete the pictures in the code directory and change them to simple book picture links


##### v2.0.4
Release time: 2019.11.06

new features:
- Add docker web interface (portainer)
- Remove hidden command output, such as the output of apt-get install, etc.
- chroot optimization


##### v2.0.3
Release time: 2019.11.04

new features:
- Add the function of qm set mapping physical hard disk


##### v2.0.2
Release time: 2019.11.01

new features:
- Added chroot function, Alpine is installed by default
- Added docker function, installed in Alpine by default
- bug fixes

##### v2.0.1
Release time: 2019.10.24

new features:
- Added support for graphics card pass-through


##### v2.0
Release time: 2019.10.01

new features:
- The interface is modified to whiptail, which is more interactive and does not require entering letters to select.
- bug fixes

### installation method

###### 1. command line

##### for english user:

Use root account to run.

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/duanegtr/pvetools-eng.git
cd pvetools
./pvetools.sh
```
>If update error,you can remove enterprise source by : `rm /etc/apt/sources.list.d/pve-enterprise.list` and retry.

###### 2. download

![download](https://upload-images.jianshu.io/upload_images/4171480-49193f4b6f4040fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### Interface

![main](https://upload-images.jianshu.io/upload_images/4171480-501e3adb625c82fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![main1](https://upload-images.jianshu.io/upload_images/4171480-0e0920b58ce482d5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)




### Uninstall
1. delete pvetools folder

### Run
cd to pvetools folder,and type:`./pvetools.sh`
* you should `chmod +x pvetools.sh` first.


#### email configration note：

you should choose `Internet Site` below, and keep others default.

![mail](https://upload-images.jianshu.io/upload_images/4171480-2ee76fb89c0f253e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

