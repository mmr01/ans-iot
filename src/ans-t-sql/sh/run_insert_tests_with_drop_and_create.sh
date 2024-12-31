#!/bin/sh
export SQLCMDPASSWORD="powerdb@@@51"
/bin/sh ~/art-ans/src/t-sql/drop_database.sh
/bin/sh ~/art-ans/src/t-sql/create_database.sh
echo Database was droped and created again.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-30_ANS.sql
echo DB-30_ANS.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-40_CreateTables.sql
echo DB-40_CreateTables.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-50_AuxiliaryFunctionsForRandomDataGeneration.sql
echo DB-50_AuxiliaryFunctionsForRandomDataGeneration.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-60_CreateTableForMetrics.sql
echo DB-60_CreateTableForMetrics.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-62_CreateViewsForMetrics.sql
echo DB-62_CreateViewsForMetrics.sql - executed.
/opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-70_Linux_DLL.sql
echo DB-DLL.sql - executed.
echo --------------------
echo "Inserting data in a loop (11 times)"
counter=1;
while [ $counter -le 11 ] ;
do
    echo "    Test" $counter.
    /opt/mssql-tools/bin/sqlcmd -U powerdb -S . -i ~/art-ans/src/t-sql/DB-80_PopulateTablesWithRandomData.sql > /dev/null
    echo "    DB-80_PopulateTablesWithRandomData.sql - executed."
    echo "    Sleeeping for 60 seconds."
    sleep 60
    counter=$((counter+1)) ;
done
echo
echo "All insertion tests done."

