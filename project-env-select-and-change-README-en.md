# Environment Selection and Configuration Script

## Description

Interactive bash script for selecting and switching between different development environments (DEV/PROD). Automatically configures Yandex Cloud CLI, sets environment variables, and navigates to appropriate Terraform directories.

## Features

- **Interactive Menu**: Environment selection through convenient menu
- **Automatic Yandex Cloud Setup**: Folder and CLI configuration
- **Environment Variable Management**: Setting ACCESS_KEY and SECRET_KEY
- **Directory Navigation**: Automatic navigation to appropriate Terraform folders
- **Colorized Output**: Different colors for different environments (green for DEV, red for PROD)

## Requirements

- Bash shell
- Installed Yandex Cloud CLI (`yc`)
- Access to directories `/opt/terraform/dev` and `/opt/terraform/prod`
- Git repository in `/opt/terraform`

## Script Structure

### Color Schemes
- **DEV**: Green color (`\e[32m`)
- **PROD**: Red color (`\e[31m`)
- **Warnings**: Yellow color (`\e[33m`)
- **Regular text**: White color (`\e[97m`)

### Functions

#### `DEV()`
- Navigates to `/opt/terraform/dev`
- Updates git repository
- Configures Yandex Cloud folder
- Sets environment variables for DEV
- Launches new shell

#### `PROD()`
- Navigates to `/opt/terraform/prod`
- Updates git repository
- Configures Yandex Cloud folder
- Sets environment variables for PROD
- Launches new shell

#### `Not-sure()`
- Displays message about need to decide
- Terminates script execution

## Usage

### Launch
```bash
./project-env-select-and-change.sh
```

### Interactive Menu
```
Enter your choice and define environment:
1) DEV
2) PROD
3) Not-sure
4) Exit
```

## Configuration

### Before use, edit the following:

1. **Folder ID for DEV**:
```bash
yc config set folder-id some-folder-id
```

2. **Folder ID for PROD**:
```bash
yc config set folder-id some-folder-id
```

3. **Environment Variables**:
```bash
export ACCESS_KEY=ACCESS_KEY
export SECRET_KEY=SECRET_KEY
```

### Recommended Directory Structure
```
/opt/terraform/
├── .git/
├── dev/
│   ├── main.tf
│   └── variables.tf
└── prod/
    ├── main.tf
    └── variables.tf
```

## Usage Examples

### Selecting DEV Environment
```bash
$ ./project-env-select-and-change.sh
Enter your choice and define environment:
1) DEV
2) PROD
3) Not-sure
4) Exit
1
You selected  DEV .
DEV environment selected
```

### Selecting PROD Environment
```bash
$ ./project-env-select-and-change.sh
Enter your choice and define environment:
1) DEV
2) PROD
3) Not-sure
4) Exit
2
You selected  PROD .
PROD environment selected
```

## Security

- Script launches new shell with set variables
- Environment variables available only in current session
- Variables reset when exiting shell

## Automation

### Adding to .bashrc
```bash
# Add to ~/.bashrc for quick access
alias env-switch='/path/to/project-env-select-and-change.sh'
```

### Creating Symbolic Link
```bash
sudo ln -s /path/to/project-env-select-and-change.sh /usr/local/bin/env-switch
```

## Troubleshooting

### "Permission denied" Error
```bash
chmod +x project-env-select-and-change.sh
```

### "yc: command not found" Error
```bash
# Install Yandex Cloud CLI
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

### "No such file or directory" Error
```bash
# Create necessary directories
sudo mkdir -p /opt/terraform/{dev,prod}
sudo chown $USER:$USER /opt/terraform/{dev,prod}
```

## Extending Functionality

### Adding New Environments
```bash
# Add new function
function STAGING {
    echo -e "You selected ${BLUE} STAGING ${ENDCOLOR}."
    cd /opt/terraform/staging
    # ... staging settings
}
```

### Adding New Variables
```bash
export REGION=ru-central1
export PROJECT_ID=your-project-id
```

## License

Script is distributed under the same license as the main project.

## Support

For questions and suggestions, create an issue in the project repository.
