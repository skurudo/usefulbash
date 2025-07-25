#!/bin/bash

# GitLab Project Export Script
# Works with gitlab-project-export by rvojcik
# https://github.com/rvojcik/gitlab-project-export

set -e

# Configuration
GITLAB_URL="https://lab.nobr.ru"
GITLAB_TOKEN="YOUR_GITLAB_TOKEN_HERE"  # Replace with your token
EXPORT_DIR="gitlab_exports"
PROJECTS_LIST_FILE="projects_list.json"
EXPORTED_PROJECTS_FILE="exported_projects.log"
CONFIG_FILE="gitlab_export_config.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Functions for message output
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required utilities: ${missing_deps[*]}"
        log_info "Install them: sudo apt-get install ${missing_deps[*]}"
        exit 1
    fi
    
    if ! command -v gitlab-project-export.py &> /dev/null && ! [ -f "./gitlab-project-export.py" ]; then
        log_error "gitlab-project-export.py not found"
        log_info "Install it: pip install gitlab-project-export"
        exit 1
    fi
    
    log_success "All dependencies are installed"
}

# Check token
check_token() {
    if [ -z "$GITLAB_TOKEN" ] || [ "$GITLAB_TOKEN" = "YOUR_GITLAB_TOKEN_HERE" ]; then
        log_error "GitLab token not set!"
        log_info "Edit the script and replace YOUR_GITLAB_TOKEN_HERE"
        exit 1
    fi
    
    log_info "Checking GitLab token..."
    
    local response=$(curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/user" \
        -w "%{http_code}")
    
    local http_code="${response: -3}"
    local user_info="${response%???}"
    
    if [ "$http_code" != "200" ]; then
        log_error "Authorization error (HTTP $http_code)"
        exit 1
    fi
    
    local username=$(echo "$user_info" | jq -r '.username')
    log_success "Authorization successful: $username"
}

# Get projects list
get_projects_list() {
    log_info "Getting list of all projects..."
    
    local all_projects=()
    local page=1
    local per_page=100
    
    while true; do
        log_info "Loading page $page..."
        
        local response=$(curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            "$GITLAB_URL/api/v4/projects?page=$page&per_page=$per_page&simple=true&archived=false&membership=true" \
            -w "%{http_code}")
        
        local http_code="${response: -3}"
        local projects_data="${response%???}"
        
        if [ "$http_code" != "200" ]; then
            log_error "Error getting projects (HTTP $http_code)"
            exit 1
        fi
        
        local projects_count=$(echo "$projects_data" | jq '. | length')
        
        if [ "$projects_count" -eq 0 ]; then
            break
        fi
        
        all_projects+=("$projects_data")
        page=$((page + 1))
    done
    
    # Combine all pages
    local combined_json="["
    for i in "${!all_projects[@]}"; do
        if [ $i -gt 0 ]; then
            combined_json+=","
        fi
        combined_json+="${all_projects[$i]:1:-1}"
    done
    combined_json+="]"
    
    echo "$combined_json" > "$PROJECTS_LIST_FILE"
    
    local total_projects=$(echo "$combined_json" | jq '. | length')
    log_success "Found projects: $total_projects"
}

# Create configuration
create_config_file() {
    log_info "Creating configuration file..."
    
    local projects=$(cat "$PROJECTS_LIST_FILE")
    local total_projects=$(echo "$projects" | jq '. | length')
    
    local projects_yaml=""
    for i in $(seq 0 $((total_projects - 1))); do
        local project=$(echo "$projects" | jq ".[$i]")
        local project_path=$(echo "$project" | jq -r '.path_with_namespace')
        projects_yaml+="  - $project_path"$'\n'
    done
    
    cat > "$CONFIG_FILE" << EOF
gitlab:
  access:
    gitlab_url: "$GITLAB_URL"
    token: "$GITLAB_TOKEN"
  projects:
$projects_yaml
backup:
  destination: "$EXPORT_DIR"
  project_dirs: true
  backup_name: "{PROJECT_NAME}-{TIME}.tar.gz"
  backup_time_format: "%Y%m%d_%H%M%S"
  retention_period: 0
EOF
    
    log_success "Configuration created: $CONFIG_FILE"
    log_info "Each project will be in a separate archive"
}

# Export projects
export_projects() {
    log_info "Starting projects export..."
    
    mkdir -p "$EXPORT_DIR"
    > "$EXPORTED_PROJECTS_FILE"
    
    local export_cmd=""
    if command -v gitlab-project-export.py &> /dev/null; then
        export_cmd="gitlab-project-export.py"
    elif [ -f "./gitlab-project-export.py" ]; then
        export_cmd="python3 ./gitlab-project-export.py"
    else
        log_error "gitlab-project-export.py not found"
        exit 1
    fi
    
    log_info "Export command: $export_cmd"
    
    local export_output=$(mktemp)
    local export_error=$(mktemp)
    
    log_info "Starting export..."
    
    if timeout 7200 $export_cmd -c "$CONFIG_FILE" -d > "$export_output" 2> "$export_error"; then
        log_success "Export completed successfully"
        
        if [ -s "$export_output" ]; then
            log_info "Export result:"
            cat "$export_output"
        fi
        
        local exported_count=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
        log_success "Exported files: $exported_count"
        
        find "$EXPORT_DIR" -name "*.tar.gz" -type f | while read -r file; do
            local filename=$(basename "$file")
            local size=$(du -h "$file" | cut -f1)
            echo "SUCCESS: $filename - $size" >> "$EXPORTED_PROJECTS_FILE"
        done
        
    else
        local exit_code=$?
        log_error "Export error (code: $exit_code)"
        
        if [ -s "$export_error" ]; then
            log_error "Error details:"
            cat "$export_error"
        fi
        
        if [ -s "$export_output" ]; then
            log_info "Command output:"
            cat "$export_output"
        fi
        
        echo "FAILED: Export failed - exit code $exit_code" >> "$EXPORTED_PROJECTS_FILE"
        
        local partial_count=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
        if [ $partial_count -gt 0 ]; then
            log_warning "Partially exported files: $partial_count"
        fi
    fi
    
    # Clean up temporary files
    rm -f "$export_output" "$export_error"
    
    if [ -d "$EXPORT_DIR" ]; then
        log_info "Export statistics:"
        local total_size=$(du -sh "$EXPORT_DIR" 2>/dev/null | cut -f1)
        local file_count=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
        log_info "Total size: $total_size"
        log_info "Number of files: $file_count"
        
        if [ $file_count -gt 0 ]; then
            log_info "Exported files:"
            find "$EXPORT_DIR" -name "*.tar.gz" -type f | while read -r file; do
                local filename=$(basename "$file")
                local size=$(du -h "$file" | cut -f1)
                log_info "  $filename ($size)"
            done
        fi
    fi
}

# Main function
main() {
    log_info "Starting GitLab projects export"
    log_info "GitLab URL: $GITLAB_URL"
    log_info "Start time: $(date)"
    
    if [ $# -eq 1 ]; then
        GITLAB_TOKEN="$1"
        log_info "Token passed as argument"
    fi
    
    check_dependencies
    check_token
    get_projects_list
    create_config_file
    export_projects
    
    log_success "Export completed!"
    log_info "Exported files in: $EXPORT_DIR"
    log_info "Export log: $EXPORTED_PROJECTS_FILE"
    log_info "End time: $(date)"
    
    local exported_files=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
    if [ $exported_files -gt 0 ]; then
        log_success "Total exported: $exported_files files"
        local total_size=$(du -sh "$EXPORT_DIR" 2>/dev/null | cut -f1)
        log_info "Total size: $total_size"
    else
        log_warning "No exported files found"
    fi
}

# Signal handling
trap 'log_error "Script interrupted"; exit 1' INT TERM

# Run script
main "$@"