# User Management Scripts

## Description

Collection of bash scripts for automating user creation with sudo privileges and SSH keys. Includes three versions: basic, interactive, and parameterized.

## Scripts

### 1. useradd-sudo-key.sh (Basic Version)
**Description**: Simple script to create a user with passwordless sudo access and SSH key.
**Purpose**: Automate user creation with full sudo privileges and SSH access.

**Features**:
- Creates user with disabled password
- Adds user to sudo group
- Sets up SSH key authentication
- Configures passwordless sudo

**Usage**:
```bash
# Edit USERNAME and PUBLIC_KEY variables
nano useradd-sudo-key.sh
# Run script
./useradd-sudo-key.sh
```

### 2. useradd-sudo-key-i.sh (Interactive Version)
**Description**: Interactive version that prompts for username and public key during execution.
**Purpose**: Interactive user creation with real-time parameter requests.

**Features**:
- Interactive input prompts
- Real-time user creation
- Immediate SSH key setup

**Usage**:
```bash
./useradd-sudo-key-i.sh
```

### 3. useradd-sudo-key-p.sh (Parameterized Version)
**Description**: Command-line parameter version for automation and scripting.
**Purpose**: Automated user creation through command line parameters.

**Features**:
- Command-line parameters
- Batch processing capability
- Non-interactive execution

**Usage**:
```bash
./useradd-sudo-key-p.sh username "ssh-rsa AAAA..."
```

## Requirements

- Bash shell
- Sudo privileges
- Installed sudo package
- User SSH keys

## Workflow

### 1. Install sudo
```bash
apt-get install sudo -y
```

### 2. Create user
```bash
sudo adduser --disabled-password --gecos "" $USERNAME
```

### 3. Add to sudo group
```bash
sudo usermod -aG sudo $USERNAME
```

### 4. Setup SSH directory
```bash
sudo mkdir -p /home/$USERNAME/.ssh
sudo touch /home/$USERNAME/.ssh/authorized_keys
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME /home/$USERNAME/.ssh
```

### 5. Add public key
```bash
sudo sh -c "echo $PUBLIC_KEY > /home/$USERNAME/.ssh/authorized_keys"
```

### 6. Configure passwordless sudo
```bash
sudo sh -c "echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USERNAME-user"
```

## Security

### SSH Keys
- Only public keys are used
- Private keys remain with user
- Automatic permission configuration

### Sudo Privileges
- User gets full sudo access
- No password required for sudo commands
- Settings isolated in separate file

### Access Rights
- SSH directory: 700 (owner only)
- authorized_keys: 600 (owner only)
- Proper file ownership

## Usage Examples

### Creating developer user
```bash
# Edit script
USERNAME="developer"
PUBLIC_KEY="ssh-rsa AAAA... developer@workstation"

# Run
./useradd-sudo-key.sh
```

### Batch user creation
```bash
# Create users file
cat > users.txt << EOF
john:ssh-rsa AAAA... john@laptop
jane:ssh-rsa AAAA... jane@desktop
EOF

# Process each user
while IFS=: read -r username key; do
    USERNAME="$username" PUBLIC_KEY="$key" ./useradd-sudo-key.sh
done < users.txt
```

## Monitoring and Logging

### Check created users
```bash
# User list
cat /etc/passwd | grep -E ":/home/"

# Check sudo privileges
sudo -l -U username

# Check SSH keys
cat /home/username/.ssh/authorized_keys
```

### Sudo logs
```bash
# View sudo logs
sudo tail -f /var/log/auth.log | grep sudo
```

## Troubleshooting

### "Permission denied" Error
```bash
chmod +x useradd-sudo-key.sh
```

### "sudo: command not found" Error
```bash
# Install sudo
apt-get update && apt-get install sudo -y
```

### SSH connection issues
```bash
# Check permissions
ls -la /home/username/.ssh/
# Check authorized_keys content
cat /home/username/.ssh/authorized_keys
```

### Sudo issues
```bash
# Check sudoers file
sudo cat /etc/sudoers.d/username-user
# Check syntax
sudo visudo -c
```

## Automation

### CI/CD Integration
```bash
# GitLab CI example
create_user:
  script:
    - USERNAME="$CI_COMMIT_AUTHOR" 
    - PUBLIC_KEY="$SSH_PUBLIC_KEY"
    - ./useradd-sudo-key.sh
```

### Cron setup
```bash
# Scheduled user creation
0 9 * * 1 /path/to/useradd-sudo-key.sh username "key"
```

## Extending Functionality

### Adding additional groups
```bash
# Add to docker group
sudo usermod -aG docker $USERNAME
```

### Additional SSH options
```bash
# Create sshd_config for user
sudo tee /home/$USERNAME/.ssh/config << EOF
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
```

### Umask configuration
```bash
# Set umask for user
echo "umask 022" >> /home/$USERNAME/.bashrc
```

## Backup and Recovery

### Export users
```bash
# Create user list with keys
for user in $(ls /home/); do
    if [ -f "/home/$user/.ssh/authorized_keys" ]; then
        echo "$user:$(cat /home/$user/.ssh/authorized_keys)"
    fi
done > users_backup.txt
```

### Restore users
```bash
# Restore from backup
while IFS=: read -r username key; do
    USERNAME="$username" PUBLIC_KEY="$key" ./useradd-sudo-key.sh
done < users_backup.txt
```

## License

Scripts are distributed under the same license as the main project.

## Support

For questions and suggestions, create an issue in the project repository.
