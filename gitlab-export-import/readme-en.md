# GitLab Project Export Tool (Legacy Version)

Legacy version of the GitLab project export tool with basic functionality for exporting projects and generating project lists.

## Overview

This tool provides a simple approach to export GitLab projects using a combination of bash scripts and Python tools. It includes functionality for both generating project lists and performing exports based on existing lists.

## Scripts

### Main Scripts

#### `start2.sh`
Launches a sequence of events: generates a project list and immediately exports files.

**Features:**
- Automatic project list generation
- Immediate export execution
- Complete workflow automation

**Usage:**
```bash
./start2.sh
```

#### `start.sh`
Runs export when a ready project list is available.

**Features:**
- Export based on existing project list
- Faster execution for repeated exports
- Requires pre-generated project list

**Usage:**
```bash
./start.sh
```

### Configuration Scripts

#### `config-creation.sh`
Processes `config-template.yaml`, adds repository information, and creates `config.yaml`.

**Features:**
- Template processing
- Configuration file generation
- Repository-specific settings

**Usage:**
```bash
./config-creation.sh
```

#### `get-all-projects.sh`
Script for obtaining project list via API (requires GitLab URL and token).

**Features:**
- API-based project discovery
- Project list generation
- Namespace path extraction

**Usage:**
```bash
# Edit script to set GitLab URL and token
nano get-all-projects.sh
./get-all-projects.sh
```

### Configuration Files

#### `config-template.yaml`
Template for `gitlab-project-export.py` (requires GitLab URL, token, and export directory specification).

**Required fields:**
- GitLab instance URL
- Access token
- Export directory path
- Project-specific settings

#### `config.yaml`
Generated configuration file created from `config-template.yaml`.

**Features:**
- Ready-to-use configuration
- Repository-specific settings
- Export directory configuration

### Data Files

#### `gitlab_path_with_namespace.txt`
Text file containing project information.

**Format:**
- One project per line
- Namespace path format
- Used for export processing

## Workflow

### Complete Export Process
1. Run `start2.sh` to generate project list and export
2. Script automatically processes all projects
3. Creates individual export files for each project

### Export with Existing List
1. Ensure `gitlab_path_with_namespace.txt` exists
2. Run `start.sh` for export execution
3. Uses existing project list for faster processing

### Configuration Setup
1. Edit `config-template.yaml` with your settings
2. Run `config-creation.sh` to generate config
3. Use generated `config.yaml` for exports

## Prerequisites

- Bash shell
- Python 3
- `gitlab-project-export` tool
- GitLab API access
- Appropriate permissions for file operations

## Installation

1. Clone or download the repository
2. Make scripts executable:
```bash
chmod +x *.sh
```

3. Install required Python tool:
```bash
pip install gitlab-project-export
```

## Configuration

### GitLab Access
- Set GitLab instance URL
- Configure access token with appropriate permissions
- Ensure API access is enabled

### Export Settings
- Specify export directory
- Configure project-specific options
- Set appropriate timeouts for large projects

## Usage Examples

### First-time Setup
```bash
# Generate project list and export
./start2.sh
```

### Subsequent Exports
```bash
# Export using existing project list
./start.sh
```

### Manual Configuration
```bash
# Generate configuration from template
./config-creation.sh
```

## Output

- Project list file (`gitlab_path_with_namespace.txt`)
- Individual project export files
- Configuration files for export tool
- Log files with export results

## Notes

- This is the legacy version of the export tool
- Consider using the newer version (`gitlab-export-import-v2`) for enhanced features
- Basic functionality suitable for simple export requirements
- Manual intervention may be required for complex configurations

## Support

For issues or questions:
1. Check script permissions and dependencies
2. Verify GitLab API access
3. Review configuration file settings
4. Check export directory permissions
