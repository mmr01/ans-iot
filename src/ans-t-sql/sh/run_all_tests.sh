#!/bin/sh
export SQLCMDPASSWORD="powerdb@@@51"
echo "Runnung all tests".
echo "!!!!!!!!!!!!!!!!!!!"
echo "Running tests for 1 packet per hour"
/bin/sh ~/art-ans/src/t-sql/run_insert_tests_with_drop_and_create.sh
/bin/sh ~/art-ans/src/t-sql/run_select_tests.sh 1

counter=2;
while [ $counter -le 6 ] ;
do
    echo "    " Running tests for $counter packets per hour.
    /bin/sh ~/art-ans/src/t-sql/run_insert_tests_only.sh $counter
    /bin/sh ~/art-ans/src/t-sql/run_select_tests.sh $counter
    echo "    Sleeeping for 60 seconds."
    sleep 60
    counter=$((counter+1)) ;
done
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "All tests done."
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
