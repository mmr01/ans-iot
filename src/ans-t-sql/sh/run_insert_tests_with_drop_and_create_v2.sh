#!/bin/sh
export SQLCMDPASSWORD="powerdb@@@51"
/bin/sh ~/art-ans/src/t-sql/drop_database_v2.sh
/bin/sh ~/art-ans/src/t-sql/create_database_v2.sh
echo Database was droped and created again.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-30_ANS_v2.sql
echo DB-30_ANS_v2.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-40_CreateTables_v2.sql
echo DB-40_CreateTables_v2.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-50_AuxiliaryFunctionsForRandomDataGeneration_v2.sql
echo DB-50_AuxiliaryFunctionsForRandomDataGeneration_v2.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-60_CreateTableForMetrics_v2.sql
echo DB-60_CreateTableForMetrics_v2.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-62_CreateViewsForMetrics_v2.sql
echo DB-62_CreateViewsForMetrics_v2.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-70_Linux_DLL_v2.sql
echo DB-70_Linux_DLL_v2.sql - executed.
echo --------------------
echo "Inserting data in a loop (11 times)"
counter=1;
while [ $counter -le 11 ] ;
do
    echo "    Test" $counter.
    /opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-80_PopulateTablesWithRandomData_v2.sql > /dev/null
    echo "    DB-80_PopulateTablesWithRandomData_v2.sql - executed."
    echo "    Sleeeping for 60 seconds."
    sleep 60
    counter=$((counter+1)) ;
done
echo
echo "All insertion tests done."

