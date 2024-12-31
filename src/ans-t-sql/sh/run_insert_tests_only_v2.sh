#!/bin/sh
if [ $# != 1 ]
then
	echo "This script expects the number of packets per hour as its parameter."
	echo "Accepted values are: 1, 2, 3, 4, 5, 6."
	exit 1
fi
if [ $1 -ne 1 ] && [ $1 -ne 2 ] && [ $1 -ne 3 ] && [ $1 -ne 4 ] && [ $1 -ne 5 ] && [ $1 -ne 6 ]
then
	echo "Accepted values are: 1, 2, 3, 4, 5, 6 only."
	exit 1
fi
export SQLCMDPASSWORD="powerdb@@@51"
echo --------------------------------------
echo "Inserting data in a loop (11 times)"
counter=1;
while [ $counter -le 11 ] ;
do
    echo "    Test" $counter.
    /opt/mssql-tools/bin/sqlcmd -U powerdb -S . -v varNumberOfPacketsPerHour=$1 -i ~/art-ans/src/t-sql/DB-80_PopulateTablesWithRandomData_SQLCMD_v2.sql > /dev/null
    echo "    DB-80_PopulateTablesWithRandomData_SQLCMD_v2.sql - executed."
    echo "    Sleeeping for 60 seconds."
    sleep 60
    counter=$((counter+1)) ;
done
echo
echo "All insertion tests done."

