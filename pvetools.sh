!/bin/bash

#############--Proxmox VE Tools--##########################
#  Author : Duane Garner
#  Mail: dgarner@catalystgroup.gg
#  Version: v2.3.8
#  Github: https://github.com/dgarner-cg/pvetools-eng
########################################################

#js whiptail --title "Success" --msgbox "c" 10 60
if [ `export|grep 'LC_ALL'|wc -l` = 0 ];then
    if [ `grep "LC_ALL" /etc/profile|wc -l` = 0 ];then
        echo "export LC_ALL='en_US.UTF-8'" >> /etc/profile
    fi
fi
if [ `grep "alias ll" /etc/profile|wc -l` = 0 ];then
    echo "alias ll='ls -alh'" >> /etc/profile
    echo "alias sn='snapraid'" >> /etc/profile
fi
source /etc/profile
#-----------------functions--start------------------#
example(){
#msgbox
whiptail --title "Success" --msgbox "
" 10 60
#yesno
if (whiptail --title "Yes/No Box" --yesno "
" 10 60);then
    echo ""
fi
#password
PASSWORD=$(whiptail --title "Password Box" --passwordbox "
Enter your password and choose Ok to continue.
                " 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your password is:" $m
fi


#input form
NAME=$(whiptail --title "
Free-form Input Box
" --inputbox "
What is your pet's name?
" 10 60
Peter
3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo ""
fi

#processing
    apt -y install mailutils
}

smbp(){
m=$(whiptail --title "Password Box" --passwordbox "
Enter samba user 'admin' password:
Please enter the password of the Samba user Admin:
                " 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    while [ true ]
    do
        if [[ ! `echo $m|grep "^[0-9a-zA-Z.-@]*$"` ]] || [[ $m = '^M' ]];then
            whiptail --title "Warnning" --msgbox "
Wrong format!!!   input again:
The password format is wrong! Intersection Intersection Please enter again：
            " 10 60
            smbp
        else
            break
        fi
    done
fi
}

#Modify Debian's mirror source address：
chSource(){
clear
if [ $1 ];then
    #x=a
    whiptail --title "Warnning" --msgbox "Not supported!
    This model is not supported." 10 60
    chSource
fi
sver=`cat /etc/debian_version |awk -F"." '{print $1}'`
currentDebianVersion=${sver}
case "$sver" in
    12 )
        sver="bookworm"
        ;;
    11 )
        sver="bullseye"
        ;;
    10 )
        sver="buster"
        ;;
    9 )
        sver="stretch"
        ;;
    8 )
        sver="jessie"
        ;;
    7 )
        sver="wheezy"
        ;;
    6 )
        sver="squeeze"
        ;;
    * )
        sver=""
esac
if [ ! $sver ];then
    whiptail --title "Warnning" --msgbox "Not supported!
   Your version is not supported!Unable to continue。" 10 60
    main
fi
# debian 11 change security source rule
if [ $currentDebianVersion -gt 10 ];then
    securitySource="
deb https://mirrors.ustc.edu.cn/debian-security/ stable-security main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ stable-security main contrib non-free
"
else
    securitySource="
deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
"
fi
    #"a" "Automation mode." \
    #"a" "无脑模式" \
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config apt source:" 25 60 15 \
    "b" "Change to cn source." \
    "c" "Disable enterprise." \
    "d" "Undo Change." \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configure APT mirror source:" 25 60 15 \
    "b" "Replace it with domestic source" \
    "c" "Close the source of corporate updates" \
    "d" "Restore configuration" \
    "q" "Return to the main menu" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
a | A )
    if (whiptail --title "Yes/No Box" --yesno "Modify to USSTC.edu.cn source, disable enterprises to subscribe to update sources, add non -subscription update sources (USSTC.EDU.CN), modify the Ceph mirror update source" 10 60) then
        if [ `grep "ustc.edu.cn" /etc/apt/sources.list|wc -l` = 0 ];then
            #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
            cp /etc/apt/sources.list /etc/apt/sources.list.bak
            cp /etc/apt/sources.list.d/pve-no-sub.list /etc/apt/sources.list.d/pve-no-sub.list.bak
            cp /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
            cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
            cat > /etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
$securitySource
EOF
            #Modify the PVE 5.X update source address as a non -subscriber renewal source, not using enterprises to subscribe to the update source。
            echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
            #Close PVE 5.X Enterprise Subscribe to Update Source
            sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
           #Modify CEPH mirror update source
            echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/ceph-luminous $sver main" > /etc/apt/sources.list.d/ceph.list

           #For Debian 12
            if [ $bver -gt 11 ];then
                su -c 'echo "APT::Get::Update::SourceListWarnings::NonFreeFirmware \"false\";" > /etc/apt/apt.conf.d/no-bookworm-firmware.conf'
            fi

            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            The software source has been replaced successfully!" 10 60
            apt-get update
            apt-get -y install net-tools
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
The software source has been replaced successfully!" 10 60
        else
            whiptail --title "Success" --msgbox " Already changed apt source to ustc.edu.cn!
The APT source has been replaced ustc.edu.cn" 10 60
        fi
        if [ ! $1 ];then
            chSource
        fi
    fi
    ;;
	b | B  )
        if [ $L = "en" ];then
            OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config apt source:" 25 60 15 \
            "a" "aliyun.com" \
            "b" "ustc.edu.cn" \
            "q" "Main menu." \
            3>&1 1>&2 2>&3)
        else
            OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configure APT mirror source:" 25 60 15 \
            "a" "aliyun.com" \
            "b" "ustc.edu.cn" \
            "q" "返回主菜单" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$OPTION" in
                a )
                    ss="aliyun.com"
                    ;;
                b)
                    ss="ustc.edu.cn"
                    ;;
                q )
                    chSource
            esac
            if (whiptail --title "Yes/No Box" --yesno "Modify the update source as $ss?" 10 60) then
                if [ `grep $ss /etc/apt/sources.list|wc -l` = 0 ];then
                    cp /etc/apt/sources.list /etc/apt/sources.list.bak
                    #cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
                    #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
                    cat > /etc/apt/sources.list << EOF
deb https://mirrors.$ss/debian/ $sver main contrib non-free
deb-src https://mirrors.$ss/debian/ $sver main contrib non-free
deb https://mirrors.$ss/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.$ss/debian/ $sver-updates main contrib non-free
deb https://mirrors.$ss/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.$ss/debian/ $sver-backports main contrib non-free
$securitySource
EOF
                    #Modify the Ceph mirror update source
                    #echo "deb http://mirrors.$ss/proxmox/debian/ceph-luminous $sver main" > /etc/apt/sources.list.d/ceph.list
                    #Modify the PVE update source address to non -subscription update sources, and do not use enterprises to subscribe to the update source.
                    echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
                    whiptail --title "Success" --msgbox " apt source has been changed successfully!
                    The software source has been replaced successfully!" 10 60
                    apt-get update
                    apt-get -y install net-tools
                    whiptail --title "Success" --msgbox " apt source has been changed successfully!
                    The software source has been replaced successfully!" 10 60
                else
                    whiptail --title "Success" --msgbox " Already changed apt source to $ss!
The APT source has been replaced $ss" 10 60
                fi
            else
                chSource
            fi
            chSource
        else
            chSource
        fi
        ;;
    c | C  )
    if (whiptail --title "Yes/No Box" --yesno "Disable Enterprise Subscribe to Update Source?" 10 60) then
        #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
        if [ -f /etc/apt/sources.list.d/pve-no-sub.list ];then
            #Modify the PVE 5.X update source address as a non -subscriber renewal source, not using enterprises to subscribe to the update source
            echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
        else
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            The software source has been replaced successfully!" 10 60
        fi
        if [ `grep "^deb" /etc/apt/sources.list.d/pve-enterprise.list|wc -l` != 0 ];then
            #Close PVE 5.X Enterprise Subscribe to Update Source            sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            The software source has been replaced successfully!"10 60        else
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            The software source has been replaced successfully!"10 60        
        fi
        chSource
    fi
    ;;
d | D )
    cp /etc/apt/sources.list.bak /etc/apt/sources.list
    cp /etc/apt/sources.list.d/pve-no-sub.list.bak /etc/apt/sources.list.d/pve-no-sub.list
    cp /etc/apt/sources.list.d/pve-enterprise.list.bak /etc/apt/sources.list.d/pve-enterprise.list
    #cp /etc/apt/sources.list.d/ceph.list.bak /etc/apt/sources.list.d/ceph.list
    whiptail --title "Success" --msgbox "apt source has been changed successfully!
    The software source has been replaced successfully!"10 60    chSource
    ;;
q )
    echo "q"
    #main
    ;;
esac
fi
}

chMail(){
#set mailutils to send mail
addMail(){
if (whiptail --title "Yes/No Box" --yesno "
Will you want to config mailutils & postfix to send notification?(Y/N):
Is it configured with Mailutils and POSTFIX to send email notifications?" 10 60);then
    qqmail=$(whiptail --title "Config mail" --inputbox "
Input email adress:
Enter the mailbox address:    " 10 60    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ `echo $qqmail|grep '^[a-zA-Z0-9\_\-\.]*\@[A-Za-z0-9\_\-\.]*\.[a-zA-Z\_\-\.]*$'` ];then
                    break
            else
                whiptail --title "Warnning" --msgbox "
Wrong email format!!!   input xxxx@qq.com for example.retry:
The wrong mailbox format! Intersection Intersection Please enter the similar xxxx@qq.com and try it out:                " 10 60
                addMail
            fi
        done
        if [[ ! -f /etc/mailname || `dpkg -l|grep mailutils|wc -l` = 0 ]];then
            apt -y install mailutils
        fi
        {
            echo 10
            sleep 1
            $(echo "pve.local" > /etc/mailname)
            echo 40
            sleep 1
            $(sed -i -e "/root:/d" /etc/aliases)
            echo 70
            sleep 1
            $(echo "root: $qqmail">>/etc/aliases)
            echo 100
            sleep 1
        } | whiptail --gauge "Please wait while installing" 10 60 0
        sleep 1
        dpkg-reconfigure postfix
        service postfix reload
        echo "This is a mail test." |mail -s "mail test" root
        whiptail --title "Success" --msgbox "
Config complete and send test email to you.
Already configured and sent test emails.        " 10 60
        main
    else
        main
    fi
else
    main
fi
}
if [ -f /etc/mailname ];then
    if (whiptail --title "Yes/No Box" --yesno "
It seems you have already configed it before.Reconfig?
You seem to have configured this.Re -configure?    " --defaultno 10 60);then
        addMail
    else
        main
    fi
fi
addMail
}

chZfs(){
#set max zfs ram
setMen(){
    x=$(whiptail --title "Config ZFS" --inputbox "
set max zfs ram 4(G) or 8(G) etc, just enter number or n?
Set the maximum ZFS memory (ZFS_ARC_MAX), such as 4 (g) or 8 (g), etc., you only need to enter pure numbers, such as 4G input 4?    " 20 60    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ "$x" =~ ^[1-9]+$ ]]; then
                    update-initramfs -u
                {
                    $(echo "options zfs zfs_arc_max=$[$x*1024*1024*1024]">/etc/modprobe.d/zfs.conf)
                    echo 10
                    echo 70
                    sleep 1
                    #set rpool to list snapshots
                    $(if [ `zpool get listsnapshots|grep rpool|awk '{print $3}'` = "off" ];then
                        zpool set listsnapshots=on rpool
                    fi)
                    echo 100
                }|whiptail --gauge "installing" 10 60 0
                whiptail --title "Success" --msgbox "
Config complete!you should reboot later.
The configuration is complete, it is best to restart the system in a while.                " 10 60
                break
            else
                whiptail --title "Warnning" --msgbox "
Invalidate value.Please comfirm!
The value of the input is invalid, please re -enter!                " 10 60
                setMen
            fi
        done
        #zfs-zed
        if (whiptail --title "Yes/No Box" --yesno "
    Install zfs-zed to get email notification of zfs scrub?(Y/n):
Install ZFS-ZED to send the results of the ZFS Scrub result reminder email?(Y/n):        " 10 60);then
            if [ `dpkg -l|grep zfs-zed|wc -l` = 0 ];then
                apt-get -y install zfs-zed
            fi
            whiptail --title "Success" --msgbox "
    Install complete!
    Install ZFS-ZED success!
            " 10 60
        else
            chZfs
        fi
    else
        main
    fi
}
if [ ! -f /etc/modprobe.d/zfs.conf ] || [ `grep "zfs_arc_max" /etc/modprobe.d/zfs.conf|wc -l` = 0 ];then
    setMen
else
    if(whiptail --title "Yes/No box" --yesno "
It seems you have already configed it before.Reconfig?
You seem to have configured this.Do you re -configure it?
    " --defaultno 10 60 );then
        setMen
    else
        main
    fi
fi
}

chSamba(){
#config samba
        addSmbRecycle(){
            if(whiptail --title "Yes/No" --yesno "enable recycle?
Open the recovery station?" 10 60 )then
                if [ ! -f '/etc/samba/smb.conf' ];then
                    whiptail --title "Warnning" --msgbox "You should install samba first!
    Please install Samba first!" 10 60
                else
                    if [ `sed -n "/\[$2\]/,/$2 end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` != 0 ];then
                        whiptail --title "Warnning" --msgbox "Already configed!  Already configured. configured." 10 60
                        smbRecycle
                    else
                        cat << EOF > ./recycle
# $2--recycle-start--
vfs object = recycle
recycle:repository = $1/.deleted
recycle:keeptree = Yes
recycle:versions = Yes
recycle:maxsixe = 0
recycle:exclude = *.tmp
# $2--recycle-end--
EOF
                        #n=`sed '/\['$2'\]/' /etc/samba/smb.conf -n|sed -n '$p'`
                        cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
                        sed -i '/\['$2'\]/r ./recycle' /etc/samba/smb.conf
                        rm ./recycle
#                        cat << EOF >> /etc/samba/smb.conf
#[$2-recycle]
#comment = All
#browseable = yes
#path = $1/.deleted
#guest ok = no
#read only = no
#create mask = 0750
#directory mask = 0750
#;  $2-recycle end
#EOF
                        systemctl restart smbd
                        whiptail --title "Success" --msgbox "Done.
    Configuration complete" 10 60
                    fi
                fi
            else
                continue
            fi
        }
        delSmbRecycle(){
            if [ ! -f '/etc/samba/smb.conf' ];then
                whiptail --title "Warnning" --msgbox "You should install samba first!
Please install Samba first!" 10 60
            else
                if [ `sed -n "/\[$1\]/,/$1 end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "Already configed!  已经配置过了。" 10 60
                    smbRecycle
                else
                    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
                    sed -i '/.*'$1'.*recycle.*start/,/.*'$1'.*end/d' /etc/samba/smb.conf
                    sed "/\[${1}\-recycle\]/,/${n}\-recycle end/d" /etc/samba/smb.conf -i
                    systemctl restart smbd
                    whiptail --title "Success" --msgbox "Done.
Configuration complete" 10 60
                fi
            fi
        }

clear
#$(grep -E "^\[[0-9a-zA-Z.-]*\]$|^path" /etc/samba/smb.conf|awk 'NR>3{print $0}'|sed 's/path/        path/'|grep -v '-recycle')
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config samba:" 25 60 15 \
    "a" "Install samba and config user." \
    "b" "Add folder to share." \
    "c" "Delete folder to share." \
    "d" "Config recycle" \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configuration samba:" 25 60 15 \
    "a" "Install and configure Samba and configure Samba users" \
    "b" "Add shared folder" \
    "c" "Cancel the shared folder" \
    "d" "Configuration Recycling Station" \
    "q" "Return to the main menu" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ `grep samba /etc/group|wc -l` = 0 ];then
            if (whiptail --title "Yes/No Box" --yesno "set samba and admin user for samba?
Install Samba and configure Admin as a Samba user？
                " 10 60);then
                apt -y install samba
                groupadd samba
                useradd -g samba -M -s /sbin/nologin admin
                smbp
                echo -e "$m\n$m"|smbpasswd -a admin
                service smbd restart
                echo -e "Successive configuration samba，Please remember the password of the Samba user Admin！"
                whiptail --title "Success" --msgbox "
Successive configuration samba，Please remember samba user admin Password！
                " 10 60
            fi
        else
            whiptail --title "Success" --msgbox "Already configed samba.
Have been configured samba，Nothing to do!
            " 10 60
                    fi
        if [ ! $1 ];then
            chSamba
        fi
        ;;
    b | B )
       # echo -e "Exist share folders:"
       # echo -e "Existing sharing directory:"
       # echo "`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'`"
       # echo -e "Input share folder path:"
       # echo -e "Enter the path of the shared folder:"
       addFolder(){
        h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
        if [ $h -lt 3 ];then
            let h=$h*15
        else
            let h=$h*5
        fi
        x=$(whiptail --title "Add Samba Share folder" --inputbox "
Exist share folders:
Existing sharing directory:
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder path(like /root):
Enter the path of the shared folder (just enter the similar path/root similar path):" $h 60 "" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ ! -d $x ]
            do
                whiptail --title "Success" --msgbox "Path not exist!
The path does not exist!
                " 10 60
                addFolder
            done
            while [ `grep "path \= ${x}$" /etc/samba/smb.conf|wc -l` != 0 ]
            do
                whiptail --title "Success" --msgbox "Path exist!
The path exists!
                " 10 60
                addFolder
            done
            n=`echo $x|grep -o "[a-zA-Z0-9.-]*$"`
            while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
            do
                n=$(whiptail --title "Samba Share folder" --inputbox "
Input share name:
Enter the shared name:
    " 10 60 "" 3>&1 1>&2 2>&3)
                exitstatus=$?
                if [ $exitstatus = 0 ]; then
                    while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
                    do
                        whiptail --title "Success" --msgbox "Name exist!
The name already exists!
                        " 10 60
                        addFolder
                    done
                fi
            done
            oldgrp=`ls -l $x|awk 'NR==2{print $4}'`
            if [ `grep "${x}$" /etc/samba/smb.conf|wc -l` = 0 ];then
                cat << EOF >> /etc/samba/smb.conf
[$n]
comment = All
browseable = yes
path = $x
guest ok = no
read only = no
create mask = 0750
directory mask = 0750
; oldgrp $oldgrp
;  $n end
EOF
                whiptail --title "Success" --msgbox "
Configed!
Configuration is successful!
                " 10 60
                #--2.3.8 add group
                chgrp -R samba $x
                chmod -R g+w $x
                addSmbRecycle $x $n
                service smbd restart
            else
                whiptail --title "Success" --msgbox "Already configed！
Already configured!
                " 10 60
            fi
            addFolder
        else
            chSamba
        fi
}
        addFolder
        ;;
    c )
        delFolder(){
        h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
        if [ $h -lt 3 ];then
            let h=$h*15
        else
            let h=$h*5
        fi
        n=$(whiptail --title "Remove Samba Share folder" --inputbox "
Exist share folders:
Existing sharing directory:
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
Enter the name of the shared folder (only the name in the []]:        " $h 60 "" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
            do
                whiptail --title "Success" --msgbox "
Name not exist!:
Name does not exist!:
                " 10 60
                delFolder
            done
            if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                oldgrp=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf |grep oldgrp|awk '{print $3}'`
                x=`grep -E "^path = [0-9a-zA-Z/-.]*${n}" /etc/samba/smb.conf|awk '{print $3}'`
                if [ $oldgrp ];then
                    chgrp -R $oldgrp $x
                fi
                sed "/\[${n}\]/,/${n} end/d" /etc/samba/smb.conf -i
                sed "/\[${n}-recycle\]/,/${n}-recycle end/d" /etc/samba/smb.conf -i
                whiptail --title "Success" --msgbox "
Configed!
Configuration is successful!
                " 10 60
                service smbd restart
            fi
            delFolder
        else
            chSamba
        fi
    }
        delFolder
        ;;
    d )
        smbRecycle(){
            if [ $L = "en" ];then
                x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config samba recycle:" 12 60 4 \
                "a" "Enable samba recycle." \
                "b" "Disable samba recycle." \
                "c" "Clear recycle." \
                3>&1 1>&2 2>&3)
            else
                x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configuration samba Recycling station!" 12 60 4 \
                "a" "Open the SAMBA recycling station." \
                "b" "Close the SAMBA recycling station." \
                "c" "Clear SAMBA Recycling Station." \
                3>&1 1>&2 2>&3)
            fi
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                case "$x" in
                    a )
                        enSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Remove Samba recycle" --inputbox "
Exist share folders:
Existing sharing directory:
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
Enter the name of the shared folder (only the name in the []]:                            " $h 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
                                do
                                    whiptail --title "Success" --msgbox "
Name not exist!:
Name does not exist!:
                                    " 10 60
                                    enSmbRecycle
                                done
                                if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                                    if [ `sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` != 0 ];then
                                        whiptail --title "Warnning" --msgbox "Already configed!  Already configured." 10 60
                                        smbRecycle
                                    else
                                        x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                        addSmbRecycle $x $n
                                        service smbd restart
                                    fi
                                fi
                                disSmbRecycle
                            else
                                smbRecycle
                            fi
                        }
                        enSmbRecycle
                        ;;
                    b )
                        disSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Remove Samba recycle" --inputbox "
Exist share folders:
Existing sharing directory:
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
Enter the name of the shared folder (only the name in the []]:                            " $h 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
                                do
                                    whiptail --title "Success" --msgbox "
Name not exist!:
Name does not exist!:
                                    " 10 60
                                    disSmbRecycle
                                done
                                x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                if [ `ls $x/.deleted/|wc -l` != 0 ];then
                                    if(whiptail --title "Warnning" --yesno "recycle not empty, you should clear it first.continue?
There are documents in the recycling station. It is recommended to clear it first. Do you confirm that you will continue?" 10 60);then
                                        if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                                            delSmbRecycle $n
                                            service smbd restart
                                        fi
                                        disSmbRecycle
                                    else
                                        disSmbRecycle
                                    fi
                                fi
                            else
                                smbRecycle
                            fi
                        }
                        disSmbRecycle
                        ;;
                    c )
                        checkClearSmb(){
                            c=$(whiptail --title "Clear Samba recycle" --inputbox "
you can disable recycle to clear it.
clear recycle may cause data lose,pvetools will not response for that,do you agree?
type 'YesIdo' to continue:
You can cancel the recycling station first and then empty manually.
The tool is empty, and PVetools will not be responsible for this. Do you agree?
If it is confirmed to be empty, please enter 'YesIdo' to continue：" 20 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ $c != 'YesIdo' ]
                                do
                                    whiptail --title "Success" --msgbox "
Woring words,try again:
Enter the error, please try again:
                                    " 10 60
                                    checkClearSmb
                                done
                            else
                                continue
                            fi
                        }
                        clearSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Clear Samba recycle" --inputbox "
Exist share folders:
Existing sharing directory:
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
Enter the name of the shared folder (only the name in the []]:
                            " $h 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
                                do
                                    whiptail --title "Success" --msgbox "
Name not exist!:
Name does not exist!:
                                    " 10 60
                                    clearSmbRecycle
                                done
                                x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                if [ `ls -a $x/.deleted/|wc -l` -gt 2 ];then
                                    if(whiptail --title "Warnning" --yesno "recycle not empty,continue?
There are files in the recycling station, whether to confirm whether to continue？" 10 60);then
                                        checkClearSmb
                                        rm -rf $x/.deleted/*
                                        rm -rf $x/.deleted/.*
                                        whiptail --title "Success" --msgbox "ok." 10 60
                                    else
                                        clearSmbRecycle
                                    fi
                                else
                                    whiptail --title "Success" --msgbox "Already empty.The recycling station is empty, no need to clear." 10 60
                                fi
                            else
                                smbRecycle
                            fi
                        }
                        clearSmbRecycle
                        ;;
                esac
            else
                chSamba
            fi
        }
        smbRecycle
        ;;

    q )
        main
        ;;
    esac
else
    chSamba
fi
}

chVim(){
#config vim
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config VIM:" 12 60 4 \
    "a" "Install vim & simply config display." \
    "b" "Install vim & config 'vim-for-server'." \
    "c" "Uninstall." \
    3>&1 1>&2 2>&3)
else

    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Installation VIM！" 12 60 4 \
    "a" "Install vim and simply configure, such as color matching number, etc." \
    "b" "Install vim and configure 'vim-for-server'." \
    "c" "Restore configuration." \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
        a )
        if(whiptail --title "Yes/No Box" --yesno "
Install vim & simply config display.Continue?
Install VIM and simply configure, such as color matching line number, etc., basically VIM original flavors.Whether to continue?
            " 10 60) then
            if [ ! -f /root/.vimrc ] || [ `cat /root/.vimrc|wc -l` = 0 ] || [ `dpkg -l |grep vim|wc -l` = 0 ];then
                apt -y install vim
            else
                cp ~/.vimrc ~/.vimrc.bak
            fi
            {
            echo 10
            echo 50
            $(
            cat << EOF > ~/.vimrc
set number
set showcmd
set incsearch
set expandtab
set showcmd
set history=400
set autoread
set ffs=unix,mac,dos
set hlsearch
set shiftwidth=2
set wrap
set ai
set si
set cindent
set tabstop=2
set nocompatible
set showmatch
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set fileformats=unix
set ttyfast
syntax on
set imcmdline
set previewwindow
set showfulltag
set cursorline
set ruler
color ron
autocmd InsertEnter * se cul
set ruler
set showcmd
set laststatus=2
set tabstop=2
set softtabstop=4
inoremap fff <esc>h
autocmd BufWritePost \$MYVIMRC source \$MYVIMRCi
EOF
            )
            echo 100
            }|whiptail --gauge "installing" 10 60
            whiptail --title "Success" --msgbox "
    Install & config complete!
    Installation is complete!
            " 10 60
        else
            chVim
        fi
            ;;
        b | B )
        if(whiptail --title "Yes/No Box" --yesno "
Install vim and configure \'vim-for-server\'(https://github.com/wklken/vim-for-server).
yes or no?
            " 12 60) then
            echo "Use curl or git? If one not work,change to another."
            echo "Select git or curl, if one way does not work, you can change one。"
            echo "1 ) git"
            echo "2 ) curl"
            echo "Please choose:"
            read x
            case $x in
                2 )
                    apt -y install curl vim
                    cp ~/.vimrc ~/.vimrc_bak
                    curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > ~/.vimrc
                    whiptail --title "Success" --msgbox "
            Install & config complete!
            The installation is complete!
                    " 10 60
                    ;;
                1 | "" )
                    apt -y install git vim
                    rm -rf vim-for-server
                    git clone https://github.com/wklken/vim-for-server.git
                    mv ~/.vimrc ~/.vimrc_bak
                    mv vim-for-server/vimrc ~/.vimrc
                    rm -rf vim-for-server
                    whiptail --title "Success" --msgbox "
            Install & config complete!
            The installation is complete!
                    " 10 60
                    ;;
                * )
                    chVim
            esac

        else
            chVim
        fi
            ;;
        c )
            if(whiptail --title "Yes/No Box" --yesno "
Remove Config?
Confirm that you want to restore the configuration?
                " --defaultno 10 60) then
                cp ~/.vimrc.bak ~/.vimrc
                whiptail --title "Success" --msgbox "
Done
Already completed configuration
                " 10 60
            else
                chVim
            fi
    esac
else
    main
fi
}

chSpindown(){
#set hard drivers to spindown
spinTime(){
    x=$(whiptail --title "config" --inputbox "
input number of minite to auto spindown:
Enter the detection time of automatic dormancy in the hard disk, the cycle is minutes, and the input is 5 minutes:
    " 10 60  3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ];then
                whiptail --title "Warnning" --msgbox "
Enter the format error, please re -enter：
                " 10 60
                spinTime
            else
                break
            fi
        done
        cat << eof >> /etc/crontab
*/$x * * * * root /root/hdspindown/spindownall
eof
        service cron reload
        whiptail --title "Success" --msgbox "
config every $x minite to check disks and auto spindown:
I have configured the hard disk every hard disk every$X -minutes automatically detect hard disks and dormant.
        " 10 60
    fi
}
doSpindown(){
    if(whiptail --title "Yes/No Box" --yesno "
    Config hard drives to auto spindown?(Y/n):
    Configure the hard disk automatic dormant？(Y/n):
    " 10 60) then
        if [ `dpkg -l|grep git|wc -l` = 0 ];then
            apt -y install git
        fi
        cd /root
        git clone https://github.com/ivanhao/hdspindown.git
    {
        echo 10
        echo 50
        echo 90
        cd hdspindown
        chmod +x *.sh
        ./spindownall
        echo 100
    }   | whiptail --gauge "installing" 10 60 0
        if [ `grep "spindownall" /etc/crontab|wc -l` = 0 ];then
            spinTime
        fi
    else
        chSpindown
    fi
}
chApm(){
    clear
    apm=$(
    whiptail --title " PveTools   Version : 2.3.8 " --menu "Config hard disks APM & AAM:
Configure hard disk quietness and cooling：
    " 25 60 15 \
    "128" "Config hard drivers to auto spindown." \
    "b" "Remove config hdspindown." \
    "c" "Config pvestatd service(in case of spinup drives)." \
    "d" "Config drivers aam\apm to low temp and quiet." \
    3>&1 1>&2 2>&3)
}

if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config hard disks spindown:" 25 60 15 \
    "a" "Config hard drivers to auto spindown." \
    "b" "Remove config hdspindown." \
    "c" "Config pvestatd service(in case of spinup drives)." \
    "d" "Config drivers aam\apm to low temp and quiet." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configure the hard disk automatic dormant" 25 60 15 \
    "a" "Configure the hard disk automatic dormant" \
    "b" "Restore the hard disk automatic dormant configuration" \
    "c" "ConfigurationpvestatdServices (prevent waking up immediately after dormant)。" \
    "d" "Set the mute and cooling of the hard disk" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ ! -f /root/hdspindown/spindownall ];then
            doSpindown
        else
            whiptail --title "Yes/No Box" --msgbox "
It seems you have already configed it before.
You seem to have configured this.
                " 10 60
            chSpindown
        fi
        ;;
    b )
        if(whiptail --title "Yes/No Box" --yesno "
Remove config spindown?
Confirm that you want to restore the configuration?
        " 10 60) then
            sed -i '/spindownall/d' /etc/crontab
            rm /usr/bin/hdspindown
            if(whiptail --title "Yes/No Box" --yesno "
Remove source code?
Do you want to delete the dormant program code?
            " 10 60) then
                rm -rf /root/hdspindown
            fi
            whiptail --title "Success" --msgbox "
OK
Already completed configuration
            " 10 60
        else
            chSpindown
        fi
        ;;
    c )
        if (whiptail --title "Enable/Disable pvestatd" --yes-button "stop(Disable)" --no-button "start up(Enable)"  --yesno "
pvestatd may spinup the drivers,if hdspindown can not effective, you can disable it to make drives to spindown.
When using LVM, PVESTATD may cause frequent wake -up hard disks, causing HDSPINDOWN to not make your hard disk dormant. If you need it, you can stop this service here.
Stop this service will display some abnormalities on the web interface. If you need to operate on the web interface, you can start this service again.This operation is not necessary, you have to apply it flexibly by yourself。
        " 20 60) then
        {
            pvestatd stop
            echo 100
            sleep 1
        }|whiptail --gauge "configing..." 10 60 50
        else
        {
            pvestatd start
            echo 100
            sleep 1
        }|whiptail --gauge "configing..." 10 60 50
        fi
        ;;
    esac
fi
}

chCpu(){
maxCpu(){
    info=`cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'`
    x=$(whiptail --title "Max cpufrequtils Maximum frequency" --inputbox "
$info
--------------------------------------------
Input MAX_SPEED(example: 1.6GHz type 1600000):
Enter the maximum frequency (example：1.6GHz enter 1600000）：
    " 20 60  3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ]] || [[ $x = "" ]];then
                whiptail --title "Warnning" --msgbox "
example: 1.6GHz type 1600000
retry
Exemplary example：1.6GHz 输入1600000
Enter the format error, please re -enter：
                " 15 60
                maxCpu
            else
                break
            fi
        done
        mx=$x
    else
        chCpu
    fi
}
minCpu(){
    x=$(whiptail --title "Mini cpufrequtils Minimum frequency" --inputbox "
$info
--------------------------------------------
Input MIN_SPEED(example: 1.6GHz type 1600000):
Enter the minimum frequency (example：1.6GHz enter1600000）：
    " 20 60   3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ]] || [[ $x = "" ]];then
                whiptail --title "Warnning" --msgbox "
example: 1.6GHz type 1600000
retry
Exemplary example ：1.6GHz enter 1600000
Enter the format error, please re -enter：
                " 15 60
                minCpu
            else
                break
            fi
        done
        mi=$x
    else
        chCpu
    fi
}

#setup for cpufreq
doChCpu(){
if(whiptail --title "Yes/No Box" --yesno "
Install cpufrequtils to save power?
Installation CPU -saving?
" --defaultno 10 60) then
    apt -y install cpufrequtils
    if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak 's|quiet|quiet intel_pstate=disable|' /etc/default/grub
        update-grub
    fi
    cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'
    maxCpu
    minCpu
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="conservative"
MAX_SPEED="$mx"
MIN_SPEED="$mi"
EOF
    whiptail --title "Success" --msgbox "
cpufrequtils need to reboot to apply! Please reboot.
cpufrequtils After installation, you need to restart the system, please restart later.
    " 10 60
else
    main
fi
}
doChCpu1(){
if(whiptail --title "Yes/No Box" --yesno "
continue?
Start configuration?
" --defaultno 10 60) then
    cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'
    maxCpu
    minCpu
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="performance"
MAX_SPEED="$mx"
MIN_SPEED="$mi"
EOF
    systemctl restart cpufrequtils
    whiptail --title "Success" --msgbox "
Done
Configuration complete
    " 10 60
else
    main
fi
}
#-------------chCpu--main---------------
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Config cpufrequtils to save power." \
    "b" "Remove config." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Installation CPU Power saving" 25 60 15 \
    "a" "Installation CPU Power saving (dynamic adjustment)" \
    "b" "Restore configuration" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
            doChCpu
        else
            if(whiptail --title "Yes/No Box" --yesno "
        It seems you have already configed it before.
        You seem to have configured this.
            " --defaultno 10 60) then
                doChCpu
            else
                main
            fi
        fi
        ;;
    c )
        if(whiptail --title "Yes/No" --yesno "
continue?
Restore configuration?
        " --defaultno 10 60 ) then
            #sed -i 's/ intel_pstate=disable//g' /etc/default/grub
            #rm -rf /etc/default/cpufrequtils
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="ondemand"
EOF
            systemctl restart cpufrequtils
            if (whiptail --title "Yes/No" --yesno "
Uninstall cpufrequtils?
Uninstalled cpufrequtils?
                " 10 60 ) then
                apt -y remove cpufrequtils 2>&1 &
                sed -i 's/ intel_pstate=disable//g' /etc/default/grub
                rm -rf /etc/default/cpufrequtils
            fi
            whiptail --title "Success" --msgbox "
Done
Configuration complete
            " 10 60
        fi
        chCpu
        ;;
    b )
        doChCpu1
        ;;
    esac
fi
#-------------chCpu--main--end------------

}

chSubs(){
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Remove subscribe notice." \
    "b" "Unset config." \
    "c" "fix proxmox-widget-toolkit" \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Install CPU power saving" 25 60 15 \
    "a" "Remove the subscription prompt" \
    "b" "Restore configuration" \
    "c" "Repair removal of subscription failure" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a )
        if(whiptail --title "Yes/No" --yesno "
continue?
Whether to remove the subscription prompt?
            " 10 60 )then
            #whiptail --title " in " --msgbox "$bver $cver  $dver" 10 60
            if [ `grep "data.status.toLowerCase() !== 'active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` -gt 0 ];then
                sed -i.bak "s/data.status.toLowerCase() !== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                systemctl restart pveproxy
                whiptail --title "Success" --msgbox "
Done!!
Remove success!
                " 10 60
            elif [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` -gt 0 ];then
                sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                systemctl restart pveproxy
                whiptail --title "Success" --msgbox "
Done!!
Remove success!
                " 10 60
            else
                whiptail --title "Success" --msgbox "
You already removed.
It has been removed and there is no need to remove it again.
                " 10 60
            fi
        fi
        ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
continue?
Whether to restore subscription prompts?
            " 10 60) then
            if [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 0 ];then
                mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                systemctl restart pveproxy
                whiptail --title "Success" --msgbox "
Done!!
Restore successfully!
                " 10 60
            elif [ `grep "data.status.toLowerCase() !== 'active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 0 ];then
                mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                systemctl restart pveproxy
                whiptail --title "Success" --msgbox "
Done!!
Restore successfully!
                " 10 60
            else
                whiptail --title "Success" --msgbox "
You already removed.
Already restored, no need to restore again.
                " 10 60
            fi
        fi
        ;;
    c )
        if(whiptail --title "Yes/No" --yesno "
continue?
Whether to repair the subscription prompt?
            " 10 60) then
            apt install --reinstall proxmox-widget-toolkit
            whiptail --title "Success" --msgbox "
Done!!
Restore successfully!
                " 10 60
        fi
        ;;
    esac
fi
}
chSmartd(){
  hds=`lsblk|grep "^[s,h]d[a-z]"|awk '{print $1}'`
}

chNestedV(){
clear
unsetVmN(){
    list=`qm list|awk 'NR>1{print $1":"$2"......."$3" "}'`
    ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}';done`
    h=`echo $ls|wc -l`
    let h=$h*1
    if [ $h -lt 30 ];then
        h=30
    fi
    list1=`echo $list|awk 'NR>1{print $1}'`
    vmid=$(whiptail  --title " PveTools   Version : 2.3.8 " --menu "
Choose vmid to unset nested:
Select VM that needs to be closed with nested virtualization:" 25 60 15 \
    $(echo $ls) \
     3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
You chose:$vmid ,Whether to continue?
            " 10 60)then
            while [ true ]
            do
                if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
Enter the format error, please re -enter:                    " 10 60
                    setVmN
                else
                    break
                fi
            done
            if [ `qm showcmd $vmid|grep "+vmx"|wc -l` = 0 ];then
                whiptail --title "Success" --msgbox "
    You already unseted.Nothing to do.
    Your virtual machine has not opened nested virtualization support.
                " 10 60
            else
                args=`qm showcmd $vmid|grep "\-cpu [0-9a-zA-Z,+_]*" -o`
                sed -i '/,+vmx/d' /etc/pve/qemu-server/$vmid.conf
                echo  "args: "$args >> /etc/pve/qemu-server/$vmid.conf
                whiptail --title "Success" --msgbox "
    Unset OK.Please reboot your vm.
    Your virtual machine has turned off nested virtualization support.Effective after restarting the virtual machine.
                " 10 60
            fi
        else
            chNestedV
        fi
    else
        chNestedV
    fi
}
setVmN(){
    list=`qm list|awk 'NR>1{print $1":"$2"......."$3" "}'`
    ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}';done`
    h=`echo $ls|wc -l`
    let h=$h*1
    if [ $h -lt 30 ];then
        h=30
    fi
    list1=`echo $list|awk 'NR>1{print $1}'`
    vmid=$(whiptail  --title " PveTools   Version : 2.3.8 " --menu "
Choose vmid to set nested:
Select VM that needs to be configured with nested virtualization:" 25 60 15 \
    $(echo $ls) \
     3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
You chose:$vmid , Whether to continue?
            " 10 60)then
            while [ true ]
            do
                if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
    Enter the format error, please re -enter：
                    " 10 60
                    setVmN
                else
                    break
                fi
            done
            if [ `qm showcmd $vmid|grep "+vmx"|wc -l` = 0 ];then
                args=`qm showcmd $vmid|grep "\-cpu [0-9a-zA-Z,+_]*" -o`
                for i in 'boot:' 'memory:' 'core:';do
                    if [ `grep '^'$i /etc/pve/qemu-server/$vmid.conf|wc -l` -gt 0 ];then
                        con=$i
                        break
                    fi
                done
                sed "/"$con"/a\args: $args,+vmx" -i /etc/pve/qemu-server/$vmid.conf
                #echo "args: "$args",+vmx" >> /etc/pve/qemu-server/$vmid.conf
                whiptail --title "Success" --msgbox "
    Nested OK.Please reboot your vm.
    Your virtual machine has opened the support of nested virtualization.Effective after restarting the virtual machine.
                " 10 60
            else
                whiptail --title "Success" --msgbox "
    You already seted.Nothing to do.
    Your virtual machine has opened nested virtualization support.
                " 10 60
            fi
        else
            chNestedV
        fi
    else
        chNestedV
    fi
}
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config Nested:" 25 60 15 \
    "a" "Enable nested" \
    "b" "Set vm to nested" \
    "c" "Unset vm nested" \
    "d" "Disable nested" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "配置嵌套虚拟化:" 25 60 15 \
    "a" "Open the nested virtualization" \
    "b" "Open the nested virtualization of a virtual machine" \
    "c" "Turn off the nested virtualization of a virtual machine" \
    "d" "Turn off nested virtualization" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
        a )
            if(whiptail --title "Yes/No" --yesno "
Are you sure to enable Nested?
It will stop all your runnging vms (Y/n):
Are you sure you want to open the nested virtualization?
This operation will stop all the virtual machines in your current operation!(Y/n):
            " 10 60) then
                if [ `cat /sys/module/kvm_intel/parameters/nested` = 'N' ];then
                    for i in `qm list|awk 'NR>1{print $1}'`;do
                        qm stop $i
                    done
                    modprobe -r kvm_intel
                    modprobe kvm_intel nested=1
                    if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                        echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf
                        whiptail --title "Success" --msgbox "
Nested ok.
You have opened nested virtualization.
                        " 10 60
                    else
                        whiptail --title "Warnning" --msgbox "
Your system can not open nested.
Your system does not support nested virtualization.
                        " 10 60
                    fi
                else
                    whiptail --title "Warnning" --msgbox "
You already enabled nested virtualization.
You have opened nested virtualization.
                    " 10 60
                fi
            fi
            chNestedV
            ;;
        b )
            if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                if [ `qm list|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
You have no vm.
You have no virtual machine yet.
                    " 10 60
                else
                    setVmN
                fi
                chNestedV
            else
                whiptail --title "Warnning" --msgbox "
Your system can not open nested.
Your system does not support nested virtualization.
                " 10 60
                chNestedV
            fi
            ;;
        c )
            if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                if [ `qm list|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
You have no vm.
You have no virtual machine yet.
                    " 10 60
                else
                    unsetVmN
                fi
                chNestedV
            else
                whiptail --title "Warnning" --msgbox "
Your system can not open nested.
Your system does not support nested virtualization.
                " 10 60
                chNestedV
            fi
            ;;
        q )
            main
            ;;
    esac
else
    main
fi
}
chSensors(){
#install lm-sensors
#for i in `sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`;do modprobe $i;done
clear
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config lm-sensors & proxmox ve display:" 25 60 15 \
    "a" "Install." \
    "b" "Uninstall." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Sensors:" 25 60 15 \
    "a" "installation configuration temperature、CPU frequency display" \
    "b" "Delete configuration" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        if(whiptail --title "Yes/No" --yesno "
Your OS：$pve, you will install sensors interface, continue?(y/n)
Your system is：$pve, you will install sensorsinterface，Whether to continue？(y/n)
            " 10 60) then
            js='/usr/share/pve-manager/js/pvemanagerlib.js'
            pm='/usr/share/perl5/PVE/API2/Nodes.pm'
            sh='/usr/bin/s.sh'
            ppv=`/usr/bin/pveversion`
            OS=`echo $ppv|awk -F'-' 'NR==1{print $1}'`
            ver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
            bver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'`
            pve=$OS$ver
            mkdir /etc/pvetools/
            if [ ! -f $js ];then
                cp $js /etc/pvetools/pvemanagerlib.js
            fi
            if [ ! -f $pm ];then
                cp $pm /etc/pvetools/Nodes.pm
            fi
            if [[ "$OS" != "pve" ]];then
                whiptail --title "Warnning" --msgbox "
Your system is not Proxmox Ve, you can't install it!
Your OS is not Proxmox VE!
                " 10 60
                if [[ "$bver" != "5" || "$bver" != "6" || "$bver" != "7" ]];then
                    whiptail --title "Warnning" --msgbox "
Your system version cannot be installed!
Your Proxmox VE version can not install!
                    " 10 60
                    main
                fi
                main
            fi
            if [[ ! -f "$js" || ! -f "$pm" ]];then
                whiptail --title "Warnning" --msgbox "
Your Proxmox VE version does not support this method！
Your Proxmox VE\'s version is not supported,Now quit!
                " 10 60
                main
            fi
            #if [[ -f "$js.backup" && -f "$sh" ]];then
            if [[ `cat $js|grep Sensors|wc -l` -gt 0 ]];then
                whiptail --title "Warnning" --msgbox "
You have installed this software, please do not repeat the installation!
You already installed,Now quit!
                " 10 60
                chSensors
            fi
            <!-- #region(collapsed) OldSensors -->
           if [ ! -f "/usr/bin/sensors" ];then
                apt-get -y install lm-sensors
            fi
            sensors-detect --auto > /tmp/sensors
            drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
            if [ `echo $drivers|wc -w` = 0 ];then
                whiptail --title "Warnning" --msgbox "
Sensors driver not found.
No driver is found, it seems that your system has no temperature sensor.
Continue to configure the CPU frequency...
                " 10 60
                if [ $bver -gt 7 ];then
                    cat << EOF > /usr/bin/s.sh
curC=\`cat /proc/cpuinfo|grep MHz|awk 'NR==1{print \$4}'\`
max=\`cat /proc/cpuinfo|grep GHz|awk -F "@" 'NR==1{print \$2}'|sed 's/GHz//g'|sed 's/\ //g'\`
maxC=\`echo "\$max * 1000"|bc -l\`
minC=\`lscpu|grep 'min MHz'|awk '{print \$4}'\`
c="\"CPU-MHz\":\""\$curC"\",\"CPU-max-MHz\":\""\$maxC"\",\"CPU-min-MHz\":\""\$minC"\""
r="{"\$c"}"
echo \$r
EOF
                else
                    cat << EOF > /usr/bin/s.sh
c=\`lscpu|grep MHz|sed 's/CPU\ /CPU-/g'|sed 's/\ MHz/-MHz/g'|sed 's/\ //g'|sed 's/^/"/g'|sed 's/$/"\,/g'|sed 's/\:/\"\:\"/g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/\,\$//g'\`
r="{"\$c"}"
echo \$r
EOF
                fi
            chmod +x /usr/bin/s.sh
            #--create the configs--
            if [ -f ./p1 ];then rm ./p1;fi
            #--这里插入cpu频率　add cpu MHz--
            cat << EOF >> ./p1
             ,{
             itemId: 'MHz',
             colspan: 2,
             printBar: false,
             title: gettext('CPU Frequency'),
             textField: 'tdata',
             renderer:function(value){
                 var d = JSON.parse(value);
                 f0 = d['CPU-MHz'];
                 f1 = d['CPU-min-MHz'];
                 f2 = d['CPU-max-MHz'];
                 return  \`CPU: \${f0} MHz | Minimum: \${f1} MHz | Maximum: \${f2} MHz \`;
         }
 }
EOF
            #--Insert the CPU frequency to end ADD cpu MHz end--
            cat << EOF >> ./p2
\$res->{tdata} = \`/usr/bin/s.sh\`;
EOF
            n=`sed '/pveversion/,/\}/=' $js -n|sed -n '$p'`
            sed -i ''$n' r ./p1' $js
            n=`sed '/pveversion/,/version_text/=' $pm -n|sed -n '$p'`
            sed -i ''$n' r ./p2' $pm
            if [ -f ./p1 ];then rm ./p1;fi
            if [ -f ./p2 ];then rm ./p2;fi
            systemctl restart pveproxy
            whiptail --title "Success" --msgbox "
If there is no accident, it has been installed!The browser opens the interface to refresh the summary interface!
Installation Complete! Go to websites and refresh to enjoy!
            " 10 60

                chSensors
            else
                for i in $drivers
                do
                    modprobe $i
                    if [ `grep $i /etc/modules|wc -l` = 0 ];then
                        echo $i >> /etc/modules
                    fi
                done
                sensors
                sleep 3
                whiptail --title "Success" --msgbox "
Install complete,if everything ok ,it\'s showed sensors.Next, restart you web.
The installation configuration is successful. If there is no accident, Sensors have been displayed above.The next step will restart the web interface, please don't panic。
                " 20 60
            rm /tmp/sensors
            #debian 12 fixbug
            if [ $bver -gt 7 ];then
                cat << EOF > /usr/bin/s.sh
r=\`sensors|grep -E 'Package id 0|fan|Physical id 0|Core'|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/:/":"/g'|sed 's/^/"/g' |sed 's/$/",/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/\,\$//g'|sed 's/°C/\&degC/g'\`
curC=\`cat /proc/cpuinfo|grep MHz|awk 'NR==1{print \$4}'\`
max=\`cat /proc/cpuinfo|grep GHz|awk -F "@" 'NR==1{print \$2}'|sed 's/GHz//g'|sed 's/\ //g'\`
maxC=\`echo "\$max * 1000"|bc -l\`
minC=\`lscpu|grep 'min MHz'|awk '{print \$4}'\`
c="\"CPU-MHz\":\""\$curC"\",\"CPU-max-MHz\":\""\$maxC"\",\"CPU-min-MHz\":\""\$minC"\""
r="{"\$r","\$c"}"
echo \$r
EOF 
<!-- #endregion -->  
            else
                cat << EOF > /usr/bin/s.sh
r=\`sensors|grep -E 'Package id 0|fan|Physical id 0|Core'|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/:/":"/g'|sed 's/^/"/g' |sed 's/$/",/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/\,\$//g'|sed 's/°C/\&degC/g'\`
c=\`lscpu|grep MHz|sed 's/CPU\ /CPU-/g'|sed 's/\ MHz/-MHz/g'|sed 's/\ //g'|sed 's/^/"/g'|sed 's/$/"\,/g'|sed 's/\:/\"\:\"/g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/\,\$//g'\`
r="{"\$r","\$c"}"
echo \$r
EOF
            fi
            chmod +x /usr/bin/s.sh
            #--create the configs--
            #--filter for sensors 过滤sensors项目--
            d=`sensors|grep -E 'Package id 0|fan|Physical id 0|Core'|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk -F ":" '{print $1}'`
            if [ -f ./p1 ];then rm ./p1;fi
            #--这里插入cpu频率　add cpu MHz--
            cat << EOF >> ./p1
             ,{
             itemId: 'MHz',
             colspan: 2,
             printBar: false,
             title: gettext('CPU频率'),
             textField: 'tdata',
             renderer:function(value){
                 var d = JSON.parse(value);
                 f0 = d['CPU-MHz'];
                 f1 = d['CPU-min-MHz'];
                 f2 = d['CPU-max-MHz'];
                 return  \`CPU: \${f0} MHz | Min: \${f1} MHz | Max: \${f2} MHz \`;
         }
 }
EOF
            #--Insert the CPU frequency to end ADD cpu MHz end--
            cat << EOF >> ./p1
        ,{
            xtype: 'box',
            colspan: 2,
        title: gettext('Sensors Data:'),
            padding: '0 0 20 0'
        }
        ,{
            itemId: 'Sensors',
            colspan: 2,
            printBar: false,
            title: gettext('Sensors Data:')
        }
EOF
            for i in $d
            do
            cat << EOF >> ./p1
        ,{
            itemId: '$i',
            colspan: 1,
            printBar: false,
            title: gettext('$i'),
            textField: 'tdata',
            renderer:function(value){
            var d = JSON.parse(value);
            var s = "";
            s = d['$i'];
            return s;
            }
        }
EOF
            done
            cat << EOF >> ./p2
\$res->{tdata} = \`/usr/bin/s.sh\`;
EOF
#\$res->{cpusensors} = \`lscpu | grep MHz\`;
            #--configs end--
            #h=`sensors|awk 'END{print NR}'`
            itemC=`s.sh|sed  's/\,/\r\n/g'|wc -l`
            if [ $itemC = 0 ];then
                h=400
            else
                #let h=$h*9+320
                let h=$itemC*24/2+360
            fi
            n=`sed '/widget.pveNodeStatus/,/height/=' $js -n|sed -n '$p'`
            sed -i ''$n'c \ \ \ \ height:\ '$h',' $js
            n=`sed '/pveversion/,/\}/=' $js -n|sed -n '$p'`
            sed -i ''$n' r ./p1' $js
            n=`sed '/pveversion/,/version_text/=' $pm -n|sed -n '$p'`
            sed -i ''$n' r ./p2' $pm
            if [ -f ./p1 ];then rm ./p1;fi
            if [ -f ./p2 ];then rm ./p2;fi
            systemctl restart pveproxy
            whiptail --title "Success" --msgbox "
If there is no accident, it has been installed!The browser opens the interface to refresh the summary interface!
Installation Complete! Go to websites and refresh to enjoy!
            " 10 60
        fi
        else
            chSensors
        fi
    ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
Uninstall?
Confirm that you want to restore the configuration?
        " 10 60)then
            js='/usr/share/pve-manager/js/pvemanagerlib.js'
            pm='/usr/share/perl5/PVE/API2/Nodes.pm'

            if [[ `cat $js|grep -E 'Sensors|CPU'|wc -l` = 0 ]];then
                whiptail --title "Warnning" --msgbox "
No sensors found.
No installation is detected and no need to uninstall.
                " 10 60
            else
                sensors-detect --auto > /tmp/sensors
                drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
                if [ `echo $drivers|wc -w` != 0 ];then
                    for i in $drivers
                    do
                        if [ `grep $i /etc/modules|wc -l` != 0 ];then
                            sed -i '/'$i'/d' /etc/modules
                        fi
                    done
                fi
                apt-get -y remove lm-sensors
            {
                #mv $js.backup $js
                #mv $pm.backup $pm
                #rm $js
                #rm $pm
                rm /usr/bin/s.sh
                cp /etc/pvetools/pvemanagerlib.js $js
                cp /etc/pvetools/Nodes.pm $pm
                echo 50
                echo 100
                sleep 1
            }|whiptail --gauge "Uninstalling" 10 60 0
            whiptail --title "Success" --msgbox "
Uninstall complete.
Uninstalled successfully.
            " 10 60
            fi
        fi
        chSensors
        ;;
    esac
fi
}

getIommu(){
    ppv=`/usr/bin/pveversion`
    OS=`echo $ppv|awk -F'-' 'NR==1{print $1}'`
    ver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
    bver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'`
    if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then
        iommu="amd_iommu=on"
    else
        iommu="intel_iommu=on"
    fi
    if [ ${bver} -gt 6 ];then
        iommu=$iommu" iommu=pt pcie_acs_override=downstream"
    fi
}

chPassth(){

#--------------funcs-start----------------
enablePass(){
if(whiptail --title "Yes/No Box" --yesno "
Enable PCI Passthrough(need reboot host)?
Do you turn on the hardware direct support (need to restart the physical machine)?
" --defaultno 10 60) then
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "
Your hardware do not support PCI Passthrough(No IOMMU)
Your hardware does not support direct through!
" 10 60
        chPassth
    fi
    getIommu
    if [ `grep "$iommu" /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak "s|quiet|quiet $iommu|" /etc/default/grub
        update-grub
        if [ `grep "vfio" /etc/modules|wc -l` = 0 ];then
            cat <<EOF >> /etc/modules
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF
        fi
        whiptail --title "Success" --msgbox "
    need to reboot to apply! Please reboot.
After installation, you need to restart the system, please restart later.
        " 10 60
    else
        whiptail --title "Warnning" --msgbox "
You already configed!
You have configured this!
" 10 60
        chPassth
    fi
else
    main
fi
}

disablePass(){
if(whiptail --title "Yes/No Box" --yesno "
disable PCI Passthrough(need reboot host)?
Whether to close the hardware direct support (need to restart the physical machine）?
" --defaultno 10 60) then
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --yesno "
Your hardware do not support PCI Passthrough(No IOMMU)
Your hardware does not support direct passage！
" 10 60
        chPassth
    fi
    getIommu
    if [ `grep "$iommu" /etc/default/grub|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "not config yet.
You haven't configured this item yet" 10 60
        chPassth
    else
        update-grub
    {
        sed -i "s/ $iommu//g" /etc/default/grub
        echo 30
        echo 80
        sed -i '/vfio/d' /etc/modules
        echo 100
        sleep 1
        }|whiptail --gauge "installing..." 10 60 10
        whiptail --title "Success" --msgbox "
need to reboot to apply! Please reboot.
You need to restart the system after installation, please restart later。
        " 10 60
    fi
else
    main
fi
}

enVideo(){
    clear
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "
    Your hardware do not support PCI Passthrough(No IOMMU)
    Your hardware does not support direct passage！
    " 10 60
        configVideo
    fi
    if [ `grep 'iommu=on' /etc/default/grub|wc -l` = 0 ];then
        if(whiptail --title "Warnning" --yesno "
    your host not enable IOMMU,jump to enable?
    Your host system has not been equipped with direct support, jump to set up？
        " 10 60)then
            enablePass
        fi
    fi
    if [ `grep 'vfio' /etc/modules|wc -l` = 0 ];then
        if(whiptail --title "Warnning" --yesno "
    your host not enable IOMMU,jump to enable?
    Your host system has not been equipped with direct support, jump to set up？
        " 10 60)then
            enablePass
        fi
    fi
    getVideo

}

getVideo(){
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -E 'VGA|Audio' > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cat cards-out > cards
    id=`cat /etc/modprobe.d/vfio.conf|grep -o "ids=[0-9a-zA-Z,:]*"|awk -F "=" '{print $2}'|sed  's/,/ /g'|sort -u`
    n=`for i in $id;do lspci -n -d $i|awk -F "." '{print $1}';done|sort -u`
    for i in $n
    do
        sed -i "/${i}/s/OFF/ON/" cards
    done
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config(* mark means configed):
Select the graphics card (the standard*is the configured)：
" 15 90 4 \
$(cat cards) \
3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ -n "$DISTROS" ];then
	    rm cards*
            if(whiptail --title "Warnning" --yesno "
Continue?
Please confirm whether to continue？
            " 10 60)then
                clear
            else
                getVideo
            fi
            ids=""
            for i in $DISTROS
            do
                i=`echo $i|sed 's/\"//g'`
                ids=$ids`lspci -n -s ${i}|awk '{print ","$3}'`
            done
            ids=`echo $ids|sed 's/^,//g'|sed 's/ ,/,/g'`
            if [ `grep $ids'$' /etc/modprobe.d/vfio.conf|wc -l` = 0 ];then
                echo "options vfio-pci ids=$ids" > /etc/modprobe.d/vfio.conf
            else
                if(whiptail --defaultno --title "Warnning" --yesno "
    It seems you have already configed it before.Reconfig?
    You seem to have configured this.Reconfigure？
                " 10 60)then
                    clear
                else
                   getVideo
                fi
            fi
            #--config-blacklist--
            for i in nvidiafb nouveau nvidia radeon amdgpu
            do
                if [ `grep '^blacklist '$i'$' /etc/modprobe.d/pve-blacklist.conf|wc -l` = 0 ];then
                    echo "blacklist "$i >> /etc/modprobe.d/pve-blacklist.conf
                fi
            done
            #--iommu-groups--
            if [ `find /sys/kernel/iommu_groups/ -type l|wc -l` = 0 ];then
                if [ `grep 'pcie_acs_override=downstream' /etc/default/grub|wc -l` = 0 ];then
                    getIommu
                    sed -i.bak "s|quiet|quiet $iommu|" /etc/default/grub
                    update-grub
                fi
            fi
            #--video=efifb:off--
            if [ `grep 'video=efifb:off' /etc/default/grub|wc -l` = 0 ];then
                sed -i.bak 's|quiet|quiet video=efifb:off|' /etc/default/grub
                update-grub
            fi
            #--kvm-parameters--
            if [ `cat /sys/module/kvm/parameters/ignore_msrs` = 'N' ];then
                echo 1 > /sys/module/kvm/parameters/ignore_msrs
                echo "options kvm ignore_msrs=Y">>/etc/modprobe.d/kvm.conf
            fi
            update-initramfs -u -k all
            whiptail --title "Success" --msgbox "
    need to reboot to apply! Please reboot.
    You need to restart the system after installation, please restart later。
            " 10 60
        else
            if(whiptail --title "Warnning" --yesno "
Continue?
请确认是否继续？
            " 10 60)then
                clear
            else
                getVideo
            fi
            {
            echo "" > /etc/modprobe.d/vfio.conf
            echo 0 > /sys/module/kvm/parameters/ignore_msrs
            sed -i '/ignore_msrs=Y/d' /etc/modprobe.d/kvm.conf
            for i in nvidiafb nouveau nvidia radeon amdgpu
            do
                sed -i '/'$i'/d' /etc/modprobe.d/pve-blacklist.conf
            done
            echo 100
            sleep 1
            }|whiptail --gauge "configing..." 10 60 10
            whiptail --title "Success" --msgbox "Done.
Configuration complete" 10 60
        fi
    else
        configVideo
    fi
}

disVideo(){
    clear
    getVideo dis
}
addVideo(){
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -e VGA > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cards=`cat cards-out`
    rm cards*
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config?" 15 90 4 \
$(echo $cards) \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
            confPath='/etc/pve/qemu-server/'
            ids=""
            for i in $DISTROS
            do

                i=`echo $i|sed 's/\"//g'`
                for j in `ls $confPath`
                do
                    if [ `grep $i $confPath$j|wc -l` != 0 ];then
                        confId=`echo $j|awk -F '.' '{print $1}'`
                    fi
                done
            done
            list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
            echo -n "">lsvm
            ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2" OFF"}'>>lsvm;done`
            ls=`sed -i '/'$confId'/ s/OFF/ON/g' lsvm`
            ls=`cat lsvm`
            rm lsvm
            h=`echo $ls|wc -l`
            let h=$h*1
            if [ $h -lt 30 ];then
                h=30
            fi
            list1=`echo $list|awk 'NR>1{print $1}'`
            vmid=$(whiptail  --title " PveTools   Version : 2.3.8 " --radiolist "
        Choose vmid to set video card Passthrough:
        Choose VMs that need to be configured to configure the graphics card：" 20 60 10 \
            $(echo $ls) \
            3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                if(whiptail --title "Yes/No" --yesno "
        you choose: $vmid ,continue?
        You chose：$vmid ，Whether to continue?
                    " 10 60)then
                    echo $vmid>vmid
                    while [ true ]
                    do
                        if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                            whiptail --title "Warnning" --msgbox "
            Enter the format error, please re -enter：
                            " 10 60
                            addVideo
                        else
                            break
                        fi
                    done
                    if [ $vmid -eq $confId ];then
                        whiptail --title "Warnning" --msgbox "
You already configed!
You have configured this!
                        " 10 60
                        addVideo
                    fi
                    opt=$(whiptail  --title " PveTools   Version : 2.3.8 " --checklist "
Choose options:
Option：" 20 60 10 \
                    "q35" "Q35 supports, GPU is recommended to choose from, leaving a blank alone " OFF \
                    "ovmf" "GPU direct selection" OFF \
                    "x-vga" "Main GPU, the default has been selected" ON \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in 'boot:' 'memory:' 'core:';do
                            if [ `grep '^'$i $confPath$vmid.conf|wc -l` != 0 ];then
                                con=$i
                                break
                            fi
                        done
                        for op in $opt
                        do
                            op=`echo $op|sed 's/\"//g'`
                            if [ $op = 'q35' ];then
                                sed "/"$con"/a\machine\: q35" -i $confPath$vmid.conf
                            fi
                            if [ $op = 'ovmf' ];then
                                sed "/"$con"/a\bios\: ovmf" -i $confPath$vmid.conf
                            fi
                        done
                        #--config-vmid.conf---
                        for i in $DISTROS
                        do
                            if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` = 0 ];then
                                pcid=`cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|awk -F ':' '{print $1}'|sort -u|grep '[0-9]*$' -o`
                                if [ $pcid ];then
                                    pcid=$((pcid+1))
                                else
                                    pcid=0
                                fi
                                i=`echo $i|sed 's/\"//g'`
                                sed -i "/"$con"/a\hostpci"$pcid": "$i",x-vga=1" $confPath$vmid.conf
                            else
                                whiptail --title "Warnning" --msgbox "
You already configed!
You have configured this!
                                " 10 60
                            fi
                            if [ $confId ];then
                                rmVideo $confId $confPath $i
                            fi
                            whiptail --title "Success" --msgbox "
Configed!Please reboot vm.
Configuration is successful!Effective after restarting the virtual machine.
                            " 10 60
                            if(whiptail --title "Yes/No" --yesno "
Let tool auto switch vm?
Whether to automatically restart the virtual machine？" 10 60)then
                                #vmid=`echo $vmid|sed 's/\"//g'`
                                vmid=`cat vmid`
                                rm vmid
                                if [ $confId ];then
                                    usb=`cat /etc/pve/qemu-server/115.conf |grep '^usb'|wc -l`
                                    if [ $usb ];then
                                        if(whiptail --title "Yes/No" --yesno "
Let tool auto switch usb?
Whether to automatically switch the USB device？
                                        " 10 60)then
                                            cat $confPath$confId.conf |grep '^usb'|sed 's/ //g'>usb
                                            sed -i '/^usb/d' $confPath$confId.conf
                                            for i in `cat usb`;do sed -i '/memory/a\'$i $confPath$vmid.conf;done
                                            sed -i 's/:host/: host/g' $confPath$vmid.conf
                                            rm usb
                                        fi
                                    fi
                                    qm stop $confId
                                fi
                                qm stop $vmid
                                if [ $confId ];then
                                    qm start $confId
                                fi
                                qm start $vmid
                            whiptail --title "Success" --msgbox "
Configed!
Configuration！
                            " 10 60
                            else
                                configVideo
                            fi
                        done
                    else
                        addVideo
                    fi
                    configVideo
                else
                    addVideo
                fi
            else
                configVideo
            fi
        else
            whiptail --title "Warnning" --msgbox "
Please choose a card.
Please select a graphics card." 10 60
            addVideo
        fi
    else
        configVideo
    fi
}
rmVideo(){
    clear
    vmid=$1
    confPath=$2
    DISTROS=$3
    for i in $vmid
    do
        sed -i '/q35/d' $confPath$vmid.conf
        for i in $DISTROS
            do
                if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` != 0 ];then
                    sed -i '/'$i'/d' $confPath$vmid.conf
                fi
            done
    done
}
switchVideo(){
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -e VGA > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cards=`cat cards-out`
    rm cards*
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config?" 15 90 4 \
$(echo $cards) \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
            confPath='/etc/pve/qemu-server/'
            ids=""
            for i in $DISTROS
            do

                i=`echo $i|sed 's/\"//g'`
                for j in `ls $confPath`
                do
                    if [ `grep $i $confPath$j|wc -l` != 0 ];then
                        confId=`echo $j|awk -F '.' '{print $1}'`
                    fi
                done
            done
            list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
            echo -n "">lsvm
            ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2" OFF"}'>>lsvm;done`
            ls=`sed -i '/'$confId'/ s/OFF/ON/g' lsvm`
            ls=`cat lsvm`
            rm lsvm
            h=`echo $ls|wc -l`
            let h=$h*1
            if [ $h -lt 30 ];then
                h=30
            fi
            list1=`echo $list|awk 'NR>1{print $1}'`
            vmid=$(whiptail  --title " PveTools   Version : 2.3.8 " --radiolist "
        Choose vmid to set video card Passthrough:
        Choose VMs that need to be configured to configure the graphics card：" 20 60 10 \
            $(echo $ls) \
            3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                if(whiptail --title "Yes/No" --yesno "
        you choose: $vmid ,continue?
        You chose:$vmid ，Whether to continue?
                    " 10 60)then
                    echo $vmid>vmid
                    while [ true ]
                    do
                        if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                            whiptail --title "Warnning" --msgbox "
            Enter the format error, please re -enter：
                            " 10 60
                            addVideo
                        else
                            break
                        fi
                    done
                    if [ $vmid -eq $confId ];then
                        whiptail --title "Warnning" --msgbox "
You already configed!
You have configured this!                        " 10 60
                        addVideo
                    fi
                    opt=$(whiptail  --title " PveTools   Version : 2.3.8 " --checklist "
Choose options:
Option：" 20 60 10 \
                    "Q35" "Q35 supports, GPU direct proposal selection, leaving no empty" OFF \
                    "OVMF" "GPU Directly select" OFF \
                    "x-vga" "Main GPU, the default has been selected" on \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in 'boot:' 'memory:' 'core:';do
                            if [ `grep '^'$i $confPath$vmid.conf|wc -l` != 0 ];then
                                con=$i
                                break
                            fi
                        done
                        for op in $opt
                        do
                            op=`echo $op|sed 's/\"//g'`
                            if [ $op = 'q35' ];then
                                sed "/"$con"/a\machine\: q35" -i $confPath$vmid.conf
                            fi
                            if [ $op = 'ovmf' ];then
                                sed "/"$con"/a\bios\: ovmf" -i $confPath$vmid.conf
                            fi
                        done
                        #--config-vmid.conf---
                        for i in $DISTROS
                        do
                            if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` = 0 ];then
                                pcid=`cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|awk -F ':' '{print $1}'|sort -u|grep '[0-9]*$' -o`
                                if [ $pcid ];then
                                    pcid=$((pcid+1))
                                else
                                    pcid=0
                                fi
                                i=`echo $i|sed 's/\"//g'`
                                sed -i "/"$con"/a\hostpci"$pcid": "$i",x-vga=1" $confPath$vmid.conf
                            else
                                whiptail --title "Warnning" --msgbox "
You already configed!
You have configured this!
                                " 10 60
                            fi
                            if [ $confId ];then
                                rmVideo $confId $confPath $i
                            fi
                            whiptail --title "Success" --msgbox "
Configed!Please reboot vm.
Configuration is successful!Effective after restarting the virtual machine.
                            " 10 60
                            if(whiptail --title "Yes/No" --yesno "
Let tool auto switch vm?
Do you let the tool automatically restart the switch to the virtual machine?" 10 60)then
                                #vmid=`echo $vmid|sed 's/\"//g'`
                                vmid=`cat vmid`
                                rm vmid
                                qm stop $confId
                                qm stop $vmid
                                qm start $confId
                                qm start $vmid
                                whiptail --title "Success" --msgbox "
Configed!
Configuration is successful!
                                " 10 60
                            else
                                configVideo
                            fi
                        done
                    else
                        addVideo
                    fi
                    configVideo
                else
                    addVideo
                fi
            else
                configVideo
            fi
        else
            whiptail --title "Warnning" --msgbox "
Please choose a card.
Please select a graphics card." 10 60
            addVideo
        fi
    else
        configVideo
    fi
}

configVideo(){
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config PCI Video card Passthrough:" 25 60 15 \
    "a" "Config Video Card Passthrough" \
    "b" "Config Video Card Passthrough to vm" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configure the PCI graphics card directly:" 25 60 15 \
    "a" "Configure the physical machine graphics card directly to support." \
    "b" "Configure the graphics card directly to the virtual machine." \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        enVideo
        ;;
    b )
        addVideo
        ;;
    esac
else
    main
fi
}


#--------------funcs-end----------------

if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config PCI Passthrough:" 25 60 15 \
    "a" "Config IOMMU on." \
    "b" "Config IOMMU off." \
    "c" "Config Video Card Passthrough" \
    "d" "Config qm set disks." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configuration hardware through:" 25 60 15 \
    "a" "Configure the direct support of the hardware of the physical machine." \
    "b" "Configuration to close the physical machine hardware direct support." \
    "c" "Configure the graphics card directly." \
    "d" "Configure the QM SET hard disk to the virtual machine." \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        enablePass
        ;;
    b )
        disablePass
        ;;
    c )
        configVideo
        ;;
    d )
        chQmdisk
    esac
else
    main
fi
}

checkPath(){
    x=$(whiptail --title "Choose a path" --inputbox "
Input path:
Please enter the path：" 10 60 \
    $1 \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ ! -d $x ];then
                whiptail --title "Warnning" --msgbox "Path not found.
If the path is not detected, please re -enter" 10 60
                checkPath
            else
                break
            fi
        done
        echo $x
        return $?
    fi
}

chRoot(){
    #--base-funcs-start--
    setChroot(){
        clear
        if(whiptail --title "Yes/No" --yesno "
Continue?
Whether to continue?" --defaultno 10 60 )then
            if [ ! -f "/usr/bin/schroot" ];then
                whiptail --title "Warnning" --msgbox "you not installed schroot.
You haven't installed yet schroot。" 10 60
                if [ `ps aux|grep apt-get|wc -l` -gt 1 ];then
                    if(whiptail --title "Yes/No" --yesno "apt-get is running,killit and install schroot?
There are APT-get in the background, whether to kill for installation？
                    " 10 60);then
                        killall apt-get && apt-get -y install schroot
                    else
                        setChroot
                    fi
                else
                    apt-get -y install schroot
                fi
            fi
            sed '/^$/d' /etc/schroot/default/fstab
            if [ `grep '\/run\/udev' /etc/schroot/default/fstab|wc -l` = 0 ];then
                cat << EOF >> /etc/schroot/default/fstab
/run/udev       /run/udev       none    rw,bind         0       0
EOF
            fi
            if [ `grep '\/sys\/fs\/cgroup' /etc/schroot/default/fstab|wc -l` = 0 ];then
                sed '/cgroup/d' /etc/schroot/default/fstab
                cat << EOF >> /etc/schroot/default/fstab
/sys/fs/cgroup  /sys/fs/cgroup  none    rw,rbind        0       0
EOF
            fi
            sed -i '/\/home/d' /etc/schroot/default/fstab
            checkPath /
            chrootp=${x%/}"/alpine"
            echo $chrootp > /etc/schroot/chrootp
            if [ ! -d $chrootp ];then
                mkdir $chrootp
            else
                clear
            fi
            cd $chrootp
            if [ `ls $chrootp/bin|wc -l` -gt 0 ];then
                if(whiptail --title "Warnning" --yesno "files exist, remove and reinstall?
Is there already files, is it empty and reinstalled?" --defaultno 10 60)then
                    for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
                    killall dockerd
                    killall portainer
                    rm -rf $chrootp/*
                else
                    configChroot
                fi
            fi
            if [ $L = "en" ];then
                alpineUrl='http://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86_64'
            else
                #alpineUrl='https://mirrors.aliyun.com/alpine/v3.10/releases/x86_64'
                #change url
                alpineUrl='https://mirrors.ustc.edu.cn/alpine/v3.10/releases/x86_64/'
            fi
            version=`wget $alpineUrl/ -q -O -|grep minirootfs|grep -o '[0-9]*\.[0-9]*\.[0-9]*'|sort -u -r|awk 'NR==1{print $1}'`
            echo $alpineUrl
            echo $version
            sleep 3
            wget -c --timeout 15 --waitretry 5 --tries 5 $alpineUrl/alpine-minirootfs-$version-x86_64.tar.gz
            tar -xvzf alpine-minirootfs-$version-x86_64.tar.gz
            rm -rf alpine-minirootfs-$version-x86_64.tar.gz
            if [ ! -f "/etc/schroot/chroot.d/alpine.conf" ] || [ `cat /etc/schroot/chroot.d/alpine.conf|wc -l` -lt 8 ];then
                cat << EOF > /etc/schroot/chroot.d/alpine.conf
[alpine]
description=alpine $version
directory=$chrootp
users=root
groups=root
root-users=root
root-groups=root
type=directory
shell=/bin/sh
EOF
            fi
            echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > $chrootp/etc/apk/repositories \
            && echo "http://mirrors.aliyun.com/alpine/latest-stable/community/"  >> $chrootp/etc/apk/repositories
            cat << EOF >> $chrootp/etc/profile
echo "Welcome to alpine $version chroot."
echo "Create by PveTools."
echo "Author: 龙天ivan"
echo "Github: https://github.com/ivanhao/pvetools"
EOF
            schroot -c alpine apk update
            whiptail --title "Success" --msgbox "Done.
The installation is complete!" 10 60
            docker
            dockerWeb
            configChroot
        else
            configChroot
        fi
    }
    installOs(){
        clear
    }
    enterChroot(){
        clear
        checkSchroot
        c=`schroot -l|awk -F ":" '{print $2"  "$1}'`
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Enter chroot:" 25 60 15 \
            $(echo $c) \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "进入chroot环境:" 25 60 15 \
            $(echo $c) \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            if [ $x ];then
                schroot -c $x -d /root
            else
                chRoot
            fi
        else
            chRoot
        fi
    }
    docker(){
        clear
        checkSchroot
        if [ `schroot -c alpine -d /root ls /usr/bin|grep docker|wc -l` = 0 ];then
            if(whiptail --title "Warnning" --yesno "No docker found.Install?
You haven't installed the docker yet, whether to install？" 10 60)then
                schroot -c alpine -d /root apk update
                schroot -c alpine -d /root apk add docker
                cat << EOF >> $chrootp/etc/profile
export DOCKER_RAMDISK=true
echo "Docker installed."
for i in {1..10}
do
if [ \`ps aux|grep dockerd|wc -l\` -gt 1 ];then
    break
else
    nohup /usr/bin/dockerd > /dev/null 2>&1 &
fi
done
EOF
                if [ ! -d "$chrootp/etc/docker" ];then
                    mkdir $chrootp/etc/docker
                fi
                if [ $L = "en" ];then
                    cat << EOF > $chrootp/etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://dockerhub.azk8s.cn",
        "https://reg-mirror.qiniu.com",
        "https://registry.docker-cn.com"
    ]
}
EOF
                fi
            else
                configChroot
            fi
        fi
        if [ -f "/usr/bin/screen" ];then
            apt-get install screen -y
        fi
        if [ `screen -ls|grep docker|wc -l` != 0 ];then
            screen -S docker -X quit
        fi
        if(whiptail --title "Yes/No" --yesno "Install portainer web interface?
Whether to install the web interface（portainer）？" 10 60);then
            dockerWeb
        else
            clear
        fi
        screen -dmS docker schroot -c alpine -d /root
        configChroot
    }
    dockerWeb(){
        checkSchroot
        checkDocker
        checkDockerWeb
        if [ `cat $chrootp/etc/profile|grep portainer|wc -l` = 0 ];then
            cat << EOF >> $chrootp/etc/profile
if [ ! -d "/root/portainer_data" ];then
    mkdir /root/portainer_data
fi
if [ \`docker ps -a|grep portainer|wc -l\` = 0 ];then
    docker run -d -p 9000:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /root/portainer_data:/data portainer/portainer
else
    docker start portainer > /dev/null
fi
echo "Portainer installed."
EOF
        fi

        if [ ! -f "/usr/bin/screen" ];then
            apt-get install screen -y
        fi
        chrootReDaemon
        sleep 5
        if [ `schroot -c alpine -d /root docker images|grep portainer|wc -l` = 0 ];then
            schroot -c alpine -d /root docker pull portainer/portainer
        fi
        if [ `schroot -c alpine -d /root docker ps -a|grep portainer|wc -l` = 0 ];then
            schroot -c alpine -d /root docker run -d -p 9000:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /root/portainer_data:/data portainer/portainer
        fi
        checkDockerWeb
    }
    checkSchroot(){
        if [ `ls /usr/bin|grep schroot|wc -l` = 0 ] || [ `schroot -l|wc -l` = 0 ];then
            whiptail --title "Warnning" --msgbox "No schroot found.Install schroot first.
您还没有安装schroot环境，请先安装。" 10 60
            chRoot
        else
            if [ -f "/etc/schroot/chrootp" ];then
                chrootp=`cat /etc/schroot/chrootp`
            else
                if [ -d "/alpine" ];then
                    chrootp="/alpine"
                    echo $chrootp > /etc/schroot/chrootp
                else
                    whiptail --title "Warnning" --msgbox "Chroot path not found!
没有检测到chroot安装目录！" 10 60
                fi
            fi
        fi
    }
    checkDocker(){
        if [ `ls $chrootp/usr/bin|grep docker|wc -l` = 0 ];then
            whiptail --title "Warnning" --msgbox "No docker found.Install docker first.
您还没有安装docker环境，请先安装。" 10 60
            chRoot
        fi
    }
    checkDockerWeb(){
        if [ `schroot -c alpine -d /root docker images|grep portainer|wc -l` != 0 ];then
            whiptail --title "Warnning" --msgbox "DockerWeb found.Quit.
您已经安装dockerWeb环境。
请进入http://ip:9000使用。
" 10 60
            chRoot
        fi
    }
    chrootReDaemon(){
        if [ `screen -ls|grep docker|wc -l` != 0 ];then
            for i in `screen -ls|grep docker|awk -F " " '{print $1}'|awk -F "." '{print $1}'`
            do
                screen -S $i -X quit
            done
        fi
        screen -dmS docker schroot -c alpine -d /root
        if [ `cat /etc/crontab|grep schroot|wc -l` = 0 ];then
            cat << EOF >> /etc/crontab
@reboot  root  screen -dmS docker schroot -c alpine -d /root
EOF
        fi
        whiptail --title "Success" --msgbox "Chroot daemon done." 10 60
    }
    checkChrootDaemon(){
        if [ `screen -ls|grep docker|wc -l` = 0 ];then
            screen -dmS docker schroot -c alpine -d /root
            if [ `screen -ls|grep docker|wc -l` != 0 ];then
                whiptail --title "Warnning" --msgbox "Chroot daemon started.
已经为您开启chroot后台运行环境。
                " 10 60
                chRoot
            else
                checkChrootDaemon
            fi
        else
            if(whiptail --title "Warnning" --yesno "Chroot daemon already runngin.Restart?
chroot后台运行环境已经运行，需要重启吗？
                " --defaultno 10 60)then
                chrootReDaemon
                checkChrootDaemon
            else
                chRoot
            fi
        fi
        chRoot
    }
    configChroot(){
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config chroot & docker etc:" 25 60 15 \
            "a" "Config base schroot." \
            "b" "Docker in alpine" \
            "c" "Portainer in alpine" \
            "d" "Change chroot path" \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "配置chroot环境和docker等:" 25 60 15 \
            "a" "配置基本的chroot环境（schroot 默认为alpine)。" \
            "b" "Docker（alpine）。" \
            "c" "Docker配置界面（portainer in alpine）。" \
            "d" "迁移chroot目录到其他路径。" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                setChroot
                ;;
            b )
                docker
                #whiptail --title "Warnning" --msgbox "Not supported." 10 60
                chroot
                ;;
            c )
                dockerWeb
                chRoot
                ;;
            d )
                mvChrootp
            esac
        else
            chRoot
        fi
    }
    mvChrootp(){
        if (whiptail --title "Yes/No" --yesno "Continue?
是否继续?" --defaultno 10 60)then
            checkSchroot
            chrootpNew=$(whiptail --title "Choose a path" --inputbox "
Current Path:
当前路径：
$(echo $chrootp)
---------------------------------
Input new chroot path:
请输入迁移的新路径：" 20 60 \
"" \
        3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                while [ true ]
                do
                    if [ ! -d $chrootpNew ];then
                        whiptail --title "Warnning" --msgbox "Path not found.
没有检测到路径，请重新输入" 10 60
                        mvChrootp
                    else
                        break
                    fi
                done
                chrootpNew=${chrootpNew%/}"/alpine"
                echo $chrootpNew > /etc/schroot/chrootp
                for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
                if [ -d "$chrootp/sys/fs/cgroup" ];then
                    mount --make-rslave $chrootp/sys/fs/cgroup
                    umount -R $chrootp/sys/fs/cgroup
                fi
                killall portainer
                killall dockerd
                rsync -a -r -v $chrootp"/" $chrootpNew
                sync
                sync
                sleep 3
                rm -rf $chrootp
                sed -i 's#'$chrootp'#'$chrootpNew'#g' /etc/schroot/chroot.d/alpine.conf
                whiptail --title "Success" --msgbox "Done.
    迁移成功" 10 60
                checkChrootDaemon
            else
                configChroot
            fi
        else
            chRoot
        fi
    }
    delChroot(){
        if (whiptail --title "Yes/No" --yesno "Continue?
是否继续?" --defaultno 10 60)then
            checkSchroot
            for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
            apt-get -y autoremove schroot debootstrap
            if [ -d "$chrootp/sys/fs/cgroup" ];then
                mount --make-rslave $chrootp/sys/fs/cgroup
                umount -R $chrootp/sys/fs/cgroup
            fi
            killall portainer
            killall dockerd
            rm -rf $chrootp
            whiptail --title "Success" --msgbox "Done.
    删除成功" 10 60
        else
            chRoot
        fi
    }
    #--base-funcs-end--
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config chroot & docker etc:" 25 60 15 \
    "a" "Install & config base schroot." \
    "b" "Enter chroot." \
    "c" "Chroot daemon manager" \
    "d" "Remove all chroot." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "配置chroot环境和docker等:" 25 60 15 \
    "a" "安装配置基本的chroot环境（schroot 默认为alpine)。" \
    "b" "进入chroot。" \
    "c" "Chroot后台管理。" \
    "d" "彻底删除chroot。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        configChroot
        ;;
    b )
        enterChroot
        ;;
    c )
        checkChrootDaemon
        ;;
    d )
        delChroot
esac
else
    main
fi

}

#--qm set <ide,scsi,sata> disk
chQmdisk(){
    clear
    confDisk(){
        list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
        echo -n "">lsvm
        ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}'>>lsvm;done`
        ls=`cat lsvm`
        rm lsvm
        h=`echo $ls|wc -l`
        let h=$h*1
        if [ $h -lt 30 ];then
            h=30
        fi
        list1=`echo $list|awk 'NR>1{print $1}'`
        vmid=$(whiptail  --title " PveTools   Version : 2.3.8 " --menu "
Choose vmid to set disk:
选择需要配置硬盘的vm：" 20 60 10 \
        $(echo $ls) \
        3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
You chose: $vmid ，是否继续?
                " 10 60)then
                while [ true ]
                do
                    if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                        whiptail --title "Warnning" --msgbox "
Enter the format error, please re -enter：
                        " 10 60
                        chQmdisk
                    else
                        break
                    fi
                done
                if [ $1 = 'add' ];then
                    #disks=`ls -alh /dev/disk/by-id|awk '{print $11" "$9" OFF"}'|awk -F "/" '{print $3}'|sed '/^$/d'|sed '/wwn/d'|sed '/^dm/d'|sed '/lvm/d'`
                    #added=`cat /etc/pve/qemu-server/$vmid.conf|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2$3"\r\n"}'`
                    disks=`ls -alh /dev/disk/by-id|sed '/\.$/d'|sed '/^$/d'|awk 'NR>1{print $9" "$11" OFF"}'|sed 's/\.\.\///g'|sed '/wwn/d'|sed '/^dm/d'|sed '/lvm/d'|sed '/nvme-nvme/d'`
                    d=$(whiptail --title " PveTools Version : 2.3.8 " --checklist "
disk list:
已添加的硬盘:
$(cat /etc/pve/qemu-server/$vmid.conf|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2" "$3}')
-----------------------
Choose disk:
Choose the hard disk:" 30 90 10 \
                    $(echo $disks) \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    t=$(whiptail --title " PveTools Version : 2.3.8 " --menu "
Choose disk type:
Select the hard disk interface type:" 20 60 10 \
                    "sata" "vm sata type" \
                    "scsi" "vm scsi type" \
                    "ide" "vm ide type" \
                    3>&1 1>&2 2>&3)
                    exits=$?
                    if [ $exitstatus = 0 ] && [ $exits = 0 ]; then
                        did=`qm config $vmid|sed -n '/^'$t'/p'|awk -F ':' '{print $1}'|sort -u -r|grep '[0-9]*$' -o|awk 'NR==1{print $0}'`
                        if [ $did ];then
                            did=$((did+1))
                        else
                            did=0
                        fi
                        #d=`ls -alh /dev/disk/by-id|grep $d|awk 'NR==1{print $9}'`
                        d=`echo $d|sed 's/\"//g'`
                        for i in $d
                        do
                            if [ `cat /etc/pve/qemu-server/$vmid.conf|grep $i|wc -l` = 0 ];then
                                #if [ $t = "ide" ] && [ `echo $i|grep "nvme"|wc -l` -gt 0 ];then
                                if [ $t = "ide" ] && [ $did -gt 3 ];then
                                    whiptail --title "Warnning" --msgbox "ide is greate then 3.
ide There are more than 3 types, please re -select other types!" 10 60
                                else
                                    qm set $vmid --$t$did /dev/disk/by-id/$i
                                fi
                                sleep 1
                                did=$((did+1))
                            fi
                        done
                        whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                        chQmdisk
                    else
                        chQmdisk
                    fi
                fi
                if [ $1 = 'rm' ];then
                    disks=`qm config $vmid|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2$3" OFF"}'`
                    d=$(whiptail --title " PveTools Version : 2.3.8 " --checklist "
Choose disk:
选择硬盘：" 20 90 10 \
                    $(echo $disks) \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in $d
                        do
                            i=`echo $i|sed 's/\"//g'`
                            qm set $vmid --delete $i
                        done
                        whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                        chQmdisk
                    else
                        chQmdisk
                    fi
                fi
            else
                chQmdisk
            fi
        fi

    }
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config qm set disks:" 25 60 15 \
        "a" "set disk to vm." \
        "b" "unset disk to vm." \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Configuration "qm set" Physical hard disk to virtual machine机:" 25 60 15 \
        "a" "Add a hard disk to the virtual machine." \
        "b" "Delete the hard disk in the virtual machine." \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            clear
            confDisk add
            ;;
        b )
            clear
            confDisk rm
        esac
    fi
}


manyTools(){
    clear
    nMap(){
        clear
        if [ ! -f "/usr/bin/nmap" ];then
            apt-get install nmap -y
        fi
        map=$(whiptail --title "nmap tools." --inputbox "
Input the Ip address.(192.168.1.0/24)
输入局域网ip地址段。（例子：192.168.1.0/24)
        " 10 60 \
        "" \
        3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ true ]
            do
                if [ ! `echo $map|grep "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]*$"` ];then
                    whiptail --title "Warnning" --msgbox "
Wrong format!!!   input again:
wrong format!IntersectionIntersectionplease enter again:                    " 10 60
                    nMap
                else
                    break
                fi
            done
            maps=`nmap -sP $map`
            whiptail --title "nmap tools." --msgbox "
$maps
            " --scrolltext 30 60
        else
            manyTools
        fi
    }
    setDns(){
        clear
        dname=`cat /etc/resolv.conf|grep 'nameserver'`
        if [ `cat /etc/resolv.conf|grep 'nameserver'|wc -l` != 0 ];then
            if [ $L = "en" ];then
                d=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "DNS - Many Tools:
Detect exist nameserver,Please choose:
                " 25 60 15 \
                "a" "Add nameserver." \
                "b" "Replace nameserver." \
                3>&1 1>&2 2>&3)
            else
                d=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "DNS - 常用的工具:
Detected that it has been configured with a DNS server: \
$(for i in $dname;do echo $i ;done)  \
------------------------------ \
Please select the following operation:
                " 25 60 15 \
                "a" "Add DNS." \
                "b" "Replace DNS." \
                3>&1 1>&2 2>&3)
            fi
            exitstatus=$?
            if [ $exitstatus != 0 ]; then
                manyTools
            fi
        fi
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "DNS - Many Tools:" 25 60 15 \
            "a" "8.8.8.8(google)." \
            "b" "223.5.5.5(alidns)." \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "DNS - 常用的工具:" 25 60 15 \
            "a" "8.8.8.8(Google)." \
            "b" "223.5.5.5(Ali)." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                dn="8.8.8.8"
                case "$d" in
                    b )
                        echo "nameserver    8.8.8.8" > /etc/resolv.conf
                esac
                echo "nameserver    8.8.8.8" >> /etc/resolv.conf
                ;;
            b )
                dn="223.5.5.5"
                case "$d" in
                    b )
                        echo "nameserver    223.5.5.5" > /etc/resolv.conf
                esac
                echo "nameserver    223.5.5.5" >> /etc/resolv.conf
                ;;
            esac
            if [ `cat /etc/resolv.conf | grep ${dn}|wc -l` != 0 ];then
                whiptail --title "Success" --msgbox "Done.
The configuration is complete."  10 60
                manyTools
            else
                whiptail --title "Warnning" --msgbox "Unsuccess.Please retry.
The configuration is unsuccessful.Please try again."  10 60
                setDns
            fi
        else
            manyTools
        fi
    }
    freeMemory(){
        clear
        if(whiptail --title "Free memory" --yesno "Free memory?
Release memory?" 10 60 );then
            sync
            sync
            sync
            echo 3 > /proc/sys/vm/drop_caches
            echo 0 > /proc/sys/vm/drop_caches
            whiptail --title "Success" --msgbox "Done." 10 60
        else
            manyTools
        fi
    }
    speedTest(){
        op=`pwd`
        cd ~
        git clone https://github.com/sivel/speedtest-cli.git
        chmod +x ~/speedtest-cli/speedtest.py
        python ~/speedtest-cli/speedtest.py
        echo "Enter to continue."
        cd $op
        read x
    }
    bbr(){
        op=`pwd`
        if [ ! -d "/opt/bbr" ];then
            mkdir /opt/bbr
        fi
        cp ./plugins/tcp.sh /opt/bbr
        cd /opt/bbr
        ./tcp.sh
        cd $op
    }
    v2ray(){
        op=`pwd`
        cd ~
        git clone https://github.com/ivanhao/ivan-v2ray
        chmod +x ~/ivan-v2ray/install.sh
        ~/ivan-v2ray/install.sh
        echo "Enter to continue."
        cd $op
        read x
    }
    darkMode(){
        if [ $L = "en" ];then
            d=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "DarkMode - Many Tools:
            " 25 60 15 \
            "a" "Install." \
            "b" "Uninstall." \
            3>&1 1>&2 2>&3)
        else
#----------------- Please select the following operation:----------------- \
            d=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "界面黑暗模式 - 常用的工具:
            " 25 60 15 \
            "a" "安装." \
            "b" "卸载." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$d" in
            a )
                if(whiptail --title "DarkMode" --yesno "install DarkMode?
        Install the dark mode interface?" 10 60 );then
                    wget https://gitee.com/ivanhao1984/PVEDiscordDark/raw/master/install.sh -O - | bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            b )
                if(whiptail --title "DarkMode" --yesno "uninstall DarkMode?
        Uninstall the dark mode interface?" 10 60 );then
                    wget https://gitee.com/ivanhao1984/PVEDiscordDark/raw/master/uninstall.sh -O - | bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            esac
        fi
        manyTools
    }
    vbios(){
        echo "..."
        if(whiptail --title "vbios tools" --yesno "get vbios?
Extract the graphics card?" 10 60 );then
            cd ..
            git clone https://github.com/ivanhao/envytools
            cd envytools
            apt-get install cmake flex libpciaccess-dev bison libx11-dev libxext-dev libxml2-dev libvdpau-dev python3-dev cython3 pkg-config
            cmake .
            make
            make install
            nvagetbios -s prom > vbios.bin
            cd ..
            git clone https://github.com/awilliam/rom-parser
            cd rom-parser
            make
            ./rom-parser ../envytools/vbios.bin
            sleep 5
            if [ `rom-parser ../envytools/vbios.bin|grep Error|wc -l` = 0 ];then
                cp ../envytools/vbios.bin /usr/share/kvm/
                whiptail --title "Success" --msgbox "Done.see vbios in '/usr/share/kvm/vbios.bin'
Extract the graphics card VBIOS success, the file is in'/usr/share/kvm/vbios.bin', You can add romfile directly to the configuration file=vbios.bin" 10 60
            else
                whiptail --title "Warnning" --msgbox "Room parse error.
提取显卡vbios失败。" 10 60
            fi

        fi
        manyTools

    }
    folder2ram(){
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "folder2ram:" 25 60 15 \
            "a" "install" \
            "b" "Uninstall" \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "USB device is optimized as a system disk:" 25 60 15 \
            "a" "Installation." \ \
            "b" "Uninstall." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                if(whiptail --title "vbios tools" --yesno "install folder2ram to optimaz USB OS storage?
        Install the USB device as the optimization of the system disk？" 10 60 );then
                    wget https://raw.githubusercontent.com/ivanhao/pve-folder2ram/master/install.sh -O -| bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            b )
                if(whiptail --title "vbios tools" --yesno "uninstall folder2ram optimaz?
        卸载USB设备做系统盘的优化？" 10 60 );then
                    wget https://raw.githubusercontent.com/ivanhao/pve-folder2ram/master/uninstall.sh -O -| bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            esac
        fi
        manyTools
    }

    autoResize(){
        if [ $L = "en" ];then
            d=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "autoResize ROOT partition - Many Tools:
            " 25 60 15 \
            "a" "start." \
            3>&1 1>&2 2>&3)
        else
#----------------- Please select the following operation:----------------- \
            d=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Automatic expansion of ROOT partition available space -commonly used tools:
            " 25 60 15 \
            "a" "运行." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$d" in
            a )
                if(whiptail --title "autoResize" --yesno "run autoResize on /(only LVM partition)?
                    是否运行自动扩展ROOT分区(LVM)可用空间？
                    注意：zfs等非LVM分区不可使用，即便运行也不产生影响。" 15 60 );then
                    ./plugins/autoResize ivanhao/pvetools > ./autoResize.log 2>&1
                    #autoResizeLog=`cat ./autoResize.log`
                    echo "Done." > ./autoResize.log
                    echo "配置完成。" > ./autoResize.log
                    whiptail --title "Success" --scrolltext --textbox "./autoResize.log" 30 60
                    rm ./autoResize.log
                fi
                ;;
            esac
        fi
        manyTools
    }

    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Many Tools:" 25 60 15 \
        "a" "Local network scans(nmap)." \
        "b" "Set DNS." \
        "c" "Free Memory." \
        "d" "net speedtest" \
        "e" "bbr\\bbr+" \
        "f" "config v2ray" \
        "g" "Nvida Video Card vbios" \
        "h" "folder2ram" \
        "i" "DarkMode" \
        "j" "autoResize ROOT partition" \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "常用的工具:" 25 60 15 \
        "a" "LAN scan." \
        "B" "Configure DNS." \
        "C" "Release memory." \
        "D" "Speedtest speed" \ \ \
        "E" "Install BBR \\ BBR+" \
        "F" "Configure v2ray" \
        "H" "USB device as the optimization of the system disk" \
        "I" "Dark Mode Interface" \
        "J" "Automatic expansion of root partition available space" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            nMap
            ;;
        b )
            setDns
            ;;
        c )
            freeMemory
            ;;
        d )
            speedTest
            ;;
        e )
            bbr
            ;;
        f )
            v2ray
            ;;
        g )
            vbios
            ;;
        h|H )
            folder2ram
            ;;
        i|I )
            darkMode
            ;;
        j|J )
            autoResize
            ;;
        esac
    fi

}
chNFS(){
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "NFS:" 25 60 15 \
        "a" "Install nfs server." \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "NFS:" 25 60 15 \
        "a" "安装NFS服务器。" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            if(whiptail --title "Yes/No" --yesno "Comfirm?
Whether to install？" 10 60)then
                apt-get install nfs-kernel-server
                whiptail --title "OK" --msgbox "Complete.If you use zfs use 'zfs set sharenfs=on <zpool> to enable NFS.'
The installation configuration is complete.If you use ZFS, execute the 'zfs set sharenfs = on <zpool> to open NFS。" 10 60
            else
                chNFS
            fi
            ;;
        esac
    fi


}
sambaOrNfs(){
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Samba or NFS:" 25 60 15 \
        "a" "samba." \
        "b" "NFS" \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Samba or NFS:" 25 60 15 \
        "a" "samba." \
        "b" "NFS" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            chSamba
            ;;
        b )
            chNFS
        esac
    fi


}

omvInPve(){
    if(whiptail --title "Yes/No" --yesno "Install omv in proxmox ve directlly?
You will install OMV directly in Proxmox VE, please confirm whether to continue：" 10 60);then
        if [ -f "/usr/sbin/omv-engined" ];then
            if(whiptail --title "Yes/No" --yesno "Already installed omv in proxmox ve.Reinstall?
OMV has been detected,Please confirm whether it is reinstalled?" 10 60);then
                echo "reinstalling..."
            else
                main
            fi
        fi
        apt-get -y install git
        cd ~
        git clone https://github.com/ivanhao/omvinpve
        cd omvinpve
        ./OmvInPve.sh
        main
    else
        main
    fi
}



ConfBackInstall(){
    path(){
x=$(whiptail --title "config path" --inputbox "Input backup path:
Enter backup path:" 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];then
    if [ ! -d $x ];then
        whiptail --title "Warnning" --msgbox "Path not found." 10 60
        path
    fi
else
    main
fi
    }
    count(){
y=$(whiptail --title "config backup number" --inputbox "Input backup last number:
Enter the number of backups:" 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];then
    if [ ! `echo $y|grep '^[0-9]$'` ];then
        whiptail --title "warnning" --msgbox "Invalid content,retry!" 10 60
        count
    fi
else
    main
fi
    }
    path
    count
    x=$x'/pveConfBackup'
    if [ ! -d $x ];then
        mkdir $x
    fi
    if [ ! -d $x/`date '+%Y%m%d'` ];then
        mkdir $x/`date '+%Y%m%d'`
    fi
    cp -rf /etc/pve/qemu-server/* $x/`date '+%Y%m%d'`/
    d=`ls -l $x|awk 'NR>1{print $9}'|wc -l`
    while [ $d -gt $y ]
    do
        rm -rf $x'/'`ls -l $x|awk 'NR>1{print $9}'|head -n 1`
        d=`ls -l $x|awk 'NR>1{print $9}'|wc -l`
    done
    cat << EOF > /usr/bin/pveConfBackup
#!/bin/bash
x='$x'
y=$y
if [ ! -d $x/`date '+%Y%m%d'` ];then
    mkdir $x/`date '+%Y%m%d'`
fi
cp -r /etc/pve/qemu-server/* $x/\`date '+%Y%m%d'\`/
d=\`ls -l $x|awk 'NR>1{print \$9}'|wc -l\`
while [ \$d -gt \$y ]
do
    rm -rf $x/\`ls -l $x|awk 'NR>1{print \$9}'|head -n 1\`
    d=\`ls -l $x|awk 'NR>1{print \$9}'|wc -l\`
done
EOF
    chmod +x /usr/bin/pveConfBackup
    sed -i '/pveConfBackup/d' /etc/crontab
    echo "0  0  *  *  *  root  /usr/bin/pveConfBackup" >> /etc/crontab
    systemctl restart cron
    whiptail --title "success" --msgbox "Install complete." 10 60
    main
}
ConfBackUninstall(){
    if [ `cat /etc/crontab|grep pveConfBackup|wc -l` -gt 0 ];then
        sed -i '/pveConfBackup/d' /etc/crontab
        rm -rf /usr/bin/pveConfBackup
        whiptail --title "success" --msgbox "Uninstall complete." 10 60
    else
        whiptail --title "warnning" --msgbox "No installration found." 10 60
    fi
    main
}
ConfBack(){
OPTION=$(whiptail --title " pve vm config backup " --menu "
auto backup /etc/pve/qemu-server path's conf files.
Automatic backup /etc/pve/qemu-server Conf file under the path
Select: " 25 60 15 \
    "a" "Install. 安装" \
    "b" "Uninstall. 卸载" \
3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
a | A )
        ConfBackInstall
        ;;
b | B)
        ConfBackUninstall
        ;;
* )
        ConfBack
    esac
fi
}
#----------------------functions--end------------------#


#--------------------------function-main-------------------------#
#    "a" "无脑模式" \
          #  a )
          #      if (whiptail --title "Test Yes/No Box" --yesno "Choose between Yes and No." 10 60) then
          #          whiptail --title "OK" --msgbox "OK" 10 60
          #      else
          #          whiptail --title "OK" --msgbox "OK" 10 60
          #      fi
          #      sleep 3
          #      main
          #      ;;
          #  b )
          #      echo "b"
          #      ;;
          #  c )
          #      echo "c"
          #      ;;

main(){
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "
Github: https://github.com/ivanhao/pvetools
Please choose:" 25 60 15 \
    "b" "Config apt source(change to ustc.edu.cn and so on)." \
    "c" "Install & config samba or NFS." \
    "d" "Install mailutils and config root email." \
    "e" "Config zfs_arc_max & Install zfs-zed." \
    "f" "Install & config VIM." \
    "g" "Install cpufrequtils to save power." \
    "h" "Config hard disks to spindown." \
    "i" "Config PCI hardware pass-thrugh." \
    "j" "Config web interface to display sensors data and CPU Freq." \
    "k" "Config enable Nested virtualization." \
    "l" "Remove subscribe notice." \
    "m" "Config chroot & docker etc." \
    "n" "Many tools." \
    "p" "Auto backup vm conf file." \
    "u" "Upgrade this script to new version." \
    "L" "Change Language." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "
Github: https://github.com/ivanhao/pvetools
    Please select the corresponding configuration: "25 60 15 \ \
    "b" "Configure APT domestic source (replaced with USSTC.EDU.CN, remove corporate source, etc.)" \
    "c" "Install and configure Samba or NFS" \
    "d" "Installation and configuration root email notification" \
    "e" "Installation and configuration ZFS maximum memory and ZED notification" \
    "f" "Install VIM" \
    "g" "Install and configure CPU power saving" \ \
    "h" "Install and configure hard disk dormant" \ "\
    "i" "Configure PCI Hardware Directly" \ \
    "j" "" Configure the web interface of the PVE interface display the sensor temperature, CPU frequency "\
    "k" "Configuration Open the Embedded Virtualization" \
    "l" "Remove the subscription prompt" \
    "m" "Configure Chroot Environment and Docker, etc." \
    "n" and "commonly used tools" \ \
    "p" "Automatic backup virtual machine CONF file" \
    "u" "Upgrade the PveTools script to the latest version" \
    "L" "Change Language" \
    3>&1 1>&2 2>&3)
fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$OPTION" in
        a )
            echo "Not support!Please choose other options."
            echo "This version does not support brainless updates, please select specific items for operation！"
            sleep 3
            main
            chSource wn
            chSamba wn
            chMail wn
        #    chZfs wn
            chVim wn
        #    chCpu wn
            chSpindown wn
            chNestedV wn
            chSubs wn
            chSensors wn
            echo "Config complete!Back to main menu 5s later."
            echo "已经完成配置！5秒后返回主界面。"
            echo "5"
            sleep 1
            echo "4"
            sleep 1
            echo "3"
            sleep 1
            echo "2"
            sleep 1
            echo "1"
            sleep 1
            main
            ;;
        b )
            chSource
            main
            ;;
        c )
            sambaOrNfs
            main
            ;;
        d )
            chMail
            main
            ;;
        e )
            chZfs
            main
            ;;
        f )
            chVim
            main
            ;;
        g )
            chCpu
            main
            ;;
        h )
            chSpindown
            main
            ;;
        i )
            #echo "not support yet."
            chPassth
            main
            ;;
        j )
            chSensors
            sleep 2
            main
            ;;
        k )
            clear
            chNestedV
            main
            ;;
        l )
            chSubs
            main
            ;;
        m )
            chRoot
            main
            ;;
        n )
            manyTools
            main
            ;;
        o )
            omvInPve
            ;;
        p )
            ConfBack
            ;;
        u )
            git pull
            echo "Now go to main interface:"
            echo "It's about to return to the main interface. Essence Essence"
            echo "3"
            sleep 1
            echo "2"
            sleep 1
            echo "1"
            sleep 1
            ./pvetools.sh
            ;;
        L )
            if (whiptail --title "Yes/No Box" --yesno "Change Language?
修改语言？" 10 60);then
                if [ $L = "zh" ];then
                    L="en"
                else
                    L="zh"
                fi
                main
                #main $L
            fi
            ;;
        exit | quit | q )
            exit
            ;;
        esac
    else
        exit
    fi
}
#----------------------functions--end------------------#
#if [ `export|grep "zh_CN"|wc -l` = 0 ];then
#    L="en"
#else
#    L="zh"
#fi
#--------santa-start--------------
DrawTriangle() {
	a=$1
	color=$[RANDOM%7+31]
	if [ "$a" -lt "8" ] ;then
		b=`printf "%-${a}s\n" "0" |sed 's/\s/0/g'`
		c=`echo "(31-$a)/2"|bc`
        d=`printf "%-${c}s\n"`
		echo "${d}`echo -e "\033[1;5;${color}m$b\033[0m"`"
	elif [ "$a" -ge "8" -a "$a" -le "21" ] ;then
		e=$[a-8]
		b=`printf "%-${e}s\n" "0" |sed 's/\s/0/g'`
		c=`echo "(31-$e)/2"|bc`
		d=`printf "%-${c}s\n"`
		echo "${d}`echo -e "\033[1;5;${color}m$b\033[0m"`"
	fi
}
DrawTree() {
	e=$1
	b=`printf "%-3s\n" "|" | sed 's/\s/|/g'`
	c=`echo "($e-3)/2"|bc`
	d=`printf "%-${c}s\n" " "`
	echo -e "${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}"
    echo "       Merry Cristamas!"
}
Display(){
	for i in `seq 1 2 31`; do
		[ "$i"="21" ] && DrawTriangle $i
		if [ "$i" -eq "31" ];then
			DrawTree $i
		fi
	done
}
if [[ `date +%m%d` = 1224  ||  `date +%m%d` = 1225 ]] && [ ! -f '/tmp/santa' ];then
    for i in {1..6}
    do
        Display
        sleep 1
        clear
    done
    touch /tmp/santa
fi

#--------santa-end--------------
if (whiptail --title "Language" --yes-button "Chinese" --no-button "English"  --yesno "Choose Language:
Choose a language:" 10 60) then
    L="zh"
else
    L="en"
fi
main
