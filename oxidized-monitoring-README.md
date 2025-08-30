# Oxidized Backup Monitoring Script

## Описание

Bash-скрипт для мониторинга сбоев резервного копирования Oxidized и отправки уведомлений в Telegram. Автоматически проверяет лог-файл с ошибками, парсит информацию и отправляет форматированные уведомления.

## Возможности

- **Мониторинг лог-файлов**: Автоматическая проверка файла с ошибками
- **Парсинг ошибок**: Извлечение информации об устройствах и причинах сбоев
- **Telegram уведомления**: Отправка HTML-форматированных сообщений
- **Автоматическая очистка**: Очистка лог-файла после обработки
- **Детальная информация**: Включение ссылок на веб-интерфейс Oxidized

## Требования

- Bash shell
- curl для HTTP-запросов
- Telegram Bot API токен
- ID чата для уведомлений
- Доступ к лог-файлу Oxidized

## Конфигурация

### Основные параметры

```bash
# Токен Telegram бота
API_TOKEN="token"

# ID чата для уведомлений
CHAT_ID="chat-id"

# Путь к файлу с ошибками
FILE=/opt/oxidized/ox_node_failed.log
```

### Получение Telegram Bot Token

1. Создать бота через @BotFather
2. Получить токен
3. Добавить бота в нужный чат
4. Получить ID чата

### Получение Chat ID

```bash
# Отправить сообщение боту и проверить логи
curl -s "https://api.telegram.org/bot$API_TOKEN/getUpdates"
```

## Структура скрипта

### 1. Проверка файла
```bash
if [ -s $FILE ]
```
- Проверяет, не пустой ли файл
- `-s` возвращает true, если файл существует и не пустой

### 2. Парсинг лог-файла
```bash
while IFS=, read -r col1 col2 col3
```
- Читает файл построчно
- Разделяет строки по запятой
- `col1` - имя устройства
- `col2` - IP-адрес
- `col3` - причина ошибки

### 3. Формирование сообщения
```bash
MESSAGE=("<b>ERROR DETECTED</b> while backup on device $col1 with IP: $col2 reason: <b>$col3</b>. Check <a href=\"http://oxidized.url\">Oxidized</a>!");
```
- HTML-форматирование для Telegram
- Включение ссылки на веб-интерфейс
- Выделение ключевой информации

### 4. Отправка уведомления
```bash
curl -s -X POST https://api.telegram.org/bot$API_TOKEN/sendMessage \
  -d parse_mode="html" \
  -d chat_id=$CHAT_ID \
  -d text="$MESSAGE"
```

### 5. Очистка файла
```bash
>$FILE
```
- Очищает файл после обработки
- Предотвращает повторную отправку

## Формат лог-файла

### Ожидаемая структура
```
device_name,192.168.1.1,Connection timeout
router_01,10.0.0.1,Authentication failed
switch_core,172.16.0.1,SSH connection refused
```

### Поля
- **col1**: Имя устройства или хоста
- **col2**: IP-адрес устройства
- **col3**: Описание ошибки или причины сбоя

## Использование

### Базовый запуск
```bash
./oxidized-check-file-and-send-notify.sh
```

### Запуск с параметрами
```bash
# Установить переменные окружения
export API_TOKEN="your-bot-token"
export CHAT_ID="your-chat-id"
export FILE="/path/to/error.log"

# Запустить скрипт
./oxidized-check-file-and-send-notify.sh
```

### Автоматизация через cron
```bash
# Проверка каждые 5 минут
*/5 * * * * /path/to/oxidized-check-file-and-send-notify.sh

# Проверка каждый час
0 * * * * /path/to/oxidized-check-file-and-send-notify.sh
```

## Примеры уведомлений

### Успешное уведомление
```
ERROR DETECTED while backup on device router_main with IP: 192.168.1.1 reason: Connection timeout. Check Oxidized!
```

### Формат в Telegram
- **Жирный текст** для заголовка и причины
- **Ссылка** на веб-интерфейс Oxidized
- Структурированная информация об ошибке

## Мониторинг и логирование

### Проверка статуса
```bash
# Проверить последние уведомления
tail -f /var/log/oxidized-notifications.log

# Проверить статус бота
curl -s "https://api.telegram.org/bot$API_TOKEN/getMe"
```

### Логирование ошибок
```bash
# Добавить логирование в скрипт
echo "$(date): Processing error file" >> /var/log/oxidized-monitor.log
echo "$(date): Sent notification for $col1" >> /var/log/oxidized-monitor.log
```

## Устранение неполадок

### Ошибка "curl: command not found"
```bash
# Установить curl
apt-get update && apt-get install curl -y
```

### Ошибка "Permission denied"
```bash
# Сделать скрипт исполняемым
chmod +x oxidized-check-file-and-send-notify.sh
```

### Проблемы с Telegram API
```bash
# Проверить токен
curl -s "https://api.telegram.org/bot$API_TOKEN/getMe"

# Проверить права бота
curl -s "https://api.telegram.org/bot$API_TOKEN/getChatMember?chat_id=$CHAT_ID&user_id=$BOT_ID"
```

### Проблемы с доступом к файлу
```bash
# Проверить права доступа
ls -la /opt/oxidized/ox_node_failed.log

# Проверить владельца
stat /opt/oxidized/ox_node_failed.log
```

## Расширение функциональности

### Добавление логирования
```bash
# Функция логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/oxidized-monitor.log
}

# Использование
log_message "Starting error check"
log_message "Found error for device $col1"
```

### Добавление уведомлений в другие каналы
```bash
# Slack уведомления
send_slack_notification() {
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$1\"}" \
        $SLACK_WEBHOOK_URL
}

# Email уведомления
send_email_notification() {
    echo "$1" | mail -s "Oxidized Backup Error" admin@company.com
}
```

### Добавление фильтрации ошибок
```bash
# Фильтр по типу ошибок
case $col3 in
    "Connection timeout")
        PRIORITY="HIGH"
        ;;
    "Authentication failed")
        PRIORITY="MEDIUM"
        ;;
    *)
        PRIORITY="LOW"
        ;;
esac
```

## Интеграция с системами мониторинга

### Zabbix
```bash
# Отправка в Zabbix
zabbix_sender -z zabbix-server -s "oxidized-monitor" -k "backup.errors" -o "1"
```

### Prometheus
```bash
# Увеличение счетчика ошибок
echo "oxidized_backup_errors_total{device=\"$col1\"} 1" >> /tmp/metrics.prom
```

### Grafana
```bash
# Логирование метрик
echo "$(date),$col1,$col2,$col3" >> /var/log/oxidized-metrics.csv
```

## Безопасность

### Защита токенов
```bash
# Использование переменных окружения
export API_TOKEN="$(cat /etc/oxidized/telegram-token)"

# Использование конфигурационного файла
source /etc/oxidized/telegram.conf
```

### Ограничение доступа
```bash
# Ограничить доступ к скрипту
chmod 750 oxidized-check-file-and-send-notify.sh
chown root:oxidized oxidized-check-file-and-send-notify.sh
```

## Производительность

### Оптимизация для больших файлов
```bash
# Обработка по частям
head -100 $FILE | while IFS=, read -r col1 col2 col3; do
    # обработка
done
```

### Кэширование результатов
```bash
# Проверка изменений файла
if [ "$(stat -c %Y $FILE)" -gt "$LAST_CHECK" ]; then
    # обработка
    LAST_CHECK=$(stat -c %Y $FILE)
fi
```

## Лицензия

Скрипт распространяется под той же лицензией, что и основной проект.

## Поддержка

Для вопросов и предложений создавайте issue в репозитории проекта.
