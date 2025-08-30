# Скрипты управления пользователями

## Описание

Коллекция bash-скриптов для автоматизации создания пользователей с правами sudo и SSH-ключами. Включает три версии: базовую, интерактивную и параметризованную.

## Скрипты

### 1. useradd-sudo-key.sh (Базовая версия)
**Описание**: Простой скрипт для создания пользователя с правами sudo без пароля и SSH-ключом.
**Назначение**: Автоматизация создания пользователей с полными правами sudo и SSH-доступом.

**Особенности**:
- Создание пользователя с отключенным паролем
- Добавление в группу sudo
- Настройка SSH-ключей
- Конфигурация sudo без пароля

**Использование**:
```bash
# Отредактировать переменные USERNAME и PUBLIC_KEY
nano useradd-sudo-key.sh
# Запустить скрипт
./useradd-sudo-key.sh
```

### 2. useradd-sudo-key-i.sh (Интерактивная версия)
**Описание**: Интерактивная версия с запросами имени пользователя и публичного ключа во время выполнения.
**Назначение**: Интерактивное создание пользователей с запросом параметров в реальном времени.

**Особенности**:
- Интерактивные запросы
- Создание пользователя в реальном времени
- Немедленная настройка SSH-ключей

**Использование**:
```bash
./useradd-sudo-key-i.sh
```

### 3. useradd-sudo-key-p.sh (Параметризованная версия)
**Описание**: Версия с параметрами командной строки для автоматизации и скриптинга.
**Назначение**: Автоматизированное создание пользователей через параметры командной строки.

**Особенности**:
- Параметры командной строки
- Возможность пакетной обработки
- Неинтерактивное выполнение

**Использование**:
```bash
./useradd-sudo-key-p.sh username "ssh-rsa AAAA..."
```

## Требования

- Bash shell
- Права sudo
- Установленный пакет sudo
- SSH-ключи пользователя

## Процесс работы

### 1. Установка sudo
```bash
apt-get install sudo -y
```

### 2. Создание пользователя
```bash
sudo adduser --disabled-password --gecos "" $USERNAME
```

### 3. Добавление в группу sudo
```bash
sudo usermod -aG sudo $USERNAME
```

### 4. Настройка SSH-директории
```bash
sudo mkdir -p /home/$USERNAME/.ssh
sudo touch /home/$USERNAME/.ssh/authorized_keys
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME /home/$USERNAME/.ssh
```

### 5. Добавление публичного ключа
```bash
sudo sh -c "echo $PUBLIC_KEY > /home/$USERNAME/.ssh/authorized_keys"
```

### 6. Настройка sudo без пароля
```bash
sudo sh -c "echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USERNAME-user"
```

## Безопасность

### SSH-ключи
- Используются только публичные ключи
- Приватные ключи остаются у пользователя
- Автоматическая настройка прав доступа

### Sudo права
- Пользователь получает полные права sudo
- Пароль не требуется для sudo команд
- Настройки изолированы в отдельном файле

### Права доступа
- SSH-директория: 700 (только владелец)
- authorized_keys: 600 (только владелец)
- Правильное владение файлами

## Примеры использования

### Создание пользователя developer
```bash
# Отредактировать скрипт
USERNAME="developer"
PUBLIC_KEY="ssh-rsa AAAA... developer@workstation"

# Запустить
./useradd-sudo-key.sh
```

### Пакетное создание пользователей
```bash
# Создать файл с пользователями
cat > users.txt << EOF
john:ssh-rsa AAAA... john@laptop
jane:ssh-rsa AAAA... jane@desktop
EOF

# Обработать каждого пользователя
while IFS=: read -r username key; do
    USERNAME="$username" PUBLIC_KEY="$key" ./useradd-sudo-key.sh
done < users.txt
```

## Мониторинг и логирование

### Проверка созданных пользователей
```bash
# Список пользователей
cat /etc/passwd | grep -E ":/home/"

# Проверка sudo прав
sudo -l -U username

# Проверка SSH-ключей
cat /home/username/.ssh/authorized_keys
```

### Логи sudo
```bash
# Просмотр логов sudo
sudo tail -f /var/log/auth.log | grep sudo
```

## Устранение неполадок

### Ошибка "Permission denied"
```bash
chmod +x useradd-sudo-key.sh
```

### Ошибка "sudo: command not found"
```bash
# Установить sudo
apt-get update && apt-get install sudo -y
```

### Проблемы с SSH-подключением
```bash
# Проверить права доступа
ls -la /home/username/.ssh/
# Проверить содержимое authorized_keys
cat /home/username/.ssh/authorized_keys
```

### Проблемы с sudo
```bash
# Проверить файл sudoers
sudo cat /etc/sudoers.d/username-user
# Проверить синтаксис
sudo visudo -c
```

## Автоматизация

### Добавление в CI/CD
```bash
# Пример для GitLab CI
create_user:
  script:
    - USERNAME="$CI_COMMIT_AUTHOR" 
    - PUBLIC_KEY="$SSH_PUBLIC_KEY"
    - ./useradd-sudo-key.sh
```

### Настройка cron
```bash
# Создание пользователей по расписанию
0 9 * * 1 /path/to/useradd-sudo-key.sh username "key"
```

## Расширение функциональности

### Добавление дополнительных групп
```bash
# Добавить в группу docker
sudo usermod -aG docker $USERNAME
```

### Настройка дополнительных SSH-опций
```bash
# Создать sshd_config для пользователя
sudo tee /home/$USERNAME/.ssh/config << EOF
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
```

### Настройка umask
```bash
# Установить umask для пользователя
echo "umask 022" >> /home/$USERNAME/.bashrc
```

## Резервное копирование

### Экспорт пользователей
```bash
# Создать список пользователей с ключами
for user in $(ls /home/); do
    if [ -f "/home/$user/.ssh/authorized_keys" ]; then
        echo "$user:$(cat /home/$user/.ssh/authorized_keys)"
    fi
done > users_backup.txt
```

### Восстановление пользователей
```bash
# Восстановить из резервной копии
while IFS=: read -r username key; do
    USERNAME="$username" PUBLIC_KEY="$key" ./useradd-sudo-key.sh
done < users_backup.txt
```

## Лицензия

Скрипты распространяются под той же лицензией, что и основной проект.

## Поддержка

Для вопросов и предложений создавайте issue в репозитории проекта.
