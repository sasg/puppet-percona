# == Class percona::params
#
# This class is meant to be called from percona
# It sets variables according to platform
#
class percona::params {

  $mysql_cnf = {
    client             => {
      socket => '/srv/db/percona/mysql.sock',
    },
    mysql              => {
      socket                => '/srv/db/percona/mysql.sock',
      default-character-set => 'utf8',
    },
    mysqld             => {
      datadir                         => '/srv/db/percona/data',
      socket                          => '/srv/db/percona/mysql.sock',
      tmpdir                          => '/srv/db/percona/tmp',
      log-error                       => '/srv/db/percona/log/mysql-err.log',
      general_log_file                => '/srv/db/percona/log/mysql-general.log',
      slow_query_log_file             => '/srv/db/percona/log/mysql-slow.log',
      log-bin                         => '/srv/db/percona/binlog/mysql-bin',
      pid-file                        => '/var/run/mysqld/mysqld.pid',
      bind-address                    => '0.0.0.0',
      user                            => 'mysql',
      max_allowed_packet              => '64M',
      max_connections                 => '300',
      character-set-server            => 'utf8',
      collation-server                => 'utf8_general_ci',
      join_buffer_size                => '512K',
      transaction-isolation           => 'READ-COMMITTED',
      thread_cache_size               => '50',
      explicit_defaults_for_timestamp => 'TRUE',
      innodb_file_per_table           => '1',
      innodb_data_file_path           => 'ibdata1:128M:autoextend',
      innodb_file_format              => 'Barracuda',
      innodb_open_files               => '1000',
      innodb_flush_method             => 'O_DIRECT',
      innodb_log_files_in_group       => '3',
      innodb_log_file_size            => '256M',
      innodb_log_buffer_size          => '8M',
      innodb_autoinc_lock_mode        => '2',
      innodb_flush_log_at_trx_commit  => '0',
      binlog_format                   => 'ROW',
      default-storage-engine          => 'InnoDB',
      query_cache_size                => '0',
      query_cache_type                => '0',
      myisam-recover-options          => 'BACKUP,FORCE',
      myisam_sort_buffer_size         => '16M',
      log-warnings                    => '2',
      log-output                      => 'FILE',
      general_log                     => '0',
      slow-query-log                  => '0',
      log-queries-not-using-indexes   => '0',
      long_query_time                 => 2,
      max_binlog_size                 => '256M',
      binlog_cache_size               => '256K',
      expire_logs_days                => '20',
      log-slave-updates               => 'TRUE',
    },
    mysqldump          => {
      socket                => '/srv/db/percona/mysql.sock',
      default-character-set => 'utf8',
      max_allowed_packet    => '256M',
      log-error             => '/srv/db/percona/log/mysqldump-err.log',
    },
  }

  $wsrep_cnf = {
    mysqld         => {
      wsrep_cluster_name     => 'GALERA_CLUSTER',
      wsrep_node_address     => $::ipaddress_eth0,
      wsrep_node_name        => "${::hostname}_${::ipaddress}",
      wsrep_provider_options => 'gcache.size=2G',
      wsrep_provider         => '/usr/lib64/galera3/libgalera_smm.so',
      wsrep_sst_method       => 'rsync',
      wsrep_sst_auth         => 'sst:very_s3cret',
    },
    sst             => {
      progess            => '/srv/db/percona/log/sst_progress.log',
      time               => '1',
      inno-backup-opts   => '--no-backup-locks',
    },
  }

  $db_galera                = false

  $exported_resource        = true
  $node_list                = undef

  ## Memory in MB
  $reserved_os_memory       = '256'

  ## Percona variables
  $percona_version          = '56'

  ## Arbitrator / Garbd / Quorum Variables
  $is_arbitrator            = false

  $garbd_config_file        = '/etc/sysconfig/garb'
  $garbd_service_name       = 'garb'

  $garbd_log_directory      = '/var/log/garbd'

  ## Additional MySQL Values
  $mysql_service_name       = 'mysql'
  $mysql_admin_user         = 'superuser'
  $mysql_admin_password     = 'very_s3cret'
  $mysql_config_file        = '/etc/my.cnf'
  $wsrep_config_file        = '/etc/my.cnf.d/wsrep.cnf'

  $mysql_monitor_user       = 'mmonitor'
  $mysql_monitor_password   = 'very_s3cret'

  $wsrep_cluster_options    = 'pc.wait_prim=no'

  ## OS Switches

  case $::osfamily {
    'RedHat': {
      if ($::operatingsystem != 'Amazon')
      and (($::operatingsystem != 'Fedora' and versioncmp($::operatingsystemrelease, '7.0') >= 0)
      or  ($::operatingsystem == 'Fedora' and versioncmp($::operatingsystemrelease, '15') >= 0)) {
        $service_provider = 'systemd'
      } else {
        $service_provider = undef
      }
    }
    default: {
      fail("Unsupported platform: ${module_name} currently doesn't support ${::osfamily} or ${::operatingsystem}")
    }
  }

  ## Service Provider
  case $service_provider {
    'systemd': {
      $bootstrap_start_cmd = 'systemctl start mysql@bootstrap.service'
      $bootstrap_stop_cmd = 'systemctl stop mysql@bootstrap.service && systemctl start mysql.service'
      $prepare_start_cmd = 'systemctl start mysql@prepare.service'
      $prepare_stop_cmd = 'systemctl stop mysql@prepare.service'
    }
    default: {
      $bootstrap_start_cmd = "service ${mysql_service_name} bootstrap-pxc"
      $bootstrap_stop_cmd = "service ${mysql_service_name} restart"
      $prepare_start_cmd = "service ${mysql_service_name} start --wsrep-provider=none"
      $prepare_stop_cmd = "service ${mysql_service_name} stop"
    }
  }
}
