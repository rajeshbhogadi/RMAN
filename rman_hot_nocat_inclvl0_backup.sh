#!/bin/bash
# description: Script to perform RMAN Hot Full level0 backup to disk
# Version: 1.0
# Modified (MM/DD/YY)
# rbhogadi (04/06/20) first version of script
# Notes

if [ "$#" -ne 1 ]; then
     echo ""
     echo ""
     echo SYNTAX ERROR - $0 [ORACLE_SID]
     echo ""
     echo        example. $0 CDBCHSPRD
     echo ""
     exit 1
fi

export PATH=/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/oracle/bin;
export NLS_DATE_FORMAT="DD-MON-YYYY HH24:MI:SS";
export ORACLE_SID=${1};
export ORAENV_ASK=NO;
. /usr/local/bin/oraenv

export LOG_DIR=${HOME}/logs;
export LOG_FILE=${LOG_DIR}/rman_full_${ORACLE_SID}_`date +%d-%b-%y-%H-%M-%S`.log;
export PATH=$PATH:$ORACLE_HOME/bin;
export DBTAG=FULLBACKUP`date +%d%b%Y`;
v_begin_time_sec=`date +%s`;
export MAIL_TO='itds-ops-corporate@westernsydney.edu.au';

verify_log_dir () {
if [ ! -d "$LOG_DIR" ]; then
echo "Backup log directory doesn't exist on the host, proceeding to create the directory and execute backup..."
mkdir -p ${HOME}/logs
export LOG_DIR=${HOME}/logs
fi
}

rman_hot_backup_use_db_recovery_file_dest () {
$ORACLE_HOME/bin/rman target / nocatalog log ${LOG_FILE} <<eofi
list backup summary;
show all;
set echo on
run
    {
     allocate channel c1 device type disk; 
     allocate channel c2 device type disk;
     allocate channel c3 device type disk;
     allocate channel c4 device type disk;
     BACKUP INCREMENTAL LEVEL 0 tag $DBTAG AS COMPRESSED BACKUPSET DATABASE plus archivelog;
         backup spfile tag $DBTAG; 
         backup current controlfile tag $DBTAG;
         release channel c1;
         release channel c2;
         release channel c3;
         release channel c4;
    }
eofi
}

notify_errors () {
if  grep -q ORA- ${LOG_FILE}
then
mailx -s "RMAN Backup errors for database ${ORACLE_SID} on Host `hostname -f`, Pls verify the log file" ${MAIL_TO} < ${LOG_FILE}
fi
}

verify_log_dir
rman_hot_backup_use_db_recovery_file_dest
notify_errors
v_end_time_sec=`date +%s`;
v_total_exec_time=`expr ${v_end_time_sec} - ${v_begin_time_sec}`;
echo "RMAN Backup execution duration on `date +%d-%m-%Y` is ${v_total_exec_time} seconds" >>${LOG_FILE}
