# == Class percona::params
#
# This class is meant to be called from percona
# It sets variables according to platform
#
class percona::params {

  $db_galera                = false

  $exported_resource        = true
  $node_list                = ''

  ## Memory in MB
  $reserved_os_memory       = '256'

  ## Galera Nodes Variables
  $wsrep_cluster_name       = 'GALERA_CLUSTER'
  $wsrep_cluster_options    = 'pc.wait_prim=no'
  $wsrep_provider_options   = 'gcache.size=2G'
  $wsrep_node_name          = "${::hostname}_${::ipaddress}"
  $wsrep_sst_method         = 'rsync'
  $wsrep_sst_username       = 'sst'
  $wsrep_sst_password       = 'very_s3cret'

  ## Percona variables
  $percona_version          = '56'

  ## Arbitrator / Garbd / Quorum Variables
  $is_arbitrator            = false

  $node_ip                  = $::ipaddress_eth0

  $garbd_config_file        = '/etc/sysconfig/garb'
  $garbd_service_name       = 'garb'

  $garbd_log_directory      = '/var/log/garbd'

  ## Additional MySQL Values
  $mysql_service_name       = 'mysql'
  $mysql_admin_user         = 'superuser'
  $mysql_admin_password     = 'very_s3cret'
  $mysql_config_file        = '/etc/my.cnf'
  $wsrep_config_file        = '/etc/my.cnf.d/wsrep.cnf'
  $mysql_dbdir              = '/srv/db'
  $mysql_datadir            = 'data'
  $mysql_socket             = 'mysql.sock'
  $mysql_tmpdir             = 'tmp'
  $mysql_logdir             = 'log'
  $mysql_binlogdir          = 'binlog'
  $mysql_piddir             = '/var/run/mysqld'

  $mysql_monitor_user       = 'mmonitor'
  $mysql_monitor_password   = 'very_s3cret'

}
