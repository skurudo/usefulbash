# GitLab Project Export Script Documentation

### Обзор

Данный bash-скрипт автоматизирует экспорт всех проектов GitLab, используя инструмент `gitlab-project-export` от rvojcik. Скрипт получает все проекты из экземпляра GitLab, создает конфигурационный файл и экспортирует каждый проект в отдельный архив.

### Возможности

- **Автоматическое обнаружение проектов**: Получение всех проектов через GitLab API
- **Индивидуальные архивы**: Каждый проект экспортируется в отдельный `.tar.gz` файл
- **Без ручного вмешательства**: Полностью автоматизированный процесс без интерактивных запросов
- **Подробное логирование**: Детальные логи процесса экспорта
- **Обработка ошибок**: Надёжное обнаружение и отчёт об ошибках
- **Проверка зависимостей**: Проверка установки всех необходимых инструментов

### Предварительные требования

#### Необходимое ПО
- `bash` (версия 4.0+)
- `curl`
- `jq`
- `python3`
- `gitlab-project-export` от rvojcik

#### Команды установки

```bash
# Установка системных зависимостей (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install curl jq python3 python3-pip

# Установка gitlab-project-export
pip install gitlab-project-export

# Или установка из исходников
git clone https://github.com/rvojcik/gitlab-project-export
cd gitlab-project-export/
pip install -r requirements.txt
```

#### Токен доступа GitLab

Создайте персональный токен доступа в GitLab со следующими правами:
- `api`
- `read_user`
- `read_repository`

**Шаги создания токена:**
1. Перейдите в GitLab → Настройки пользователя → Токены доступа
2. Создайте новый токен с необходимыми правами
3. Скопируйте сгенерированный токен

### Конфигурация

#### Базовая настройка

1. **Загрузите скрипт** и сделайте его исполняемым:
```bash
chmod +x gitlab_export.sh
```

2. **Отредактируйте скрипт** и замените токен:
```bash
# Откройте скрипт в редакторе
nano gitlab_export.sh

# Найдите эту строку и замените на ваш токен:
GITLAB_TOKEN="YOUR_GITLAB_TOKEN_HERE"
```

3. **Обновите URL GitLab** если используете собственный экземпляр:
```bash
GITLAB_URL="https://your-gitlab-instance.com"
```

#### Переменные конфигурации

| Переменная | Описание | Значение по умолчанию |
|------------|----------|-----------------------|
| `GITLAB_URL` | URL экземпляра GitLab | `https://lab.nobr.ru` |
| `GITLAB_TOKEN` | Персональный токен доступа | `YOUR_GITLAB_TOKEN_HERE` |
| `EXPORT_DIR` | Директория экспорта | `gitlab_exports` |
| `PROJECTS_LIST_FILE` | JSON файл списка проектов | `projects_list.json` |
| `EXPORTED_PROJECTS_FILE` | Файл лога экспорта | `exported_projects.log` |
| `CONFIG_FILE` | YAML конфигурационный файл | `gitlab_export_config.yml` |

### Использование

#### Базовое использование

```bash
# Запуск с токеном, настроенным в скрипте
./gitlab_export.sh

# Запуск с токеном как аргументом команды
./gitlab_export.sh "glpat-your-token-here"

# Запуск с переменной окружения
export GITLAB_TOKEN="glpat-your-token-here"
./gitlab_export.sh
```

#### Продвинутое использование

```bash
# Запуск с пользовательским таймаутом (по умолчанию: 2 часа)
timeout 14400 ./gitlab_export.sh  # таймаут 4 часа

# Запуск в фоне с логированием
nohup ./gitlab_export.sh > export.log 2>&1 &

# Запуск с указанной директорией
EXPORT_DIR="/backup/gitlab" ./gitlab_export.sh
```

### Выходные файлы

#### Структура директории

```
./
├── gitlab_export.sh              # Основной скрипт
├── projects_list.json           # Список всех проектов
├── exported_projects.log        # Лог результатов экспорта
├── gitlab_export_config.yml     # Сгенерированный конфиг файл
└── gitlab_exports/              # Директория экспорта
    ├── project1-20250716_143022.tar.gz
    ├── project2-20250716_143045.tar.gz
    └── project3-20250716_143108.tar.gz
```

#### Описание файлов

- **`projects_list.json`**: Полный список проектов из GitLab API
- **`exported_projects.log`**: Лог файл с результатами экспорта и размерами файлов
- **`gitlab_export_config.yml`**: Автоматически сгенерированная YAML конфигурация
- **`gitlab_exports/`**: Директория, содержащая индивидуальные архивы проектов

#### Соглашение об именовании архивов

Файлы именуются по шаблону: `{PROJECT_NAME}-{TIMESTAMP}.tar.gz`

Пример: `my-awesome-project-20250716_143022.tar.gz`

### Рабочий процесс скрипта

1. **Проверка зависимостей**: Проверка установки необходимых инструментов
2. **Валидация токена**: Тестирование доступа к GitLab API
3. **Обнаружение проектов**: Получение всех доступных проектов
4. **Генерация конфигурации**: Создание YAML конфигурационного файла
5. **Выполнение экспорта**: Запуск инструмента gitlab-project-export
6. **Сводка результатов**: Отображение статистики экспорта

### Обработка ошибок

#### Распространённые ошибки и решения

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `Authorization error (HTTP 401)` | Неверный токен | Проверить действительность токена и права |
| `gitlab-project-export.py not found` | Инструмент не установлен | Установить через pip |
| `Missing required utilities` | Отсутствуют зависимости | Установить curl, jq, python3 |
| `Export error (code: 124)` | Таймаут | Увеличить таймаут или проверить сеть |
| `No exported files found` | Экспорт не удался | Проверить логи и права токена |

#### Режим отладки

Включите отладочный вывод, изменив скрипт:
```bash
# Добавьте в начало после set -e
set -x  # Включить режим отладки
```

### Автоматизация

#### Настройка Cron Job

```bash
# Редактировать crontab
crontab -e

# Добавить ежедневное резервное копирование в 2 утра
0 2 * * * /path/to/gitlab_export.sh >> /var/log/gitlab_backup.log 2>&1

# Добавить еженедельное резервное копирование по воскресеньям
0 2 * * 0 /path/to/gitlab_export.sh
```

#### Systemd Timer (альтернатива)

Создать файл сервиса `/etc/systemd/system/gitlab-backup.service`:
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

Создать файл таймера `/etc/systemd/system/gitlab-backup.timer`:
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

Включить таймер:
```bash
sudo systemctl enable gitlab-backup.timer
sudo systemctl start gitlab-backup.timer
```

### Соображения производительности

- **Пропускная способность сети**: Большие репозитории требуют значительной пропускной способности
- **Дисковое пространство**: Убедитесь в достаточном месте для всех архивов проектов
- **Ограничения API**: GitLab может ограничивать API запросы
- **Настройки таймаута**: Настройте таймаут для больших проектов

#### Рекомендуемые настройки

- **Маленький экземпляр** (< 50 проектов): Настройки по умолчанию работают хорошо
- **Средний экземпляр** (50-200 проектов): Увеличить таймаут до 4-6 часов
- **Большой экземпляр** (200+ проектов): Рассмотреть разделение экспорта по группам

### Замечания по безопасности

- **Безопасность токена**: Никогда не коммитьте токены в систему контроля версий
- **Права файлов**: Ограничьте доступ к экспортированным файлам
- **Сетевая безопасность**: Используйте HTTPS для подключений к GitLab
- **Шифрование резервных копий**: Рассмотрите шифрование экспортированных архивов

### Устранение неполадок

#### Подробное логирование

Добавьте подробное логирование в скрипт:
```bash
# Включить детальный вывод curl
curl -v -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/user"

# Добавить отладочные принты
log_info "Debug: Processing project ID $project_id"
```

#### Ручное тестирование

Тестирование отдельных компонентов:
```bash
# Тест доступа к API
curl -H "PRIVATE-TOKEN: your-token" "https://gitlab.com/api/v4/user"

# Ручной тест экспорта проекта
gitlab-project-export.py -c config.yml -d

# Проверка прав проекта
curl -H "PRIVATE-TOKEN: your-token" "https://gitlab.com/api/v4/projects/123"
```