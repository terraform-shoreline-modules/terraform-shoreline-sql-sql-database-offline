

#!/bin/bash



# Set variables

DB_NAME=${DATABASE_NAME}

DB_USERNAME=${DATABASE_USERNAME}

DB_PASSWORD=${DATABASE_PASSWORD}



# Check if the SQL Server service is running

if (( $(sc query MSSQLSERVER | grep "STATE" | wc -l) > 0 )); then

    echo "SQL Server service is running"

else

    echo "SQL Server service is not running"

fi



# Check if the database is online

sqlcmd -S ${SERVER_NAME} -U $DB_USERNAME -P $DB_PASSWORD -Q "SELECT name, state_desc FROM sys.databases WHERE name = '$DB_NAME';"



# Check for any error logs related to the database

Get-EventLog -LogName Application -Source MSSQLSERVER | Select-String -Pattern "$DB_NAME"



# Check for any recent changes made to the database

sqlcmd -S ${SERVER_NAME} -U $DB_USERNAME -P $DB_PASSWORD -Q "SELECT create_date, modify_date FROM sys.databases WHERE name = '$DB_NAME';"