#!/bin/bash

# Set the API token and chat ID - обозначаем токен и id чата
API_TOKEN="token"
CHAT_ID="chat-id"

# Parse file with error - объявляем путь к файлу
FILE=/opt/oxidized/ox_node_failed.log

# Checking if file is empty or not - проверяем, пустой ли файл
if [ -s $FILE ]
then
     echo "File is not empty, do the JOB"

       # Read file, prepare messade and send to Telegram - читаем файл, готовим сообщение
        while IFS=, read -r col1 col2 col3
        do
            MESSAGE=("<b>ERROR DETECTED</b> while backup on device $col1 with IP: $col2 reason: <b>$col3</b>. Check <a href=\"http://oxidized.url\">Oxidized</a>!");
            echo $MESSAGE

        # Use the curl command to send the message - отправляем сообщение
        curl -s -X POST https://api.telegram.org/bot$API_TOKEN/sendMessage -d parse_mode="html" -d chat_id=$CHAT_ID -d text="$MESSAGE";

        done < $FILE
      
        # Clean file - очищаем файл, чтобы избежать повторной отправки
        >$FILE

else
     echo "File is empty, nothing to do"
     exit;
fi
