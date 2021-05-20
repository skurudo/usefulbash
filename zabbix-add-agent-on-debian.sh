#!/bin/bash
#
# YASZAIT
# Yet Another Simple Zabbix Agent Installer Tool
#
###############################################################


# enter some data to start
echo -n "This server name: "
read SRV_HOSTNAME

# if SRV_HOSTNAME is empty, try again
if [ -z "$SRV_HOSTNAME" ]; then
        SRV_HOSTNAME=$(hostname -f)
fi


echo -n "Main Zabbix Server: "
read ZABBIX_SERVER

# if ZABBIX_SERVER is empty, try again
if [ -z "$ZABBIX_SERVER" ]; then
    echo -n "==> Please input the servername of your Zabbix server... [example.myzabbix.org or IP]: "
        read -r ZABBIX_SERVER
fi

echo -n "Listening port (10050): "
read LISTEN_PORT

# if LISTEN_PORT is empty, set it to 10050
if [ -z "$LISTEN_PORT" ]; then
    LISTEN_PORT=10050
fi

# Zabbix agent simple installation
apt-get install zabbix-agent

# change configuration file
cat > /etc/zabbix/zabbix_agentd.conf << EOF
# simple core config file
# address of the server
Server=$ZABBIX_SERVER
ServerActive=$ZABBIX_SERVER
# port for Zabbix
ListenPort=$LISTEN_PORT
# hostname 
Hostname=$SRV_HOSTNAME
#Hostname=$(hostname -f)
# pid and logs
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix-agent/zabbix_agentd.log
LogFileSize=0
EOF

# restart the zabbix agent
service zabbix-agent restart 

# check agent status
service zabbix-agent status

# show a little ip4 addresses for Zabbix server
echo "Server ipv4 addresses:"
ip addr show | grep "inet "