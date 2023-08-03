

@ECHO OFF

REM Check the server hosting the SQLServer database to ensure that it is running correctly and all services are operational.



REM Check if the SQLServer service is running

sc query MSSQLSERVER | findstr /i "STATE" | findstr /i "RUNNING" >nul

IF ERRORLEVEL 1 (

    ECHO SQLServer service is not running.

    REM Try to start the service

    sc start MSSQLSERVER

    ECHO SQLServer service has been started.

) ELSE (

    ECHO SQLServer service is running.

)



REM Check if the SQLServer database is online

sqlcmd -S ${SERVER_NAME} -U ${USERNAME} -P ${PASSWORD} -Q "SELECT name, state_desc FROM sys.databases WHERE name = '${DATABASE_NAME}'" | findstr /i "ONLINE" >nul

IF ERRORLEVEL 1 (

    ECHO SQLServer database is not online.

    REM Try to bring the database online

    sqlcmd -S ${SERVER_NAME} -U ${USERNAME} -P ${PASSWORD} -Q "ALTER DATABASE ${DATABASE_NAME} SET ONLINE"

    ECHO SQLServer database has been brought online.

) ELSE (

    ECHO SQLServer database is online.

)



PAUSE