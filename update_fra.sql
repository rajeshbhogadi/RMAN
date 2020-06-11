--This script sets up the FRA parameters and updates the control_file_record_keep_time settings
WHENEVER SQLERROR EXIT SQL.SQLCODE
create pfile='/home/oracle/scripts/inithrstg.ora' from spfile;
alter system set control_file_record_keep_time=180 scope=both;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 150G scope=both;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/opt/app/alesco_archive/rman_hrstg' scope=both;
alter system set log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST' scope=both;
