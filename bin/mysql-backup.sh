#!/bin/sh
 
renice 20 $$ > /dev/null
 
# Script to be executed is from ${DIR} ... go there!
# CWD=$(pwd)
# DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# cd ${DIR}

BACKUP_DIR='/srv/www/backup'
# TODO: remove my local test
BACKUP_DIR='/home/toomasm/backup'
DB_CONF='/etc/mysql/debian.cnf'
# Name of subdirectory (under BACKUP_DIR/) where to keep backup, YYYY/MM/DD
SUB_DIR=$(/bin/date '+%Y/%m/%d')
BACKUP_SUBDIR=${BACKUP_DIR}/${SUB_DIR}
# Keep backups up to days, remove older
KEEP_DAYS=30

# Prepare ${LOG} and ${LOCK}
# Please note, that they depend of command ${0}
PID=$$
filename=$(basename -- "${0}")
extension="${filename##*.}"
filename="${filename%.*}"
LOG_FILE=${BACKUP_DIR}/${filename}.log
LOCK_FILE=${BACKUP_DIR}/${filename}.lock

echo -e "$(date +"%Y-%m-%dT%H:%M:%S%Z")\t${PID}\t[INFO] Start of ${0}" | tee -a ${LOG_FILE}

# Dealing with ${LOCK}
if [ -f ${LOCK_FILE} ]; then
   echo -e "$(date +"%Y-%m-%dT%H:%M:%S%Z")\t${PID}\t[WARN] Lock file ${LOCK_FILE} exists! PID = $(cat ${LOCK_FILE}) -- Exiting!" | \
      tee -a ${LOG_FILE}
   exit 1
else
   # Create it
   echo -e "$(date +"%Y-%m-%dT%H:%M:%S%Z")\t${PID}\t[INFO] Create lock file ${LOCK_FILE}" | \
      tee ${LOCK_FILE}
fi

mkdir --parents ${BACKUP_SUBDIR}
# TODO: I have to have at least read permissions
mysql_dbs=`mysql --defaults-file=${DB_CONF} \
  --execute 'show databases' | \
  sed --expression '1d'`
 
for db in ${mysql_dbs}
do
  if test "${db}" != "information_schema" && \
     test "${db}" != "performance_schema"; then
       mysqldump --defaults-file=${DB_CONF} ${db} | \
       gzip --to-stdout > \
       ${BACKUP_SUBDIR}/mysql_${db}_$(date +"%Y-%m-%dT%H:%M:%S%Z").sql.gz;
       echo -e "$(date +"%Y-%m-%dT%H:%M:%S%Z")\t$?\t[INFO] ${db}" | tee -a ${LOG_FILE}
  fi
done

# Remove backups older than days
find ${BACKUP_DIR} -type f -mtime +${KEEP_DAYS} -name '*.sql.gz' -exec /bin/ls -al {} \; | tee -a ${LOG_FILE}
# find ${BACKUP_DIR} -type f -mtime +${KEEP_DAYS} -name '*.sql.gz' -exec /bin/rm {} \;

# Remove empty directories under ${BACKUP_DIR}
find ${BACKUP_DIR} -type d -empty -print | tee -a ${LOG_FILE}
find ${BACKUP_DIR} -type d -empty -delete

# Remove ${LOCK}
/bin/rm --force ${LOCK}

# The End
echo -e "$(date +"%Y-%m-%dT%H:%M:%S%Z")\t${PID}\t[INFO] End of ${0}" | tee -a ${LOG_FILE}

# Just in case, go home!
# cd ${CWD}
