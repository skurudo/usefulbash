# GitLab Project Export Script Documentation

### Overview

This bash script automates the export of all GitLab projects using the `gitlab-project-export` tool by rvojcik. The script retrieves all projects from a GitLab instance, creates a configuration file, and exports each project to a separate archive.

### Features

- **Automatic project discovery**: Retrieves all projects via GitLab API
- **Individual archives**: Each project is exported to a separate `.tar.gz` file
- **No manual intervention**: Fully automated process without interactive prompts
- **Detailed logging**: Comprehensive logs of the export process
- **Error handling**: Reliable error detection and reporting
- **Dependency checking**: Verifies installation of all required tools

### Prerequisites

#### Required Software
- `bash` (version 4.0+)
- `curl`
- `jq`
- `python3`
- `gitlab-project-export` by rvojcik

#### Installation Commands

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install curl jq python3 python3-pip

# Install gitlab-project-export
pip install gitlab-project-export

# Or install from source
git clone https://github.com/rvojcik/gitlab-project-export
cd gitlab-project-export/
pip install -r requirements.txt
```

#### GitLab Access Token

Create a personal access token in GitLab with the following permissions:
- `api`
- `read_user`
- `read_repository`

**Token creation steps:**
1. Go to GitLab → User Settings → Access Tokens
2. Create a new token with required permissions
3. Copy the generated token

### Configuration

#### Basic Setup

1. **Download the script** and make it executable:
```bash
chmod +x gitlab_export.sh
```

2. **Edit the script** and replace the token:
```bash
# Open the script in an editor
nano gitlab_export.sh

# Find this line and replace with your token:
GITLAB_TOKEN="YOUR_GITLAB_TOKEN_HERE"
```

3. **Update GitLab URL** if using your own instance:
```bash
GITLAB_URL="https://your-gitlab-instance.com"
```

#### Configuration Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `GITLAB_URL` | GitLab instance URL | `https://lab.nobr.ru` |
| `GITLAB_TOKEN` | Personal access token | `YOUR_GITLAB_TOKEN_HERE` |
| `EXPORT_DIR` | Export directory | `gitlab_exports` |
| `PROJECTS_LIST_FILE` | Projects list JSON file | `projects_list.json` |
| `EXPORTED_PROJECTS_FILE` | Export log file | `exported_projects.log` |
| `CONFIG_FILE` | YAML configuration file | `gitlab_export_config.yml` |

### Usage

#### Basic Usage

```bash
# Run with token configured in script
./gitlab_export.sh

# Run with token as command argument
./gitlab_export.sh "glpat-your-token-here"

# Run with environment variable
export GITLAB_TOKEN="glpat-your-token-here"
./gitlab_export.sh
```

#### Advanced Usage

```bash
# Run with custom timeout (default: 2 hours)
timeout 14400 ./gitlab_export.sh  # 4 hour timeout

# Run in background with logging
nohup ./gitlab_export.sh > export.log 2>&1 &

# Run with specified directory
EXPORT_DIR="/backup/gitlab" ./gitlab_export.sh
```

### Output Files

#### Directory Structure

```
./
├── gitlab_export.sh              # Main script
├── projects_list.json           # List of all projects
├── exported_projects.log        # Export results log
├── gitlab_export_config.yml     # Generated config file
└── gitlab_exports/              # Export directory
    ├── project1-20250716_143022.tar.gz
    ├── project2-20250716_143045.tar.gz
    └── project3-20250716_143108.tar.gz
```

#### File Descriptions

- **`projects_list.json`**: Complete list of projects from GitLab API
- **`exported_projects.log`**: Log file with export results and file sizes
- **`gitlab_export_config.yml`**: Automatically generated YAML configuration
- **`gitlab_exports/`**: Directory containing individual project archives

#### Archive Naming Convention

Files are named using the pattern: `{PROJECT_NAME}-{TIMESTAMP}.tar.gz`

Example: `my-awesome-project-20250716_143022.tar.gz`

### Script Workflow

1. **Dependency check**: Verifies installation of required tools
2. **Token validation**: Tests access to GitLab API
3. **Project discovery**: Retrieves all available projects
4. **Configuration generation**: Creates YAML configuration file
5. **Export execution**: Runs gitlab-project-export tool
6. **Results summary**: Displays export statistics

### Error Handling

#### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Authorization error (HTTP 401)` | Invalid token | Check token validity and permissions |
| `gitlab-project-export.py not found` | Tool not installed | Install via pip |
| `Missing required utilities` | Missing dependencies | Install curl, jq, python3 |
| `Export error (code: 124)` | Timeout | Increase timeout or check network |
| `No exported files found` | Export failed | Check logs and token permissions |

#### Debug Mode

Enable debug output by modifying the script:
```bash
# Add after set -e
set -x  # Enable debug mode
```

### Automation

#### Cron Job Setup

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/gitlab_export.sh >> /var/log/gitlab_backup.log 2>&1

# Add weekly backup on Sundays
0 2 * * 0 /path/to/gitlab_export.sh
```

#### Systemd Timer (Alternative)

Create service file `/etc/systemd/system/gitlab-backup.service`:
```ini
[Unit]
Description=GitLab Project Backup
After=network.target

[Service]
Type=oneshot
User=backup
ExecStart=/path/to/gitlab_export.sh
WorkingDirectory=/backup
```

Create timer file `/etc/systemd/system/gitlab-backup.timer`:
```ini
[Unit]
Description=Run GitLab backup daily
Requires=gitlab-backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Enable timer:
```bash
sudo systemctl enable gitlab-backup.timer
sudo systemctl start gitlab-backup.timer
```

### Performance Considerations

- **Network bandwidth**: Large repositories require significant bandwidth
- **Disk space**: Ensure sufficient space for all project archives
- **API limitations**: GitLab may limit API requests
- **Timeout settings**: Configure timeout for large projects

#### Recommended Settings

- **Small instance** (< 50 projects): Default settings work well
- **Medium instance** (50-200 projects): Increase timeout to 4-6 hours
- **Large instance** (200+ projects): Consider splitting export by groups

### Security Notes

- **Token security**: Never commit tokens to version control
- **File permissions**: Restrict access to exported files
- **Network security**: Use HTTPS for GitLab connections
- **Backup encryption**: Consider encrypting exported archives

### Troubleshooting

#### Detailed Logging

Add detailed logging to the script:
```bash
# Enable verbose curl output
curl -v -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/user"

# Add debug prints
log_info "Debug: Processing project ID $project_id"
```

#### Manual Testing

Testing individual components:
```bash
# Test API access
curl -H "PRIVATE-TOKEN: your-token" "https://gitlab.com/api/v4/user"

# Manual project export test
gitlab-project-export.py -c config.yml -d

# Check project permissions
curl -H "PRIVATE-TOKEN: your-token" "https://gitlab.com/api/v4/projects/123"
```