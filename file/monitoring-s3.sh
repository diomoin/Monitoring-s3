#!/bin/bash
  
set -a

ACCESS_KEY_ID=${ACCESS_KEY_ID:?Please enter ACCESS_KEY_ID}

SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY:?Please enter SECRET_ACCESS_KEY}

HOST_BUCKET=${HOST_BUCKET:?Please enter HOST_BUCKET}

NAME_BUCKET=${NAME_BUCKET:?Please enter NAME_BUCKET}

CHAT_ID=${CHAT_ID:?Please enter CHAT_ID}

BOT_TOKEN=${BOT_TOKEN:?Please enter BOT_TOKEN}

DATEFILTER=$(date '+%Y-%m-%d')

PERIOD=6h

set +a


function check_backup() {

    echo 'start function'
    echo 'path is' $1

    for path in $(s3cmd ls $1 --access_key=$ACCESS_KEY_ID --secret_key=$SECRET_ACCESS_KEY --host-bucket=$HOST_BUCKET | awk '{print $2}')
    do
        if $(echo -n s3cmd ls $path --access_key=$ACCESS_KEY_ID --secret_key=$SECRET_ACCESS_KEY --host-bucket=$HOST_BUCKET); then
            results="$(s3cmd ls $path --access_key=$ACCESS_KEY_ID --secret_key=$SECRET_ACCESS_KEY --host-bucket=$HOST_BUCKET | grep $DATEFILTER)"
            name_path=$path
            last_backup="$(s3cmd ls $path --access_key=$ACCESS_KEY_ID --secret_key=$SECRET_ACCESS_KEY --host-bucket=$HOST_BUCKET | tail -n 1 | awk '{print $1}')"
            check_backup $path

        else
            echo 'results is' "$results"
            return "$results"
        fi
        if [[ ${results} ]]; then
            echo 'resuls is' $results
            echo 'Backup done success!' 
        else
            echo 'results is' $results
            echo 'Fail Backups' $name_path \r\n 'Last backups: ' $last_backup 
            curl -X POST -H "Content-type: application/json" --data "{\"chat_id\": \"$CHAT_ID\", \"text\": \"FAIL! Backup $name_path is fail!\r\n Last backups: $last_backup\"}" https://api.telegram.org/bot$BOT_TOKEN/sendMessage
        fi
    done
}

while true
do

    check_backup $NAME_BUCKET
    sleep ${PERIOD}

done
