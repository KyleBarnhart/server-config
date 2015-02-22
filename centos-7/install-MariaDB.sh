#!/bin/bash

if [ "$#" -ne 2 ] || [ ${#1} -lt 1 ] || [ ${#2} -lt 1 ]
then
    echo 'Try "sh install-MariaDB.sh username password"'
    exit
fi

sudo tee -a /etc/yum.repos.d/MariaDB.repo << EOM
# MariaDB 10.0 CentOS repository list - created 2015-02-22 05:20 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOM

# exclude mariadb from centos repos
# Note mariadb from the centos repo is all lowercase. This apparently was done on purpose as a 'sloppy' fix.
# https://www.centos.org/forums/viewtopic.php?f=48&t=47679#p203884
sudo sed -i 's/releasever - Base/releasever - Base\nexclude=mariadb*/' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -i 's/releasever - Updates/releasever - Updates\nexclude=mariadb*/' /etc/yum.repos.d/CentOS-Base.repo

# install MariaDB
sudo yum -y install MariaDB-server MariaDB-client

# start tomcat with system
sudo chmod 755 /etc/init.d/mysql
sudo chkconfig --level 345 mysql on

# open ports
iptables -A INPUT -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT
iptables-save > /etc/sysconfig/iptables

#start
sudo service mysql start

# build timezone data
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot mysql

# Root password
mysql -uroot <<< "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$2');"
mysql -uroot -p$2 <<< "SET PASSWORD FOR 'root'@'$(hostname)' = PASSWORD('$2');"
mysql -uroot -p$2 <<< "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('$2');"
mysql -uroot -p$2 <<< "SET PASSWORD FOR 'root'@'::1' = PASSWORD('$2');"

# Drop anonymous user
mysql -uroot -p$2 <<< "DROP USER ''@'localhost';"
mysql -uroot -p$2 <<< "DROP USER ''@'$(hostname)';"

# Add user
mysql -uroot -p$2 <<< "CREATE USER '$1'@'%' IDENTIFIED BY '$2';"
mysql -uroot -p$2 <<< "GRANT ALL PRIVILEGES ON * . * TO '$1'@'%';"

mysql -uroot -p$2 <<< "FLUSH PRIVILEGES;"
