# Yandex.Connect Mass User Management Script

## Описание

Bash-скрипт для массового создания пользователей в Yandex.Connect через Directory API. Автоматизирует процесс добавления сотрудников из файла с использованием OAuth токена для аутентификации.

## Возможности

- **Массовое создание пользователей**: Обработка списка сотрудников из файла
- **API интеграция**: Использование официального Yandex.Connect Directory API
- **Гибкая настройка**: Настройка департаментов, должностей и паролей
- **Автоматическая обработка**: Пакетная обработка без ручного вмешательства
- **Логирование результатов**: Отслеживание успешных и неудачных операций
- **Настраиваемые атрибуты**: Полная настройка профиля пользователя

## Требования

- Bash shell
- curl для HTTP-запросов
- OAuth токен Yandex.Connect
- Файл со списком пользователей
- Доступ к интернету

## Конфигурация

### Основные параметры

```bash
# Путь к файлу со списком пользователей
employees='./usrlist'

# OAuth токен для аутентификации
TOKEN="token-here-and-there"
```

### Получение OAuth токена

1. **Создание приложения**:
   - Перейти на [https://oauth.yandex.ru/](https://oauth.yandex.ru/)
   - Создать новое приложение
   - Получить Client ID

2. **Получение токена**:
   - Перейти по ссылке: `https://oauth.yandex.ru/authorize?response_type=token&client_id=YOUR_CLIENT_ID`
   - Авторизоваться в Yandex
   - Скопировать access_token из URL

3. **Права приложения**:
   - `Directory API` - для управления пользователями
   - `Read user info` - для чтения информации
   - `Write user info` - для создания/изменения

## Формат файла пользователей

### Структура файла
```
email_lastname_firstname_middlename_password_position
```

### Примеры строк
```
petrova_Петрова_Авдотья_Федоровна_eeKrutoiparol23_Менеджер
ivanov_Иванов_Иван_Иванович_StrongPass123_Разработчик
sidorova_Сидорова_Мария_Петровна_SecurePass456_Аналитик
```

### Поля
- **email**: Логин пользователя (без домена)
- **lastname**: Фамилия
- **firstname**: Имя
- **middlename**: Отчество
- **password**: Пароль пользователя
- **position**: Должность

## Структура скрипта

### 1. Чтение файла пользователей
```bash
for i in $( cat $employees ); do
    value=($(echo $i | tr "_" " "))
```

### 2. Парсинг данных
```bash
email="${value[0]}"
lastname="${value[1]}"
firstname="${value[2]}"
middlename="${value[3]}"
password="${value[4]}"
position="${value[5]}"
```

### 3. Формирование API запроса
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

### 4. Обработка ответа
```bash
# Только HTTP ответы
| grep HTTP

# Полные ответы (закомментировано)
# curl -i -X POST ... (без grep)
```

### 5. Задержка между запросами
```bash
wait 2
```

## Использование

### Подготовка файла пользователей
```bash
# Создать файл usrlist
cat > usrlist << EOF
john_Джон_Джон_Джонович_Pass123_Developer
jane_Джейн_Джейн_Джейновна_Pass456_Manager
EOF
```

### Запуск скрипта
```bash
# Отредактировать TOKEN в скрипте
nano yandex-connect-mass-user-add.sh

# Запустить
./yandex-connect-mass-user-add.sh
```

### Проверка результатов
```bash
# Проверить HTTP ответы
./yandex-connect-mass-user-add.sh

# Для полных ответов раскомментировать строку
# curl -i -X POST ... (убрать | grep HTTP)
```

## API Endpoints

### Создание пользователя
```
POST https://api.directory.yandex.net/v6/users/
```

### Параметры запроса
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

### Заголовки
```
Content-Type: application/json
Authorization: OAuth YOUR_TOKEN
```

## Обработка ошибок

### HTTP коды ответов
- **200/201**: Пользователь успешно создан
- **400**: Ошибка в данных запроса
- **401**: Неверный токен
- **403**: Недостаточно прав
- **409**: Пользователь уже существует

### Типичные ошибки
```bash
# Неверный токен
HTTP/1.1 401 Unauthorized

# Недостаточно прав
HTTP/1.1 403 Forbidden

# Пользователь существует
HTTP/1.1 409 Conflict
```

## Мониторинг и логирование

### Добавление логирования
```bash
# Функция логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/yandex-connect.log
}

# Использование
log_message "Creating user: $email"
log_message "User $email created successfully"
```

### Проверка статуса
```bash
# Проверить последние операции
tail -f /var/log/yandex-connect.log

# Статистика по пользователям
grep "created successfully" /var/log/yandex-connect.log | wc -l
```

## Устранение неполадок

### Ошибка "curl: command not found"
```bash
# Установить curl
apt-get update && apt-get install curl -y
```

### Ошибка "Permission denied"
```bash
chmod +x yandex-connect-mass-user-add.sh
```

### Проблемы с OAuth токеном
```bash
# Проверить токен
curl -H "Authorization: OAuth $TOKEN" \
  "https://api.directory.yandex.net/v6/users/"

# Проверить права приложения
curl -H "Authorization: OAuth $TOKEN" \
  "https://api.directory.yandex.net/v6/me"
```

### Проблемы с API
```bash
# Проверить доступность API
curl -I "https://api.directory.yandex.net/v6/users/"

# Проверить rate limits
curl -H "Authorization: OAuth $TOKEN" \
  "https://api.directory.yandex.net/v6/users/" \
  -w "HTTP Code: %{http_code}\nTime: %{time_total}s\n"
```

## Расширение функциональности

### Добавление дополнительных полей
```bash
# Добавить поле department
department="${value[6]}"

# Обновить API запрос
"department_id": "'$department'",
```

### Добавление валидации
```bash
# Проверка обязательных полей
if [ -z "$email" ] || [ -z "$password" ]; then
    echo "Error: Missing required fields for user"
    continue
fi

# Проверка формата email
if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+$ ]]; then
    echo "Error: Invalid email format: $email"
    continue
fi
```

### Добавление обработки ошибок
```bash
# Проверка HTTP ответа
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

## Автоматизация

### Cron job для регулярного обновления
```bash
# Обновление пользователей каждый день в 9:00
0 9 * * * /path/to/yandex-connect-mass-user-add.sh

# Обновление каждые 6 часов
0 */6 * * * /path/to/yandex-connect-mass-user-add.sh
```

### Интеграция с HR системой
```bash
#!/bin/bash
# sync-hr-users.sh

# Экспорт из HR системы
hr_export > /tmp/hr_users.csv

# Конвертация в формат скрипта
awk -F',' '{
    print $1 "_" $2 "_" $3 "_" $4 "_" $5 "_" $6
}' /tmp/hr_users.csv > usrlist

# Запуск синхронизации
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

## Безопасность

### Защита токенов
```bash
# Использование переменных окружения
export YANDEX_TOKEN="$(cat /etc/yandex/token)"

# Использование конфигурационного файла
source /etc/yandex/connect.conf
```

### Ограничение доступа
```bash
# Ограничить доступ к скрипту
chmod 750 yandex-connect-mass-user-add.sh
chown root:yandex yandex-connect-mass-user-add.sh

# Ограничить доступ к файлу пользователей
chmod 640 usrlist
chown root:yandex usrlist
```

### Шифрование паролей
```bash
# Генерация случайных паролей
generate_password() {
    openssl rand -base64 12 | tr -d "=+/" | cut -c1-12
}

# Использование
password=$(generate_password)
```

## Производительность

### Оптимизация для больших списков
```bash
# Обработка по частям
split -l 100 usrlist usrlist_part_

for part in usrlist_part_*; do
    employees="$part"
    ./yandex-connect-mass-user-add.sh
    sleep 5  # Задержка между частями
done
```

### Параллельная обработка
```bash
# Обработка нескольких пользователей одновременно
process_user() {
    local user_data="$1"
    # ... обработка пользователя
}

export -f process_user
cat usrlist | parallel -j 5 process_user {}
```

## Интеграция с другими системами

### Active Directory синхронизация
```bash
# Экспорт из AD
ldapsearch -H ldap://dc.company.com -D "user@company.com" \
  -w "password" -b "DC=company,DC=com" \
  "(&(objectClass=user)(objectCategory=person))" \
  sAMAccountName sn givenName displayName | \
  awk '/^sAMAccountName:/ {email=$2} \
       /^sn:/ {lastname=$2} \
       /^givenName:/ {firstname=$2} \
       /^displayName:/ {print email "_" lastname "_" firstname "_" "_Pass123_User"}' > usrlist
```

### Google Workspace синхронизация
```bash
# Экспорт из Google Workspace
gcloud admin-sdk directory users list \
  --customer=my_customer \
  --format="table(primaryEmail,name.fullName)" | \
  awk 'NR>1 {split($2,names," "); print $1 "_" names[2] "_" names[1] "_" "_Pass123_User"}' > usrlist
```

### CSV импорт
```bash
# Конвертация CSV в формат скрипта
awk -F',' 'NR>1 {
    print $1 "_" $2 "_" $3 "_" $4 "_" $5 "_" $6
}' users.csv > usrlist
```

## Мониторинг и отчетность

### Создание отчетов
```bash
# Отчет по созданным пользователям
echo "=== Yandex.Connect User Sync Report ===" > sync_report.txt
echo "Date: $(date)" >> sync_report.txt
echo "Total users processed: $(wc -l < usrlist)" >> sync_report.txt
echo "Successfully created: $(grep "HTTP/1.1 201" /tmp/response | wc -l)" >> sync_report.txt
echo "Errors: $(grep "HTTP/1.1 [45]" /tmp/response | wc -l)" >> sync_report.txt
```

### Интеграция с системами мониторинга
```bash
# Zabbix
zabbix_sender -z zabbix-server -s "yandex-sync" -k "users.synced" -o "$(grep "201" /tmp/response | wc -l)"

# Prometheus
echo "yandex_users_synced_total $success_count" >> /tmp/metrics.prom
```

## Лицензия

Скрипт распространяется под той же лицензией, что и основной проект.

## Поддержка

Для вопросов и предложений создавайте issue в репозитории проекта.
