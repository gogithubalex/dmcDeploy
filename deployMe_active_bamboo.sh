#!/bin/bash -v
#anything printed on stdout and stderr to be sent to the syslog1, as well as being echoed back to the original shell’s stderr.
#exec 1> >(logger -s -t $(basename $0)) 2>&1


# yum update -y
# yum install -y java-1.8.0-openjdk.x86_64
# yum erase -y java-1.7.0-openjdk
# yum install -y git
# yum install -y tomcat7
# yum install git -y


cd /tmp

git clone https://bitbucket.org/DigitalMfgCommons/dmcactivemq.git

cd /tmp/dmcactivemq
mv * ..


sudo echo "admin: asdfgqwer, admin" >> /tmp/jetty-realm.properties
sudo echo "user: asdfgqwer, user" >> /tmp/jetty-realm.properties

wget http://mirror.cc.columbia.edu/pub/software/apache/activemq/5.13.2/apache-activemq-5.13.2-bin.tar.gz
tar zxvf apache-activemq-5.13.2-bin.tar.gz

sudo mv apache-activemq-5.13.2 /opt
sudo ln -sf /opt/apache-activemq-5.13.2/ /opt/activemq


# Copy our custom startup script to /etc/init.d and set appropriate permissions
# this makes the command "service activemq start|stop|restart" possible
sudo cp /tmp/activemq /etc/init.d/.
sudo chmod 755 /etc/init.d/activemq
# Configure system to start the activemq service automatically
sudo chkconfig activemq on


sudo cp -v  /tmp/jetty-realm.properties /opt/activemq/conf/jetty-realm.properties

#start ActiveMQ
cd /opt/activemq/bin
./activemq start
