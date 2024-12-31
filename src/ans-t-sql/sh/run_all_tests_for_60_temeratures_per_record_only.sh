#!/bin/sh
export SQLCMDPASSWORD="powerdb@@@51"
echo "    " Running tests for 1 packets per hour.
/bin/sh ~/art-ans/src/t-sql/run_insert_tests_only.sh 1
/bin/sh ~/art-ans/src/t-sql/run_select_tests.sh 1
echo "All tests done."
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
