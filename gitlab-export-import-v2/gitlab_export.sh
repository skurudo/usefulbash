#!/bin/bash

# GitLab Project Export Script
# Работает с gitlab-project-export от rvojcik
# https://github.com/rvojcik/gitlab-project-export

set -e

# Конфигурация
GITLAB_URL="https://example.gitlab.com"
GITLAB_TOKEN="YOUR_GITLAB_TOKEN_HERE"
EXPORT_DIR="gitlab_exports"
PROJECTS_LIST_FILE="projects_list.json"
EXPORTED_PROJECTS_FILE="exported_projects.log"
CONFIG_FILE="gitlab_export_config.yml"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функции для вывода сообщений
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

# Проверка зависимостей
check_dependencies() {
    log_info "Проверка зависимостей..."
    
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
        log_error "Отсутствуют необходимые утилиты: ${missing_deps[*]}"
        log_info "Установите их: sudo apt-get install ${missing_deps[*]}"
        exit 1
    fi
    
    if ! command -v gitlab-project-export.py &> /dev/null && ! [ -f "./gitlab-project-export.py" ]; then
        log_error "gitlab-project-export.py не найден"
        log_info "Установите: pip install gitlab-project-export"
        exit 1
    fi
    
    log_success "Все зависимости установлены"
}

# Проверка токена
check_token() {
    if [ -z "$GITLAB_TOKEN" ] || [ "$GITLAB_TOKEN" = "YOUR_GITLAB_TOKEN_HERE" ]; then
        log_error "Токен GitLab не задан!"
        log_info "Отредактируйте скрипт и замените YOUR_GITLAB_TOKEN_HERE"
        exit 1
    fi
    
    log_info "Проверка токена GitLab..."
    
    local response=$(curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/user" \
        -w "%{http_code}")
    
    local http_code="${response: -3}"
    local user_info="${response%???}"
    
    if [ "$http_code" != "200" ]; then
        log_error "Ошибка авторизации (HTTP $http_code)"
        exit 1
    fi
    
    local username=$(echo "$user_info" | jq -r '.username')
    log_success "Авторизация успешна: $username"
}

# Получение списка проектов
get_projects_list() {
    log_info "Получение списка всех проектов..."
    
    local all_projects=()
    local page=1
    local per_page=100
    
    while true; do
        log_info "Загрузка страницы $page..."
        
        local response=$(curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            "$GITLAB_URL/api/v4/projects?page=$page&per_page=$per_page&simple=true&archived=false&membership=true" \
            -w "%{http_code}")
        
        local http_code="${response: -3}"
        local projects_data="${response%???}"
        
        if [ "$http_code" != "200" ]; then
            log_error "Ошибка получения проектов (HTTP $http_code)"
            exit 1
        fi
        
        local projects_count=$(echo "$projects_data" | jq '. | length')
        
        if [ "$projects_count" -eq 0 ]; then
            break
        fi
        
        all_projects+=("$projects_data")
        page=$((page + 1))
    done
    
    # Объединяем все страницы
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
    log_success "Найдено проектов: $total_projects"
}

# Создание конфигурации
create_config_file() {
    log_info "Создание конфигурационного файла..."
    
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
    
    log_success "Конфигурация создана: $CONFIG_FILE"
    log_info "Каждый проект будет в отдельном архиве"
}

# Экспорт проектов
export_projects() {
    log_info "Начинаем экспорт проектов..."
    
    mkdir -p "$EXPORT_DIR"
    > "$EXPORTED_PROJECTS_FILE"
    
    local export_cmd=""
    if command -v gitlab-project-export.py &> /dev/null; then
        export_cmd="gitlab-project-export.py"
    elif [ -f "./gitlab-project-export.py" ]; then
        export_cmd="python3 ./gitlab-project-export.py"
    else
        log_error "gitlab-project-export.py не найден"
        exit 1
    fi
    
    log_info "Команда экспорта: $export_cmd"
    
    local export_output=$(mktemp)
    local export_error=$(mktemp)
    
    log_info "Запуск экспорта..."
    
    if timeout 7200 $export_cmd -c "$CONFIG_FILE" -d > "$export_output" 2> "$export_error"; then
        log_success "Экспорт завершен успешно"
        
        if [ -s "$export_output" ]; then
            log_info "Результат экспорта:"
            cat "$export_output"
        fi
        
        local exported_count=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
        log_success "Экспортировано файлов: $exported_count"
        
        find "$EXPORT_DIR" -name "*.tar.gz" -type f | while read -r file; do
            local filename=$(basename "$file")
            local size=$(du -h "$file" | cut -f1)
            echo "SUCCESS: $filename - $size" >> "$EXPORTED_PROJECTS_FILE"
        done
        
    else
        local exit_code=$?
        log_error "Ошибка экспорта (код: $exit_code)"
        
        if [ -s "$export_error" ]; then
            log_error "Детали ошибки:"
            cat "$export_error"
        fi
        
        if [ -s "$export_output" ]; then
            log_info "Вывод команды:"
            cat "$export_output"
        fi
        
        echo "FAILED: Export failed - exit code $exit_code" >> "$EXPORTED_PROJECTS_FILE"
        
        local partial_count=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
        if [ $partial_count -gt 0 ]; then
            log_warning "Частично экспортировано файлов: $partial_count"
        fi
    fi
    
    rm -f "$export_output" "$export_error"
    
    if [ -d "$EXPORT_DIR" ]; then
        log_info "Статистика экспорта:"
        local total_size=$(du -sh "$EXPORT_DIR" 2>/dev/null | cut -f1)
        local file_count=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
        log_info "Общий размер: $total_size"
        log_info "Количество файлов: $file_count"
        
        if [ $file_count -gt 0 ]; then
            log_info "Экспортированные файлы:"
            find "$EXPORT_DIR" -name "*.tar.gz" -type f | while read -r file; do
                local filename=$(basename "$file")
                local size=$(du -h "$file" | cut -f1)
                log_info "  $filename ($size)"
            done
        fi
    fi
}

# Основная функция
main() {
    log_info "Запуск экспорта проектов GitLab"
    log_info "GitLab URL: $GITLAB_URL"
    log_info "Время начала: $(date)"
    
    if [ $# -eq 1 ]; then
        GITLAB_TOKEN="$1"
        log_info "Токен передан как аргумент"
    fi
    
    check_dependencies
    check_token
    get_projects_list
    create_config_file
    export_projects
    
    log_success "Экспорт завершен!"
    log_info "Экспортированные файлы в: $EXPORT_DIR"
    log_info "Лог экспорта: $EXPORTED_PROJECTS_FILE"
    log_info "Время завершения: $(date)"
    
    local exported_files=$(find "$EXPORT_DIR" -name "*.tar.gz" -type f | wc -l)
    if [ $exported_files -gt 0 ]; then
        log_success "Всего экспортировано: $exported_files файлов"
        local total_size=$(du -sh "$EXPORT_DIR" 2>/dev/null | cut -f1)
        log_info "Общий размер: $total_size"
    else
        log_warning "Экспортированных файлов не найдено"
    fi
}

# Обработка сигналов
trap 'log_error "Скрипт прерван"; exit 1' INT TERM

# Запуск
main "$@"