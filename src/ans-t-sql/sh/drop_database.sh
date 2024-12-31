#!/bin/sh
export SQLCMDPASSWORD="powerdb@@@51"
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-10_DropDatabase.sql

