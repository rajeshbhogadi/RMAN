# description: Script to perform RMAN Hot Full level0 backup to disk
# Version: 1.0
# Modified (MM/DD/YY)
# rbhogadi (04/06/20) first version of script
# Notes

if
[ "${1}" = "" ];
then
     echo
     echo
     echo SYNTAX ERROR - rman_hot_nocat_inclvl0_backup.sh  [parameter1]
     echo
     echo        example. rman_hot_nocat_inclvl0_backup.sh  ORACLE_SID
     echo
     exit 1
fi

export PATH=/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/oracle/bin;
export NLS_DATE_FORMAT="DD-MON-YYYY HH24:MI:SS";
export ORACLE_SID=${1};
export ORAENV_ASK=NO;
. /usr/local/bin/oraenv
export LOG_DIR=/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/logs;
export LOG_FILE=${LOG_DIR}/rman_full_${ORACLE_SID}_`date +%d-%b-%y-%H-%M-%S`.log;
export PATH=$PATH:$ORACLE_HOME/bin;
export DBTAG=FULLBACKUP`date +%d%b%Y`;
v_begin_time_sec=`date +%s`;

verify_dir () {
if [ ! -d "$LOG_DIR" ]; then
echo "Backup  directory doesn't exist on the host, pls check and create the directory..."
exit 1
else
echo "Backup directory exist..proceeding with backup"
fi
}

rman_hot_backup () {
$ORACLE_HOME/bin/rman target / nocatalog log ${LOG_FILE} <<eofi
list backup summary;
show all;
set echo on
run
    {
     allocate channel c1 device type disk format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/database_%U';
     allocate channel c2 device type disk format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/database_%U';
     allocate channel c3 device type disk format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/database_%U';
     allocate channel c4 device type disk format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/database_%U';
     allocate channel c5 device type disk format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/database_%U';
     allocate channel c6 device type disk format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/database_%U';
     BACKUP INCREMENTAL LEVEL 0 tag $DBTAG AS COMPRESSED BACKUPSET DATABASE plus archivelog;
         backup spfile tag $DBTAG format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/spfile_%U';
         backup current controlfile tag $DBTAG format '/opt/app/oracle/db_backups/${ORACLE_SID}/rman_backups/control_%U';
         release channel c1;
         release channel c2;
         release channel c3;
         release channel c4;
         release channel c5;
         release channel c6;
    }
eofi
}

verify_dir
rman_hot_backup
v_end_time_sec=`date +%s`;
v_total_execution_time=`expr ${v_end_time_sec} - ${v_begin_time_sec}`;
echo "RMAN Backup execution duration on `date +%d-%m-%Y` is $v_total_execution_time seconds" >>${LOG_FILE}
