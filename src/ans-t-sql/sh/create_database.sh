#!/bin/sh
export SQLCMDPASSWORD="powerdb@@@51"
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -v varFileSize="100MB" varOriginalFileName="/var/opt/mssql/data/datacloud_oryginaltemp.ndf" varANSFileName="/var/opt/mssql/data/datacloud_anstemp.ndf" varCompressFileName="/var/opt/mssql/data/datacloud_compresstemp.ndf" -i ~/art-ans/src/t-sql/DB-20_CreateDatabaseAndFilegroupsSQLCMD.sql

