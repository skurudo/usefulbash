# Useful Bash Scripts Collection

A comprehensive collection of useful bash scripts for system administration, DevOps, and automation tasks.

**🇺🇸 English version** | **🇷🇺 Русская версия**: [README-ru.md](README-ru.md)

## Table of Contents

- [System Administration](#system-administration)
- [GitLab Management](#gitlab-management)
- [Monitoring & Backup](#monitoring--backup)
- [Cloud Services](#cloud-services)

## System Administration

### Environment Selection and Configuration
**Script**: [project-env-select-and-change.sh](project-env-select-and-change.sh)

Interactive script for selecting and switching between different environments (DEV/PROD). Automatically configures Yandex Cloud CLI, sets environment variables, and navigates to appropriate Terraform directories.

**Purpose**: Interactive environment switching for development and production with automatic Yandex Cloud CLI configuration and environment variable management.

**Features:**
- Interactive menu for environment selection
- Automatic Yandex Cloud folder configuration
- Environment-specific variable setup
- Terraform directory navigation

**Usage:**
```bash
./project-env-select-and-change.sh
```

### User Management with Sudo and SSH Keys

**Purpose**: Automate user creation with full sudo privileges and SSH key authentication for secure server access.

#### Basic Version
**Script**: [useradd-sudo-key.sh](useradd-sudo-key.sh)

Simple script to add a user with passwordless sudo access and SSH key authentication.

**Features:**
- Creates user with disabled password
- Adds user to sudo group
- Sets up SSH key authentication
- Configures passwordless sudo

**Usage:**
```bash
# Edit script to set USERNAME and PUBLIC_KEY variables
nano useradd-sudo-key.sh
./useradd-sudo-key.sh
```

#### Interactive Version
**Script**: [useradd-sudo-key-i.sh](useradd-sudo-key-i.sh)

Interactive version that prompts for username and public key during execution.

**Features:**
- Interactive input prompts
- Real-time user creation
- Immediate SSH key setup

#### Parameterized Version
**Script**: [useradd-sudo-key-p.sh](useradd-sudo-key-p.sh)

Command-line parameter version for automation and scripting.

**Features:**
- Command-line parameters
- Batch processing capability
- Non-interactive execution

## GitLab Management

### GitLab Project Export Tool (New Version)
**Directory**: [gitlab-export-import-v2/](gitlab-export-import-v2/)

Advanced GitLab project export automation tool with comprehensive features.

**Purpose**: Comprehensive GitLab project backup and export with automatic project discovery, YAML configuration, and detailed logging.

**Features:**
- Automatic project discovery via GitLab API
- Individual project archives (.tar.gz)
- YAML configuration generation
- Detailed logging and error handling
- Dependency checking
- Cron job automation support

**Scripts:**
- `gitlab_export.sh` - Main export script
- `gitlab_export-en.sh` - English version

**Documentation**: [gitlab-export-import-v2/readme-en.md](gitlab-export-import-v2/readme-en.md)

### GitLab Project Export Tool (Legacy Version)
**Directory**: [gitlab-export-import/](gitlab-export-import/)

Original version of the GitLab export tool with basic functionality.

**Purpose**: Basic GitLab project export functionality for simple backup requirements and legacy systems.

**Scripts:**
- `start.sh` - Export with existing project list
- `start2.sh` - Full export with project list generation
- `config-creation.sh` - Configuration file generator
- `get-all-projects.sh` - Project list fetcher

**Documentation**: [gitlab-export-import/readme.md](gitlab-export-import/readme.md)

## Monitoring & Backup

### Oxidized Backup Monitoring
**Script**: [oxidized-check-file-and-send-notify.sh](oxidized-check-file-and-send-notify.sh)

Monitors Oxidized backup failures and sends Telegram notifications.

**Purpose**: Monitor Oxidized backup failures and send instant Telegram notifications with automatic log file cleanup.

**Features:**
- Monitors failed backup log file
- Parses error information
- Sends formatted Telegram notifications
- Automatic log file cleanup
- HTML message formatting

**Configuration:**
- Set `API_TOKEN` for Telegram bot
- Set `CHAT_ID` for target chat
- Configure log file path

**Usage:**
```bash
# Edit script to set API_TOKEN and CHAT_ID
nano oxidized-check-file-and-send-notify.sh
./oxidized-check-file-and-send-notify.sh
```

### Zabbix Agent Installer
**Script**: [zabbix-add-agent-on-debian.sh](zabbix-add-agent-on-debian.sh)

**YASZAIT** - Yet Another Simple Zabbix Agent Installer Tool for Debian-based systems.

**Purpose**: Automated Zabbix agent installation and configuration with interactive setup and service status verification.

**Features:**
- Interactive server configuration
- Automatic Zabbix agent installation
- Custom configuration file generation
- Service status verification
- IP address information display

**Usage:**
```bash
./zabbix-add-agent-on-debian.sh
```

**Configuration Options:**
- Server hostname
- Zabbix server address
- Listening port (default: 10050)

## Cloud Services

### Yandex.Connect User Management
**Script**: [yandex-connect-mass-user-add.sh](yandex-connect-mass-user-add.sh)

Mass user creation tool for Yandex.Connect using the Directory API.

**Purpose**: Bulk user creation in Yandex.Connect through Directory API with OAuth authentication and batch processing.

**Features:**
- Batch user creation from file
- OAuth token authentication
- Customizable user attributes
- Department assignment
- Position and password setting

**File Format:**
```
email_lastname_firstname_middlename_password_position
```

**Usage:**
```bash
# Edit script to set OAuth TOKEN
nano yandex-connect-mass-user-add.sh
# Prepare usrlist file with user data
./yandex-connect-mass-user-add.sh
```

## Installation and Setup

### Prerequisites
- Bash 4.0+
- curl
- jq (for JSON processing)
- Python 3 (for GitLab export tools)
- sudo access for user management scripts

### System Requirements
- Debian/Ubuntu-based systems (for most scripts)
- Network access for API calls
- Appropriate permissions for system modifications

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve these scripts.

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Support

For questions or issues, please check the individual project documentation or create an issue in the repository.
