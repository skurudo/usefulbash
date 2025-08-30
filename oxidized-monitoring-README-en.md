# Oxidized Backup Monitoring Script

## Description

Bash script for monitoring Oxidized backup failures and sending Telegram notifications. Automatically checks error log files, parses information, and sends formatted notifications.

## Features

- **Log file monitoring**: Automatic checking of error files
- **Error parsing**: Extraction of device and failure reason information
- **Telegram notifications**: Sending HTML-formatted messages
- **Automatic cleanup**: Log file cleanup after processing
- **Detailed information**: Including links to Oxidized web interface

## Requirements

- Bash shell
- curl for HTTP requests
- Telegram Bot API token
- Chat ID for notifications
- Access to Oxidized log file

## Configuration

### Main parameters

```bash
# Telegram bot token
API_TOKEN="token"

# Chat ID for notifications
CHAT_ID="chat-id"

# Path to error file
FILE=/opt/oxidized/ox_node_failed.log
```

### Getting Telegram Bot Token

1. **Create application**:
   - Go to [https://oauth.yandex.ru/](https://oauth.yandex.ru/)
   - Create new application
   - Get Client ID

2. **Get token**:
   - Go to: `https://oauth.yandex.ru/authorize?response_type=token&client_id=YOUR_CLIENT_ID`
   - Authorize in Yandex
   - Copy access_token from URL

3. **Application rights**:
   - `Directory API` - for user management
   - `Read user info` - for reading information
   - `Write user info` - for creating/changing

## Script Structure

### 1. File check
```bash
if [ -s $FILE ]
```
- Checks if file is not empty
- `-s` returns true if file exists and is not empty

### 2. Log file parsing
```bash
while IFS=, read -r col1 col2 col3
```
- Reads file line by line
- Splits lines by comma
- `col1` - device name
- `col2` - IP address
- `col3` - error reason

### 3. Message formation
```bash
MESSAGE=("<b>ERROR DETECTED</b> while backup on device $col1 with IP: $col2 reason: <b>$col3</b>. Check <a href=\"http://oxidized.url\">Oxidized</a>!");
```
- HTML formatting for Telegram
- Including web interface link
- Highlighting key information

### 4. Sending notification
```bash
curl -s -X POST https://api.telegram.org/bot$API_TOKEN/sendMessage \
  -d parse_mode="html" \
  -d chat_id=$CHAT_ID \
  -d text="$MESSAGE"
```

### 5. File cleanup
```bash
>$FILE
```
- Cleans file after processing
- Prevents repeated sending

## Log File Format

### Expected structure
```
device_name,192.168.1.1,Connection timeout
router_01,10.0.0.1,Authentication failed
switch_core,172.16.0.1,SSH connection refused
```

### Fields
- **col1**: Device or host name
- **col2**: Device IP address
- **col3**: Error description or failure reason

## Usage

### Basic launch
```bash
./oxidized-check-file-and-send-notify.sh
```

### Launch with parameters
```bash
# Set environment variables
export API_TOKEN="your-bot-token"
export CHAT_ID="your-chat-id"
export FILE="/path/to/error.log"

# Run script
./oxidized-check-file-and-send-notify.sh
```

### Automation via cron
```bash
# Check every 5 minutes
*/5 * * * * /path/to/oxidized-check-file-and-send-notify.sh

# Check every hour
0 * * * * /path/to/oxidized-check-file-and-send-notify.sh
```

## Notification Examples

### Successful notification
```
ERROR DETECTED while backup on device router_main with IP: 192.168.1.1 reason: Connection timeout. Check Oxidized!
```

### Telegram format
- **Bold text** for header and reason
- **Link** to Oxidized web interface
- Structured error information

## Monitoring and Logging

### Status check
```bash
# Check recent notifications
tail -f /var/log/oxidized-notifications.log

# Check bot status
curl -s "https://api.telegram.org/bot$API_TOKEN/getMe"
```

### Error logging
```bash
# Add logging to script
echo "$(date): Processing error file" >> /var/log/oxidized-monitor.log
echo "$(date): Sent notification for $col1" >> /var/log/oxidized-monitor.log
```

## Troubleshooting

### "curl: command not found" Error
```bash
# Install curl
apt-get update && apt-get install curl -y
```

### "Permission denied" Error
```bash
# Make script executable
chmod +x oxidized-check-file-and-send-notify.sh
```

### Telegram API issues
```bash
# Check token
curl -s "https://api.telegram.org/bot$API_TOKEN/getMe"

# Check bot rights
curl -s "https://api.telegram.org/bot$API_TOKEN/getChatMember?chat_id=$CHAT_ID&user_id=$BOT_ID"
```

### File access issues
```bash
# Check access rights
ls -la /opt/oxidized/ox_node_failed.log

# Check owner
stat /opt/oxidized/ox_node_failed.log
```

## Extending Functionality

### Adding logging
```bash
# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/oxidized-monitor.log
}

# Usage
log_message "Starting error check"
log_message "Found error for device $col1"
```

### Adding notifications to other channels
```bash
# Slack notifications
send_slack_notification() {
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$1\"}" \
        $SLACK_WEBHOOK_URL
}

# Email notifications
send_email_notification() {
    echo "$1" | mail -s "Oxidized Backup Error" admin@company.com
}
```

### Adding error filtering
```bash
# Error type filter
case $col3 in
    "Connection timeout")
        PRIORITY="HIGH"
        ;;
    "Authentication failed")
        PRIORITY="MEDIUM"
        ;;
    *)
        PRIORITY="LOW"
        ;;
esac
```

## Integration with Monitoring Systems

### Zabbix
```bash
# Send to Zabbix
zabbix_sender -z zabbix-server -s "oxidized-monitor" -k "backup.errors" -o "1"
```

### Prometheus
```bash
# Increment error counter
echo "oxidized_backup_errors_total{device=\"$col1\"} 1" >> /tmp/metrics.prom
```

### Grafana
```bash
# Log metrics
echo "$(date),$col1,$col2,$col3" >> /var/log/oxidized-metrics.csv
```

## Security

### Token protection
```bash
# Using environment variables
export API_TOKEN="$(cat /etc/oxidized/telegram-token)"

# Using configuration file
source /etc/oxidized/telegram.conf
```

### Access restriction
```bash
# Restrict script access
chmod 750 oxidized-check-file-and-send-notify.sh
chown root:oxidized oxidized-check-file-and-send-notify.sh
```

## Performance

### Optimization for large files
```bash
# Process in parts
head -100 $FILE | while IFS=, read -r col1 col2 col3; do
    # processing
done
```

### Result caching
```bash
# Check file changes
if [ "$(stat -c %Y $FILE)" -gt "$LAST_CHECK" ]; then
    # processing
    LAST_CHECK=$(stat -c %Y $FILE)
fi
```

## License

Script is distributed under the same license as the main project.

## Support

For questions and suggestions, create an issue in the project repository.
