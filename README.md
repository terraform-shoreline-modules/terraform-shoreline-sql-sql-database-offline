
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Database Offline (SQLServer)
---

This incident type refers to a situation where a SQLServer database goes offline, which can potentially cause disruptions in software or applications that rely on it. The incident is triggered by a monitoring system that detects the database's state is not available. A prompt response is necessary to resolve the issue and prevent any adverse impact on the system.

### Parameters
```shell
# Environment Variables

export SQL_SERVER_SERVICE_NAME="PLACEHOLDER"

export PORT_NUMBER="PLACEHOLDER"

export SERVER_NAME="PLACEHOLDER"

export INSTANCE_NAME="PLACEHOLDER"

export DATABASE_PASSWORD="PLACEHOLDER"

export DATABASE_USERNAME="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"
```

## Debug

### Check if the SQL Server service is running
```shell
Get-Service -Name ${SQL_SERVER_SERVICE_NAME}
```

### Check the connection to the server
```shell
Test-NetConnection -ComputerName ${SERVER_NAME} -Port ${PORT_NUMBER}
```

### Check if the database is online
```shell
Invoke-Sqlcmd -Query "SELECT name, state_desc FROM sys.databases" -ServerInstance ${SERVER_NAME}\${INSTANCE_NAME}
```

### Check the SQL Server error log for any issues
```shell
Get-EventLog -LogName Application -Source MSSQLSERVER | Where-Object {$_.EntryType -eq "Error"}
```

### Restart the SQL Server service
```shell
Restart-Service -Name ${SQL_SERVER_SERVICE_NAME} -Force
```

### Database configuration issues: Incorrect configuration of the SQLServer database can cause it to go offline. This could be due to changes made to the database that are not compatible with its current configuration.
```shell


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


```

## Repair

### Restart the SQLServer database service to see if it can recover from the outage. This step is only recommended if the cause of the outage is unclear or if the service is not responding.
```shell


@echo off



set serviceName=${NAME_OF_THE_SQLSERVER_DATABASE_SERVICE}



echo Stopping %serviceName%...

net stop %serviceName%



echo Starting %serviceName%...

net start %serviceName%



echo %serviceName% restarted successfully.


```

### Check the server hosting the SQLServer database to ensure that it is running correctly and all services are operational.
```shell


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


```