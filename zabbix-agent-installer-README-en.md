# YASZAIT - Zabbix Agent Installer

## Description

**YASZAIT** (Yet Another Simple Zabbix Agent Installer Tool) - interactive bash script for automatic installation and configuration of Zabbix agent on Debian/Ubuntu systems. Provides a simple way to deploy monitoring without complex configuration.

## Features

- **Automatic installation**: Zabbix agent installation via apt
- **Interactive configuration**: Parameter requests during execution
- **Automatic configuration**: Configuration file generation
- **Status verification**: Service operation verification
- **System information**: Display of server IP addresses
- **Flexible configuration**: Ability to change port and other parameters

## Requirements

- Debian/Ubuntu system
- Sudo or root privileges
- Internet access for package installation
- Bash shell

## Script Structure

### 1. Parameter input
```bash
# Server name
echo -n "Enter this server name: "
read SRV_HOSTNAME

# Zabbix server
echo -n "Enter Zabbix Server (FQDN or IP): "
read ZABBIX_SERVER

# Listening port
echo -n "Listening port (10050): "
read LISTEN_PORT
```

### 2. Validation and default values
```bash
# Use hostname if name not specified
if [ -z "$SRV_HOSTNAME" ]; then
    SRV_HOSTNAME=($(hostname -f))
fi

# Re-request Zabbix server if not specified
if [ -z "$ZABBIX_SERVER" ]; then
    echo -n "=> Please enter address of your Zabbix server... [example.org or IP]: "
    read -r ZABBIX_SERVER
fi

# Default port 10050
if [ -z "$LISTEN_PORT" ]; then
    LISTEN_PORT=10050
fi
```

### 3. Installation and configuration
```bash
# Install Zabbix agent
apt-get install zabbix-agent

# Generate configuration
cat > /etc/zabbix/zabbix_agentd.conf << EOF
# simple core config file
Server=$ZABBIX_SERVER
ServerActive=$ZABBIX_SERVER
ListenPort=$LISTEN_PORT
Hostname=$SRV_HOSTNAME
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix-agent/zabbix_agentd.log
LogFileSize=0
EOF
```

### 4. Start and verification
```bash
# Restart service
service zabbix-agent restart

# Check status
service zabbix-agent status

# Display IP addresses
ip addr show | grep "inet "
```

## Usage

### Basic launch
```bash
sudo ./zabbix-add-agent-on-debian.sh
```

### Launch with root privileges
```bash
sudo su -
./zabbix-add-agent-on-debian.sh
```

### Interactive input
```
Enter this server name: [Enter to use hostname]
Enter Zabbix Server (FQDN or IP): zabbix.company.com
Listening port (10050): [Enter for default port]
```

## Configuration

### Main parameters

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `Server` | Zabbix server for passive checks | User input |
| `ServerActive` | Zabbix server for active checks | User input |
| `ListenPort` | Listening port | 10050 |
| `Hostname` | Host name in Zabbix | hostname -f |
| `PidFile` | PID file | /var/run/zabbix/zabbix_agentd.pid |
| `LogFile` | Log file | /var/log/zabbix-agent/zabbix_agentd.log |
| `LogFileSize` | Log file size | 0 (no limits) |

### Additional settings

```bash
# Add to configuration
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Additional parameters
Timeout=30
EnablePersistentBuffer=1
BufferSize=100
EOF
```

## Usage Examples

### Installation on web server
```bash
$ ./zabbix-add-agent-on-debian.sh
Enter this server name: web-server-01
Enter Zabbix Server (FQDN or IP): zabbix.internal.company.com
Listening port (10050): 
Zabbix agent simple installation
Reading package lists... Done
...
Zabbix agent installed successfully
```

### Installation on database server
```bash
$ ./zabbix-add-agent-on-debian.sh
Enter this server name: db-server-prod
Enter Zabbix Server (FQDN or IP): 192.168.1.100
Listening port (10050): 10051
...
```

## Monitoring and Verification

### Service status check
```bash
# Zabbix agent status
systemctl status zabbix-agent

# Process check
ps aux | grep zabbix_agentd

# Port check
netstat -tlnp | grep :10050
```

### Log check
```bash
# View logs
tail -f /var/log/zabbix-agent/zabbix_agentd.log

# Search for errors
grep -i error /var/log/zabbix-agent/zabbix_agentd.log

# Search for warnings
grep -i warning /var/log/zabbix-agent/zabbix_agentd.log
```

### Connection testing
```bash
# Test from Zabbix server
zabbix_get -s localhost -p 10050 -k agent.ping

# Local test
zabbix_agentd -t agent.ping
```

## Troubleshooting

### "Permission denied" Error
```bash
chmod +x zabbix-add-agent-on-debian.sh
```

### "apt-get: command not found" Error
```bash
# Update PATH
export PATH=$PATH:/usr/bin:/usr/sbin
```

### Package installation issues
```bash
# Update package lists
apt-get update

# Check package availability
apt-cache search zabbix-agent

# Install manually
apt-get install zabbix-agent -y
```

### Configuration issues
```bash
# Check configuration syntax
zabbix_agentd -t config_file

# Check access rights
ls -la /etc/zabbix/zabbix_agentd.conf

# Recreate configuration
./zabbix-add-agent-on-debian.sh
```

### Service issues
```bash
# Restart service
systemctl restart zabbix-agent

# Check dependencies
systemctl list-dependencies zabbix-agent

# Check systemd logs
journalctl -u zabbix-agent -f
```

## Automation

### Mass installation script
```bash
#!/bin/bash
# install-zabbix-agents.sh

SERVERS=("server1" "server2" "server3")
ZABBIX_SERVER="zabbix.company.com"

for server in "${SERVERS[@]}"; do
    ssh $server "wget -O - https://raw.githubusercontent.com/user/repo/main/zabbix-add-agent-on-debian.sh | bash -s -- $ZABBIX_SERVER"
done
```

### Ansible playbook
```yaml
---
- name: Install Zabbix Agent
  hosts: all
  become: yes
  tasks:
    - name: Download installer script
      get_url:
        url: "https://raw.githubusercontent.com/user/repo/main/zabbix-add-agent-on-debian.sh"
        dest: "/tmp/zabbix-add-agent-on-debian.sh"
        mode: '0755'
    
    - name: Run installer
      command: "/tmp/zabbix-add-agent-on-debian.sh"
      args:
        stdin: "{{ item }}"
      loop:
        - "{{ ansible_hostname }}"
        - "{{ zabbix_server }}"
        - "10050"
```

### Terraform provisioner
```hcl
resource "null_resource" "zabbix_agent" {
  provisioner "remote-exec" {
    inline = [
      "wget -O - https://raw.githubusercontent.com/user/repo/main/zabbix-add-agent-on-debian.sh | bash -s -- ${var.zabbix_server}"
    ]
  }
}
```

## Extending Functionality

### Adding custom keys
```bash
# Add to configuration
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Custom keys
UserParameter=custom.key,/path/to/script.sh
UserParameter=system.uptime,uptime | awk '{print \$3}'
EOF
```

### TLS configuration
```bash
# Add TLS settings
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# TLS settings
TLSConnect=cert
TLSCAFile=/etc/zabbix/certs/ca.crt
TLSCertFile=/etc/zabbix/certs/agent.crt
TLSKeyFile=/etc/zabbix/certs/agent.key
EOF
```

### Proxy configuration
```bash
# Add proxy settings
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Proxy settings
ProxyMode=1
Proxy=proxy.company.com:10051
EOF
```

## Security

### Access restriction
```bash
# Restrict configuration access
chmod 640 /etc/zabbix/zabbix_agentd.conf
chown zabbix:zabbix /etc/zabbix/zabbix_agentd.conf

# Restrict script access
chmod 750 zabbix-add-agent-on-debian.sh
chown root:root zabbix-add-agent-on-debian.sh
```

### Firewall settings
```bash
# Open only needed port
ufw allow from $ZABBIX_SERVER to any port $LISTEN_PORT

# Or for iptables
iptables -A INPUT -s $ZABBIX_SERVER -p tcp --dport $LISTEN_PORT -j ACCEPT
```

## Performance

### Configuration optimization
```bash
# Add performance settings
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Performance settings
StartAgents=3
MaxLinesPerSecond=100
BufferSize=100
EnablePersistentBuffer=1
EOF
```

### Agent monitoring
```bash
# Add agent monitoring
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Agent monitoring
UserParameter=zabbix.agent.processes,ps aux | grep zabbix_agentd | wc -l
UserParameter=zabbix.agent.memory,ps aux | grep zabbix_agentd | awk '{sum+=\$6} END {print sum}'
EOF
```

## Integration

### Host creation in Zabbix
```bash
# API request for host creation
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ZABBIX_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
      "host": "'$SRV_HOSTNAME'",
      "interfaces": [{
        "type": 1,
        "main": 1,
        "useip": 1,
        "ip": "'$(hostname -I | awk '{print $1}')'",
        "dns": "",
        "port": "'$LISTEN_PORT'"
      }],
      "groups": [{"groupid": "1"}],
      "templates": [{"templateid": "10001"}]
    },
    "id": 1
  }' \
  "http://$ZABBIX_SERVER/api_jsonrpc.php"
```

### Auto-registration
```bash
# Setup auto-registration
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Auto-registration
ServerActive=$ZABBIX_SERVER
HostMetadata=Linux server
EOF
```

## License

Script is distributed under the same license as the main project.

## Support

For questions and suggestions, create an issue in the project repository.
