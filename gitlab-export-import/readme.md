# useful bash
Useful bash-scripts and something like this

## Gitlab
### Gitlab - export plus list maker

* [start2.sh](start2.sh) -- запускает вереницу событий: на выходе список и сразу экспорт файлов
* [start.sh](start.sh) -- при наличии готового списка запускается экспорт
* [config-creation.sh](config-creation.sh) - обрабатывает config-template.yaml, дописывает в него репо и делает config.yaml 
* [config-template.yaml](config-template.yaml) - шаблон для gitlab-project-export.py (нужно указать URL и токен от Gitlab, а также директорию, где будут лежать файлы экспорта)
* [config.yaml](config.yaml) -- готовый конфиг, делается из шаблона config-template.yaml 
* [get-all-projects.sh](get-all-projects.sh) - скрипт для получения списка проектов по API (нужно указать URL и от Gitlab)
* [gitlab_path_with_namespace.txt](gitlab_path_with_namespace.txt) - текстовый файл с проектами