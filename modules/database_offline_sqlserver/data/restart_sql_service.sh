

@echo off



set serviceName=${NAME_OF_THE_SQLSERVER_DATABASE_SERVICE}



echo Stopping %serviceName%...

net stop %serviceName%



echo Starting %serviceName%...

net start %serviceName%



echo %serviceName% restarted successfully.