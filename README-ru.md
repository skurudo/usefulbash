# useful bash
Useful bash-scripts and something like this

**🇷🇺 Русская версия** | **🇺🇸 English version**: [README-en.md](README-en.md)

## OS
### Initial softwate install and change 
* **Environment Selection** - [project-env-select-and-change.sh](project-env-select-and-change.sh) | [README](project-env-select-and-change-README.md) | [English](project-env-select-and-change-README-en.md)
  - Интерактивный выбор и переключение между средами разработки (DEV/PROD). Автоматически настраивает Yandex Cloud CLI и переменные окружения.

### Add user with passwordless sudo and public key
* **User Management Scripts** - [useradd-sudo-key.sh](useradd-sudo-key.sh), [useradd-sudo-key-i.sh](useradd-sudo-key-i.sh), [useradd-sudo-key-p.sh](useradd-sudo-key-p.sh) | [README](user-management-README.md) | [English](user-management-README-en.md)
  - Автоматизация создания пользователей с правами sudo и SSH-ключами. Три версии: базовая, интерактивная и параметризованная.

## Gitlab
### Gitlab - export plus list maker (new version)
**Advanced GitLab Export Tool** - [scripts](/gitlab-export-import-v2/readme.md) | [English](/gitlab-export-import-v2/readme-en.md)
- Продвинутый инструмент экспорта проектов GitLab с автоматическим обнаружением, YAML конфигурацией и детальным логированием.

### Gitlab - export plus list maker (old version)
**Legacy GitLab Export Tool** - [scripts](/gitlab-export-import/readme.md) | [English](/gitlab-export-import/readme-en.md)
- Базовая версия инструмента экспорта GitLab с простой функциональностью для базовых потребностей.

## Oxidized
### Oxidized - send notification
**Oxidized Backup Monitor** - [scripts](/oxidized-check-file-and-send-notify.sh) | [README](oxidized-monitoring-README.md) | [English](oxidized-monitoring-README-en.md)
- Мониторинг сбоев резервного копирования Oxidized с отправкой Telegram уведомлений и автоматической очисткой лог-файлов.

## Zabbix
### YASZAIT - Zabbix-Agent Installer
**Zabbix Agent Installer** - [zabbix-add-agent-on-debian.sh](https://github.com/skurudo/usefulbash/blob/main/zabbix-add-agent-on-debian.sh) | [README](zabbix-agent-installer-README.md) | [English](zabbix-agent-installer-README-en.md)
- Автоматическая установка и настройка Zabbix агента с интерактивной конфигурацией и проверкой статуса сервиса.

## Yandex API
### Yandex.Connect - AddUsers
**Yandex.Connect User Manager** - [yandex-connect-mass-user-add.sh](https://github.com/skurudo/usefulbash/blob/main/yandex-connect-mass-user-add.sh) | [README](yandex-connect-README.md) | [English](yandex-connect-README-en.md)
- Массовое создание пользователей в Yandex.Connect через Directory API с OAuth аутентификацией и пакетной обработкой.
