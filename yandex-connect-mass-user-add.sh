#!/bin/bash
#
# Yandex Connect mass user add
#
###############################################################
#
# path to users list - путь к списку пользователей
employees='./usrlist'
# line example from users list - пример строки файла 
# usrlist: email_lastname_firstname_middlename_password_position
# for example: petrova_Петрова_Авдотья_Федоровна_eeKrutoiparol23_Менеджер

# OAuth_Token
# link to material about token - ссылка на формирование отладочного токена
# https://tech.yandex.ru/oauth/doc/dg/tasks/get-oauth-token-docpage/
# link about our apps - список ваших приложений
# https://oauth.yandex.ru/
# get token from apps id - получить токен из ID приложения
# https://oauth.yandex.ru/verification_code#access_token=425843455894374389
TOKEN="token-here-and-there"

# read and trim user file - читаем и перебираем файл со списком пользователей
for i in $( cat $employees ); do
value=($(echo $i | tr "_" " "))

# make variables for api request from file - заводим переменные для запроса из файла
email="${value[0]}"
lastname="${value[1]}"
firstname="${value[2]}"
middlename="${value[3]}"
password="${value[4]}"
position="${value[5]}"

# Make user for good - создаем сотрудника ради добра
# department = 1 for default - департамент 1 умолчанию
#only http answers, not full - только http ответы, не полный лог
curl -i -X POST -H 'Content-type: application/json' -d '{"department_id": 1, "position": "'$position'", "password": "'$password'", "nickname": "'$email'", "name": {"first": "'$firstname'", "last": "'$lastname'", "middle": "'$middlename'"}}' -H "Authorization: OAuth $TOKEN" 'https://api.directory.yandex.net/v6/users/' | grep HTTP
#full answers - полные ответы
#curl -i -X POST -H 'Content-type: application/json' -d '{"department_id": 1, "position": "'$position'", "password": "'$password'", "nickname": "'$email'", "name": {"first": "'$firstname'", "last": "'$lastname'", "middle": "'$middlename'"}}' -H "Authorization: OAuth $TOKEN" 'https://api.directory.yandex.net/v6/users/' 
# wait for 2 sec - ждем пару секунд
wait 2
done
