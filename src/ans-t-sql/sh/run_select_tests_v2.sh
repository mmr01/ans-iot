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
echo Tests - select.
echo --------------------
echo "Selecting data in a loop (10 times, all records)"
counter=1;
while [ $counter -le 10 ] ;
do
    echo "    Test" $counter.
    /opt/mssql-tools/bin/sqlcmd -U powerdb -S . -v varNumberOfPacketsPerHour=$1 -i ~/art-ans/src/t-sql/DB-90_Select_tests_SQLCMD_v2.sql >/dev/null 
    echo "    DB-90_Select_tests_SQLCMD_v2.sql - executed."
    echo "    Sleeping for 30 seconds."
    sleep 30
    counter=$((counter+1)) ;
done
echo
echo "All selection tests done."

