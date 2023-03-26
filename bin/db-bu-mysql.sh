#!/bin/sh

renice 20 $$ > /dev/null

SCRIPT=${0}
# echo "SCRIPT=${SCRIPT}"
n=${SCRIPT%.*}
# echo "n=${n}"
n=$(basename ${n})
# echo "n=${n}"
LOG_FILE="${n}.log"
# echo "LOG_FILE=${LOG_FILE}"
HEARTBEAT_FILE="heartbeat_${n}.json"
# echo "HEARTBEAT_FILE=${HEARTBEAT_FILE}"
# exit

# BACKUP_DIR='/var/backups/mysql'
BACKUP_DIR='/home/toomasm/backup'
DB_CONF='/etc/mysql/debian.cnf'

mkdir --parents ${BACKUP_DIR}
/bin/rm --force ${BACKUP_DIR}/${HEARTBEAT_FILE}
mysql_dbs="a b c"
# mysql_dbs=$(mysql --defaults-file=${DB_CONF} -e 'show databases' | sed -e '1d')

for db in ${mysql_dbs}
do
        if test "${db}" != "information_schema" && test "${db}" != "performance_schema"; then
                CURTIME=$(date +"%FT%H:%M:%S")
                # mysqldump --defaults-file=${DB_CONF} ${db} | gzip -c > ${BACKUP_DIR}/mysql_${db}.sql_${CURTIME}.gz;
                sleep 1
                echo "$? ${BACKUP_DIR}/mysql_${db}.sql_${CURTIME}.gz $(date +"%FT%H:%M:%S")" >> ${BACKUP_DIR}/${LOG_FILE}
                echo "{\"status\": \"$?\", \"db\": \"${db}\", "file": \"${BACKUP_DIR}/mysql_${db}.sql_${CURTIME}.gz\", \"date\": \"$(date +"%FT%H:%M:%S")\"}" >> ${BACKUP_DIR}/${HEARTBEAT_FILE}
        fi
done
