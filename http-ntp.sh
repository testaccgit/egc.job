#!/bin/bash
### Modified Script

RELEASE=`cat /etc/redhat-release`
isCentOs7=false
isCentOs65=false
isCentOs64=false
isCentOs6=false
SUBSTR=`echo $RELEASE|cut -c1-22`
SUBSTR2=`echo $RELEASE|cut -c1-26`

if [ "$SUBSTR" == "CentOS Linux release 7" ]
then
    isCentOs7=true
elif [ "$SUBSTR2" == "CentOS release 6.5 (Final)" ]
then 
    isCentOs65=true

elif [ "$SUBSTR2" == "CentOS release 6.4 (Final)" ]
then 
    isCentOs64=true
else
    isCentOs6=true
fi

# Check for versions earlier than 6.5

if [ "$isCentOs7" == true ]
then
    echo "I am CentOS 7"
elif [ "$isCentOs65" == true ]
then
    echo "I am CentOS 6.5"
elif [ "$isCentOs64" == true ]
then 
    echo "I am CentOS 6.4"
else
    echo "I am CentOS 6"
fi

CWD=`pwd`

# dependency 
sudo yum install -y yum-presto vim wget html2text mlocate sed gawk openssl curl gcc 
sudo yum install -y firewalld && sudo systemctl start firewalld

# EPEL
sudo yum install -y epel-release
if [ "$isCentOs7" != true ]
then
    sudo sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo
fi

if [ "$isCentOs7" == true ]
then
    sudo wget -N http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-13.ius.centos7.noarch.rpm
    sudo rpm -Uvh ius-release*.rpm
else
    # Please note that v6.5, 6.4, etc. are all covered by the following repository:
    sudo wget -N http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm
    sudo rpm -Uvh ius-release*.rpm
fi

sudo yum install -y firewalld && sudo systemctl start firewalld

# Install and set-up NTP daemon:
if [ "$isCentOs7" == true ]; then
    sudo yum install -y ntp
    sudo firewall-cmd --add-service=ntp --permanent
    sudo firewall-cmd --reload

    sudo systemctl start ntpd
	timedatectl set-timezone Europe/Berlin
fi

# Apache:
# Port 80:
if [ "$isCentOs7" == true ]
then
    sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
    sudo firewall-cmd --reload
else
    sudo iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    sudo service iptables save
    sudo service iptables restart
fi

sudo yum install -y httpd mod_ssl openssh
if [ "$isCentOs7" == true ]
then
    sudo systemctl start httpd
else
    sudo service httpd start
fi

# Restart Apache
if [ "$isCentOs7" == true ]
then
    sudo systemctl start httpd
else
    sudo service httpd start
fi

echo ""
echo "Finished with setup!"
echo ""
echo "Happy development!"
echo ""