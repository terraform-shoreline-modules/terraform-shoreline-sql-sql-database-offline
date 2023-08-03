resource "shoreline_notebook" "database_offline_sqlserver" {
  name       = "database_offline_sqlserver"
  data       = file("${path.module}/data/database_offline_sqlserver.json")
  depends_on = [shoreline_action.invoke_db_check,shoreline_action.invoke_restart_sql_service,shoreline_action.invoke_sqlserver_check_services]
}

resource "shoreline_file" "db_check" {
  name             = "db_check"
  input_file       = "${path.module}/data/db_check.sh"
  md5              = filemd5("${path.module}/data/db_check.sh")
  description      = "Database configuration issues: Incorrect configuration of the SQLServer database can cause it to go offline. This could be due to changes made to the database that are not compatible with its current configuration."
  destination_path = "/agent/scripts/db_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restart_sql_service" {
  name             = "restart_sql_service"
  input_file       = "${path.module}/data/restart_sql_service.sh"
  md5              = filemd5("${path.module}/data/restart_sql_service.sh")
  description      = "Restart the SQLServer database service to see if it can recover from the outage. This step is only recommended if the cause of the outage is unclear or if the service is not responding."
  destination_path = "/agent/scripts/restart_sql_service.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "sqlserver_check_services" {
  name             = "sqlserver_check_services"
  input_file       = "${path.module}/data/sqlserver_check_services.sh"
  md5              = filemd5("${path.module}/data/sqlserver_check_services.sh")
  description      = "Check the server hosting the SQLServer database to ensure that it is running correctly and all services are operational."
  destination_path = "/agent/scripts/sqlserver_check_services.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_db_check" {
  name        = "invoke_db_check"
  description = "Database configuration issues: Incorrect configuration of the SQLServer database can cause it to go offline. This could be due to changes made to the database that are not compatible with its current configuration."
  command     = "`chmod +x /agent/scripts/db_check.sh && /agent/scripts/db_check.sh`"
  params      = ["DATABASE_PASSWORD","DATABASE_NAME","DATABASE_USERNAME","SERVER_NAME"]
  file_deps   = ["db_check"]
  enabled     = true
  depends_on  = [shoreline_file.db_check]
}

resource "shoreline_action" "invoke_restart_sql_service" {
  name        = "invoke_restart_sql_service"
  description = "Restart the SQLServer database service to see if it can recover from the outage. This step is only recommended if the cause of the outage is unclear or if the service is not responding."
  command     = "`chmod +x /agent/scripts/restart_sql_service.sh && /agent/scripts/restart_sql_service.sh`"
  params      = []
  file_deps   = ["restart_sql_service"]
  enabled     = true
  depends_on  = [shoreline_file.restart_sql_service]
}

resource "shoreline_action" "invoke_sqlserver_check_services" {
  name        = "invoke_sqlserver_check_services"
  description = "Check the server hosting the SQLServer database to ensure that it is running correctly and all services are operational."
  command     = "`chmod +x /agent/scripts/sqlserver_check_services.sh && /agent/scripts/sqlserver_check_services.sh`"
  params      = ["DATABASE_NAME","SERVER_NAME"]
  file_deps   = ["sqlserver_check_services"]
  enabled     = true
  depends_on  = [shoreline_file.sqlserver_check_services]
}

