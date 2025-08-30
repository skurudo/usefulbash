# Environment Selection and Configuration Script

## Описание

Интерактивный bash-скрипт для выбора и переключения между различными средами разработки (DEV/PROD). Автоматически настраивает Yandex Cloud CLI, устанавливает переменные окружения и переходит в соответствующие директории Terraform.

## Возможности

- **Интерактивное меню**: Выбор среды через удобное меню
- **Автоматическая настройка Yandex Cloud**: Конфигурация папок и CLI
- **Управление переменными окружения**: Установка ACCESS_KEY и SECRET_KEY
- **Навигация по директориям**: Автоматический переход в нужные папки Terraform
- **Цветной вывод**: Различные цвета для разных сред (зеленый для DEV, красный для PROD)

## Требования

- Bash shell
- Установленный Yandex Cloud CLI (`yc`)
- Доступ к директориям `/opt/terraform/dev` и `/opt/terraform/prod`
- Git репозиторий в `/opt/terraform`

## Структура скрипта

### Цветовые схемы
- **DEV**: Зеленый цвет (`\e[32m`)
- **PROD**: Красный цвет (`\e[31m`)
- **Предупреждения**: Желтый цвет (`\e[33m`)
- **Обычный текст**: Белый цвет (`\e[97m`)

### Функции

#### `DEV()`
- Переходит в `/opt/terraform/dev`
- Обновляет git репозиторий
- Настраивает Yandex Cloud папку
- Устанавливает переменные окружения для DEV
- Запускает новую оболочку

#### `PROD()`
- Переходит в `/opt/terraform/prod`
- Обновляет git репозиторий
- Настраивает Yandex Cloud папку
- Устанавливает переменные окружения для PROD
- Запускает новую оболочку

#### `Not-sure()`
- Выводит сообщение о необходимости определиться
- Завершает выполнение скрипта

## Использование

### Запуск
```bash
./project-env-select-and-change.sh
```

### Интерактивное меню
```
Enter your choice and define environment:
1) DEV
2) PROD
3) Not-sure
4) Exit
```

## Конфигурация

### Перед использованием необходимо отредактировать:

1. **Folder ID для DEV**:
```bash
yc config set folder-id some-folder-id
```

2. **Folder ID для PROD**:
```bash
yc config set folder-id some-folder-id
```

3. **Переменные окружения**:
```bash
export ACCESS_KEY=ACCESS_KEY
export SECRET_KEY=SECRET_KEY
```

### Рекомендуемая структура директорий
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

## Примеры использования

### Выбор DEV среды
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

### Выбор PROD среды
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

## Безопасность

- Скрипт запускает новую оболочку с установленными переменными
- Переменные окружения доступны только в текущей сессии
- При выходе из оболочки переменные сбрасываются

## Автоматизация

### Добавление в .bashrc
```bash
# Добавить в ~/.bashrc для быстрого доступа
alias env-switch='/path/to/project-env-select-and-change.sh'
```

### Создание символической ссылки
```bash
sudo ln -s /path/to/project-env-select-and-change.sh /usr/local/bin/env-switch
```

## Устранение неполадок

### Ошибка "Permission denied"
```bash
chmod +x project-env-select-and-change.sh
```

### Ошибка "yc: command not found"
```bash
# Установить Yandex Cloud CLI
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

### Ошибка "No such file or directory"
```bash
# Создать необходимые директории
sudo mkdir -p /opt/terraform/{dev,prod}
sudo chown $USER:$USER /opt/terraform/{dev,prod}
```

## Расширение функциональности

### Добавление новых сред
```bash
# Добавить новую функцию
function STAGING {
    echo -e "You selected ${BLUE} STAGING ${ENDCOLOR}."
    cd /opt/terraform/staging
    # ... настройки для staging
}
```

### Добавление новых переменных
```bash
export REGION=ru-central1
export PROJECT_ID=your-project-id
```

## Лицензия

Скрипт распространяется под той же лицензией, что и основной проект.

## Поддержка

Для вопросов и предложений создавайте issue в репозитории проекта.
