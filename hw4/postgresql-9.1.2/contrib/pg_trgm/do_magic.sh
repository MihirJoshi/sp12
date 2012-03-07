# This script recompiles and reinstalls the pg_trgm module
# It then restarts postgres, and runs a query (optionally).
# Example usage: ./do_magic.sh "SELECT show_trgm('cat');"
# For just recompile & restart: ./do_magic.sh

# Compile!
make 2>&1 | tee make_output.tmp # eff bash

# Error checking
numError=`cat make_output.tmp | grep "*** .* Error " | wc -l`
numWarning=`cat make_output.tmp | grep ": warning:" | wc -l`
didWork=`cat make_output.tmp | grep "make: Nothing to be done" | wc -l`
lastModifiedC=`date -r trgm_op.c +%s`
lastModifiedH=`date -r trgm.h +%s`

# Print out errors/warnings we found
if [ $numError != '0' ]; then
    echo -e "\e[00;31mERROR:\e[00m Compilation failed."
    exit
elif [ $numWarning == '1' ]; then
    echo -e "\e[00;33m$numWarning compiler warning detected. Careful!\e[00m"
elif [ $numWarning != '0' ]; then
    echo -e "\e[00;33m$numWarning compiler warnings detected. Careful!\e[00m"
elif [ $didWork == '1' ]; then
    if [ $lastModifiedC -lt $lastModifiedH ]; then
	echo -e "\e[00;31mALERT: We did not recompile. If you just changed the .h file, we did not pick up the changes!\e[00m"
    fi
fi

# Install the changes
make install

# Restart postgres
$HOME/pgsql/bin/pg_ctl -D $HOME/pgsql/data stop
cat /dev/null > ../../log.txt
$HOME/pgsql/bin/pg_ctl start -D $HOME/pgsql/data -l ../../log.txt

# Check for the env variable
if [ -z $POSTGRES_Q_GRAM ]; then
    echo -e "\e[00;33mNotice: POSTGRES_Q_GRAM is not set, default q will be used.\e[00m"
else
    echo -e "\e[00;32mNotice: q = $POSTGRES_Q_GRAM\e[00m"
fi

# Wait for postgres to start up and then execute our query.
sleep 2.5
# FIXME: You may have to change the port below
$HOME/pgsql/bin/psql -p 5430 postgres -c "$1"
