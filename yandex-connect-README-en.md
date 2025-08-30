# Yandex.Connect Mass User Management Script

## Description

Bash script for mass user creation in Yandex.Connect through Directory API. Automates the process of adding employees from a file using OAuth token for authentication.

## Features

- **Mass user creation**: Processing employee list from file
- **API integration**: Using official Yandex.Connect Directory API
- **Flexible configuration**: Setting departments, positions, and passwords
- **Automatic processing**: Batch processing without manual intervention
- **Result logging**: Tracking successful and failed operations
- **Customizable attributes**: Full user profile configuration

## Requirements

- Bash shell
- curl for HTTP requests
- OAuth token for Yandex.Connect
- File with user list
- Internet access

## Configuration

### Main parameters

```bash
# Path to user list file
employees='./usrlist'

# OAuth token for authentication
TOKEN="token-here-and-there"
```

### Getting OAuth token

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

## User File Format

### File structure
```
email_lastname_firstname_middlename_password_position
```

### Example lines
```
petrova_Петрова_Авдотья_Федоровна_eeKrutoiparol23_Менеджер
ivanov_Иванов_Иван_Иванович_StrongPass123_Разработчик
sidorova_Сидорова_Мария_Петровна_SecurePass456_Аналитик
```

### Fields
- **email**: User login (without domain)
- **lastname**: Last name
- **firstname**: First name
- **middlename**: Middle name
- **password**: User password
- **position**: Job position

## Script Structure

### 1. Read user file
```bash
for i in $( cat $employees ); do
    value=($(echo $i | tr "_" " "))
```

### 2. Parse data
```bash
email="${value[0]}"
lastname="${value[1]}"
firstname="${value[2]}"
middlename="${value[3]}"
password="${value[4]}"
position="${value[5]}"
```

### 3. Form API request
```bash
curl -i -X POST \
  -H 'Content-type: application/json' \
  -d '{
    "department_id": 1,
    "position": "'$position'",
    "password": "'$password'",
    "nickname": "'$email'",
    "name": {
      "first": "'$firstname'",
      "last": "'$lastname'",
      "middle": "'$middlename'"
    }
  }' \
  -H "Authorization: OAuth $TOKEN" \
  'https://api.directory.yandex.net/v6/users/'
```

### 4. Process response
```bash
# Only HTTP responses
| grep HTTP

# Full responses (commented)
# curl -i -X POST ... (without grep)
```

### 5. Delay between requests
```bash
wait 2
```

## Usage

### Prepare user file
```bash
# Create usrlist file
cat > usrlist << EOF
john_Джон_Джон_Джонович_Pass123_Developer
jane_Джейн_Джейн_Джейновна_Pass456_Manager
EOF
```

### Run script
```bash
# Edit TOKEN in script
nano yandex-connect-mass-user-add.sh

# Run
./yandex-connect-mass-user-add.sh
```

### Check results
```bash
# Check HTTP responses
./yandex-connect-mass-user-add.sh

# For full responses uncomment line
# curl -i -X POST ... (remove | grep HTTP)
```

## API Endpoints

### User creation
```
POST https://api.directory.yandex.net/v6/users/
```

### Request parameters
```json
{
  "department_id": 1,
  "position": "Должность",
  "password": "Пароль",
  "nickname": "Логин",
  "name": {
    "first": "Имя",
    "last": "Фамилия",
    "middle": "Отчество"
  }
}
```

### Headers
```
Content-Type: application/json
Authorization: OAuth YOUR_TOKEN
```

## Error Handling

### HTTP response codes
- **200/201**: User successfully created
- **400**: Request data error
- **401**: Invalid token
- **403**: Insufficient rights
- **409**: User already exists

### Typical errors
```bash
# Invalid token
HTTP/1.1 401 Unauthorized

# Insufficient rights
HTTP/1.1 403 Forbidden

# User exists
HTTP/1.1 409 Conflict
```

## Monitoring and Logging

### Adding logging
```bash
# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/yandex-connect.log
}

# Usage
log_message "Creating user: $email"
log_message "User $email created successfully"
```

### Status check
```bash
# Check recent operations
tail -f /var/log/yandex-connect.log

# User statistics
grep "created successfully" /var/log/yandex-connect.log | wc -l
```

## Troubleshooting

### "curl: command not found" Error
```bash
# Install curl
apt-get update && apt-get install curl -y
```

### "Permission denied" Error
```bash
chmod +x yandex-connect-mass-user-add.sh
```

### OAuth token issues
```bash
# Check token
curl -H "Authorization: OAuth $TOKEN" \
  "https://api.directory.yandex.net/v6/users/"

# Check application rights
curl -H "Authorization: OAuth $TOKEN" \
  "https://api.directory.yandex.net/v6/me"
```

### API issues
```bash
# Check API availability
curl -I "https://api.directory.yandex.net/v6/users/"

# Check rate limits
curl -H "Authorization: OAuth $TOKEN" \
  "https://api.directory.yandex.net/v6/users/" \
  -w "HTTP Code: %{http_code}\nTime: %{time_total}s\n"
```

## Extending Functionality

### Adding additional fields
```bash
# Add department field
department="${value[6]}"

# Update API request
"department_id": "'$department'",
```

### Adding validation
```bash
# Check required fields
if [ -z "$email" ] || [ -z "$password" ]; then
    echo "Error: Missing required fields for user"
    continue
fi

# Check email format
if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+$ ]]; then
    echo "Error: Invalid email format: $email"
    continue
fi
```

### Adding error handling
```bash
# Check HTTP response
HTTP_RESPONSE=$(curl -s -o /tmp/response -w "%{http_code}" \
  -X POST -H 'Content-type: application/json' \
  -d "$JSON_DATA" \
  -H "Authorization: OAuth $TOKEN" \
  'https://api.directory.yandex.net/v6/users/')

if [ "$HTTP_RESPONSE" = "201" ]; then
    echo "User $email created successfully"
else
    echo "Error creating user $email: HTTP $HTTP_RESPONSE"
    cat /tmp/response
fi
```

## Automation

### Cron job for regular updates
```bash
# Update users daily at 9:00
0 9 * * * /path/to/yandex-connect-mass-user-add.sh

# Update every 6 hours
0 */6 * * * /path/to/yandex-connect-mass-user-add.sh
```

### HR system integration
```bash
#!/bin/bash
# sync-hr-users.sh

# Export from HR system
hr_export > /tmp/hr_users.csv

# Convert to script format
awk -F',' '{
    print $1 "_" $2 "_" $3 "_" $4 "_" $5 "_" $6
}' /tmp/hr_users.csv > usrlist

# Run sync
./yandex-connect-mass-user-add.sh
```

### Ansible playbook
```yaml
---
- name: Sync Yandex.Connect Users
  hosts: localhost
  tasks:
    - name: Create users list
      template:
        src: users.j2
        dest: usrlist
        mode: '0644'
    
    - name: Run user sync
      command: ./yandex-connect-mass-user-add.sh
      args:
        chdir: /path/to/script
```

## Security

### Token protection
```bash
# Using environment variables
export YANDEX_TOKEN="$(cat /etc/yandex/token)"

# Using configuration file
source /etc/yandex/connect.conf
```

### Access restriction
```bash
# Restrict script access
chmod 750 yandex-connect-mass-user-add.sh
chown root:yandex yandex-connect-mass-user-add.sh

# Restrict user file access
chmod 640 usrlist
chown root:yandex usrlist
```

### Password encryption
```bash
# Generate random passwords
generate_password() {
    openssl rand -base64 12 | tr -d "=+/" | cut -c1-12
}

# Usage
password=$(generate_password)
```

## Performance

### Optimization for large lists
```bash
# Process in parts
split -l 100 usrlist usrlist_part_

for part in usrlist_part_*; do
    employees="$part"
    ./yandex-connect-mass-user-add.sh
    sleep 5  # Delay between parts
done
```

### Parallel processing
```bash
# Process several users simultaneously
process_user() {
    local user_data="$1"
    # ... user processing
}

export -f process_user
cat usrlist | parallel -j 5 process_user {}
```

## Integration with Other Systems

### Active Directory synchronization
```bash
# Export from AD
ldapsearch -H ldap://dc.company.com -D "user@company.com" \
  -w "password" -b "DC=company,DC=com" \
  "(&(objectClass=user)(objectCategory=person))" \
  sAMAccountName sn givenName displayName | \
  awk '/^sAMAccountName:/ {email=$2} \
       /^sn:/ {lastname=$2} \
       /^givenName:/ {firstname=$2} \
       /^displayName:/ {print email "_" lastname "_" firstname "_" "_Pass123_User"}' > usrlist
```

### Google Workspace synchronization
```bash
# Export from Google Workspace
gcloud admin-sdk directory users list \
  --customer=my_customer \
  --format="table(primaryEmail,name.fullName)" | \
  awk 'NR>1 {split($2,names," "); print $1 "_" names[2] "_" names[1] "_" "_Pass123_User"}' > usrlist
```

### CSV import
```bash
# Convert CSV to script format
awk -F',' 'NR>1 {
    print $1 "_" $2 "_" $3 "_" $4 "_" $5 "_" $6
}' users.csv > usrlist
```

## Monitoring and Reporting

### Creating reports
```bash
# Report on created users
echo "=== Yandex.Connect User Sync Report ===" > sync_report.txt
echo "Date: $(date)" >> sync_report.txt
echo "Total users processed: $(wc -l < usrlist)" >> sync_report.txt
echo "Successfully created: $(grep "HTTP/1.1 201" /tmp/response | wc -l)" >> sync_report.txt
echo "Errors: $(grep "HTTP/1.1 [45]" /tmp/response | wc -l)" >> sync_report.txt
```

### Integration with monitoring systems
```bash
# Zabbix
zabbix_sender -z zabbix-server -s "yandex-sync" -k "users.synced" -o "$(grep "201" /tmp/response | wc -l)"

# Prometheus
echo "yandex_users_synced_total $success_count" >> /tmp/metrics.prom
```

## License

Script is distributed under the same license as the main project.

## Support

For questions and suggestions, create an issue in the project repository.
