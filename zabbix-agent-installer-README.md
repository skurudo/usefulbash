# YASZAIT - Zabbix Agent Installer

## Описание

**YASZAIT** (Yet Another Simple Zabbix Agent Installer Tool) - интерактивный bash-скрипт для автоматической установки и настройки Zabbix агента на системах Debian/Ubuntu. Предоставляет простой способ развертывания мониторинга без сложной конфигурации.

## Возможности

- **Автоматическая установка**: Установка Zabbix агента через apt
- **Интерактивная настройка**: Запрос параметров во время выполнения
- **Автоматическая конфигурация**: Генерация конфигурационного файла
- **Проверка статуса**: Верификация работы сервиса
- **Информация о системе**: Отображение IP-адресов сервера
- **Гибкая настройка**: Возможность изменения порта и других параметров

## Требования

- Debian/Ubuntu система
- Права sudo или root
- Доступ к интернету для установки пакетов
- Bash shell

## Структура скрипта

### 1. Ввод параметров
```bash
# Имя сервера
echo -n "Enter this server name: "
read SRV_HOSTNAME

# Zabbix сервер
echo -n "Enter Zabbix Server (FQDN or IP): "
read ZABBIX_SERVER

# Порт прослушивания
echo -n "Listening port (10050): "
read LISTEN_PORT
```

### 2. Валидация и значения по умолчанию
```bash
# Использование hostname если имя не указано
if [ -z "$SRV_HOSTNAME" ]; then
    SRV_HOSTNAME=($(hostname -f))
fi

# Повторный запрос Zabbix сервера если не указан
if [ -z "$ZABBIX_SERVER" ]; then
    echo -n "=> Please enter address of your Zabbix server... [example.org or IP]: "
    read -r ZABBIX_SERVER
fi

# Порт по умолчанию 10050
if [ -z "$LISTEN_PORT" ]; then
    LISTEN_PORT=10050
fi
```

### 3. Установка и настройка
```bash
# Установка Zabbix агента
apt-get install zabbix-agent

# Генерация конфигурации
cat > /etc/zabbix/zabbix_agentd.conf << EOF
# simple core config file
Server=$ZABBIX_SERVER
ServerActive=$ZABBIX_SERVER
ListenPort=$LISTEN_PORT
Hostname=$SRV_HOSTNAME
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix-agent/zabbix_agentd.log
LogFileSize=0
EOF
```

### 4. Запуск и проверка
```bash
# Перезапуск сервиса
service zabbix-agent restart

# Проверка статуса
service zabbix-agent status

# Отображение IP-адресов
ip addr show | grep "inet "
```

## Использование

### Базовый запуск
```bash
sudo ./zabbix-add-agent-on-debian.sh
```

### Запуск с правами root
```bash
sudo su -
./zabbix-add-agent-on-debian.sh
```

### Интерактивный ввод
```
Enter this server name: [Enter для использования hostname]
Enter Zabbix Server (FQDN or IP): zabbix.company.com
Listening port (10050): [Enter для порта по умолчанию]
```

## Конфигурация

### Основные параметры

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `Server` | Zabbix сервер для пассивных проверок | Вводится пользователем |
| `ServerActive` | Zabbix сервер для активных проверок | Вводится пользователем |
| `ListenPort` | Порт прослушивания | 10050 |
| `Hostname` | Имя хоста в Zabbix | hostname -f |
| `PidFile` | Файл PID | /var/run/zabbix/zabbix_agentd.pid |
| `LogFile` | Файл логов | /var/log/zabbix-agent/zabbix_agentd.log |
| `LogFileSize` | Размер лог-файла | 0 (без ограничений) |

### Дополнительные настройки

```bash
# Добавить в конфигурацию
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Дополнительные параметры
Timeout=30
EnablePersistentBuffer=1
BufferSize=100
EOF
```

## Примеры использования

### Установка на веб-сервер
```bash
$ ./zabbix-add-agent-on-debian.sh
Enter this server name: web-server-01
Enter Zabbix Server (FQDN or IP): zabbix.internal.company.com
Listening port (10050): 
Zabbix agent simple installation
Reading package lists... Done
...
Zabbix agent installed successfully
```

### Установка на базе данных сервер
```bash
$ ./zabbix-add-agent-on-debian.sh
Enter this server name: db-server-prod
Enter Zabbix Server (FQDN or IP): 192.168.1.100
Listening port (10050): 10051
...
```

## Мониторинг и проверка

### Проверка статуса сервиса
```bash
# Статус Zabbix агента
systemctl status zabbix-agent

# Проверка процессов
ps aux | grep zabbix_agentd

# Проверка портов
netstat -tlnp | grep :10050
```

### Проверка логов
```bash
# Просмотр логов
tail -f /var/log/zabbix-agent/zabbix_agentd.log

# Поиск ошибок
grep -i error /var/log/zabbix-agent/zabbix_agentd.log

# Поиск предупреждений
grep -i warning /var/log/zabbix-agent/zabbix_agentd.log
```

### Тестирование подключения
```bash
# Тест от Zabbix сервера
zabbix_get -s localhost -p 10050 -k agent.ping

# Тест локально
zabbix_agentd -t agent.ping
```

## Устранение неполадок

### Ошибка "Permission denied"
```bash
chmod +x zabbix-add-agent-on-debian.sh
```

### Ошибка "apt-get: command not found"
```bash
# Обновить PATH
export PATH=$PATH:/usr/bin:/usr/sbin
```

### Проблемы с установкой пакета
```bash
# Обновить списки пакетов
apt-get update

# Проверить доступность пакета
apt-cache search zabbix-agent

# Установить вручную
apt-get install zabbix-agent -y
```

### Проблемы с конфигурацией
```bash
# Проверить синтаксис конфигурации
zabbix_agentd -t config_file

# Проверить права доступа
ls -la /etc/zabbix/zabbix_agentd.conf

# Пересоздать конфигурацию
./zabbix-add-agent-on-debian.sh
```

### Проблемы с сервисом
```bash
# Перезапустить сервис
systemctl restart zabbix-agent

# Проверить зависимости
systemctl list-dependencies zabbix-agent

# Проверить логи systemd
journalctl -u zabbix-agent -f
```

## Автоматизация

### Скрипт для массовой установки
```bash
#!/bin/bash
# install-zabbix-agents.sh

SERVERS=("server1" "server2" "server3")
ZABBIX_SERVER="zabbix.company.com"

for server in "${SERVERS[@]}"; do
    ssh $server "wget -O - https://raw.githubusercontent.com/user/repo/main/zabbix-add-agent-on-debian.sh | bash -s -- $ZABBIX_SERVER"
done
```

### Ansible playbook
```yaml
---
- name: Install Zabbix Agent
  hosts: all
  become: yes
  tasks:
    - name: Download installer script
      get_url:
        url: "https://raw.githubusercontent.com/user/repo/main/zabbix-add-agent-on-debian.sh"
        dest: "/tmp/zabbix-add-agent-on-debian.sh"
        mode: '0755'
    
    - name: Run installer
      command: "/tmp/zabbix-add-agent-on-debian.sh"
      args:
        stdin: "{{ item }}"
      loop:
        - "{{ ansible_hostname }}"
        - "{{ zabbix_server }}"
        - "10050"
```

### Terraform provisioner
```hcl
resource "null_resource" "zabbix_agent" {
  provisioner "remote-exec" {
    inline = [
      "wget -O - https://raw.githubusercontent.com/user/repo/main/zabbix-add-agent-on-debian.sh | bash -s -- ${var.zabbix_server}"
    ]
  }
}
```

## Расширение функциональности

### Добавление пользовательских ключей
```bash
# Добавить в конфигурацию
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Пользовательские ключи
UserParameter=custom.key,/path/to/script.sh
UserParameter=system.uptime,uptime | awk '{print \$3}'
EOF
```

### Настройка шифрования
```bash
# Добавить TLS настройки
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# TLS настройки
TLSConnect=cert
TLSCAFile=/etc/zabbix/certs/ca.crt
TLSCertFile=/etc/zabbix/certs/agent.crt
TLSKeyFile=/etc/zabbix/certs/agent.key
EOF
```

### Настройка прокси
```bash
# Добавить настройки прокси
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Прокси настройки
ProxyMode=1
Proxy=proxy.company.com:10051
EOF
```

## Безопасность

### Ограничение доступа
```bash
# Ограничить доступ к конфигурации
chmod 640 /etc/zabbix/zabbix_agentd.conf
chown zabbix:zabbix /etc/zabbix/zabbix_agentd.conf

# Ограничить доступ к скрипту
chmod 750 zabbix-add-agent-on-debian.sh
chown root:root zabbix-add-agent-on-debian.sh
```

### Firewall настройки
```bash
# Открыть только нужный порт
ufw allow from $ZABBIX_SERVER to any port $LISTEN_PORT

# Или для iptables
iptables -A INPUT -s $ZABBIX_SERVER -p tcp --dport $LISTEN_PORT -j ACCEPT
```

## Производительность

### Оптимизация конфигурации
```bash
# Добавить настройки производительности
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Настройки производительности
StartAgents=3
MaxLinesPerSecond=100
BufferSize=100
EnablePersistentBuffer=1
EOF
```

### Мониторинг ресурсов
```bash
# Добавить мониторинг самого агента
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Мониторинг агента
UserParameter=zabbix.agent.processes,ps aux | grep zabbix_agentd | wc -l
UserParameter=zabbix.agent.memory,ps aux | grep zabbix_agentd | awk '{sum+=\$6} END {print sum}'
EOF
```

## Интеграция

### Создание хоста в Zabbix
```bash
# API запрос для создания хоста
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ZABBIX_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
      "host": "'$SRV_HOSTNAME'",
      "interfaces": [{
        "type": 1,
        "main": 1,
        "useip": 1,
        "ip": "'$(hostname -I | awk '{print $1}')'",
        "dns": "",
        "port": "'$LISTEN_PORT'"
      }],
      "groups": [{"groupid": "1"}],
      "templates": [{"templateid": "10001"}]
    },
    "id": 1
  }' \
  "http://$ZABBIX_SERVER/api_jsonrpc.php"
```

### Автоматическое обнаружение
```bash
# Настройка auto-registration
cat >> /etc/zabbix/zabbix_agentd.conf << EOF
# Auto-registration
ServerActive=$ZABBIX_SERVER
HostMetadata=Linux server
EOF
```

## Лицензия

Скрипт распространяется под той же лицензией, что и основной проект.

## Поддержка

Для вопросов и предложений создавайте issue в репозитории проекта.
