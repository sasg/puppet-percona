# == Class percona::create_node
#
class percona::create_node {

  ## We only support x86_64 plattform
  $wsrep_provider_path = '/usr/lib64/galera3/libgalera_smm.so'

  if str2bool($percona::exported_resource) == true {
    @@datacat_fragment { "${name}-${::fqdn}_garb":
      target => $percona::garbd_config_file,
      data   => {
        nodes => [ $percona::node_ip ],
      },
      tag    => "galera_wsrep_${percona::wsrep_cluster_name}",
    }

    @@datacat_fragment { "${name}-${::fqdn}_mysql":
      target => $percona::wsrep_config_file,
      data   => {
        nodes => [ $percona::node_ip ],
      },
      tag    => "galera_wsrep_${percona::wsrep_cluster_name}",
    }

    Datacat_fragment <<| tag == "galera_wsrep_${percona::wsrep_cluster_name}" |>>
  } elsif $percona::node_list {
    datacat_fragment { "${name}-db_members":
      target => $percona::wsrep_config_file,
      data   => {
        nodes => [ $percona::node_list ],
      },
    }
  } else {
    fail('Please define nodes or activate exported resources')
  }

  file { "${name}-my_cnf_d_dir":
    ensure  => directory,
    path    => '/etc/my.cnf.d',
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0755',
    purge   => true,
    recurse => true,
  }
  ->

  datacat { $percona::mysql_config_file:
    ensure   => file,
    path     => $percona::mysql_config_file,
    owner    => 'mysql',
    group    => 'mysql',
    mode     => '0640',
    template => 'percona/node/my.cnf.erb',
  }
  ->

  datacat_fragment { "${name}-${percona::mysql_config_file}_fragment":
    target => $percona::mysql_config_file,
    data   => {
      hostname           => $::hostname,
      memorysize_mb      => $::memorysize_mb,
      mysql_binlogdir    => $percona::mysql_binlogdir,
      mysql_datadir      => $percona::mysql_datadir,
      mysql_logdir       => $percona::mysql_logdir,
      mysql_piddir       => $percona::mysql_piddir,
      mysql_socket       => $percona::mysql_socket,
      mysql_tmpdir       => $percona::mysql_tmpdir,
      processorcount     => $::processorcount,
      reserved_os_memory => $percona::reserved_os_memory,
    },
  }
  ->

  datacat { $percona::wsrep_config_file:
    ensure   => file,
    path     => $percona::wsrep_config_file,
    owner    => 'mysql',
    group    => 'mysql',
    mode     => '0640',
    template => 'percona/node/wsrep.cnf.erb',
  }
  ->

  datacat_fragment { "${name}-${percona::wsrep_config_file}_fragment":
    target => $percona::wsrep_config_file,
    data   => {
      processorcount         => $::processorcount,
      wsrep_cluster_name     => $percona::wsrep_cluster_name,
      wsrep_cluster_options  => $percona::wsrep_cluster_options,
      wsrep_node_address     => $percona::node_ip,
      wsrep_node_name        => $percona::wsrep_node_name,
      wsrep_provider_options => $percona::wsrep_provider_options,
      wsrep_provider_path    => $wsrep_provider_path,
      wsrep_sst_method       => $percona::wsrep_sst_method,
      wsrep_sst_password     => $percona::wsrep_sst_password,
      wsrep_sst_username     => $percona::wsrep_sst_username,
    },
  }
  ->

  file { "${name}-logrotate":
    ensure  => file,
    path    => '/etc/logrotate.d/galera',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('percona/node/logrotate.mysql.erb'),
  }
  ->

  file { "${name}-client_auth_dir":
    ensure => directory,
    path   => '/etc/my.cnf.d/client',
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0750',
  }
  ->

  file { "${name}-client_admin_auth_file":
    ensure  => file,
    path    => '/etc/my.cnf.d/client/admin_auth.cnf',
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0640',
    content => template('percona/node/admin_auth.cnf.erb'),
  }
  ->

  exec { "${name}-${percona::mysql_dbdir}_mkdir":
    command => "/bin/mkdir -p ${percona::mysql_dbdir}",
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_dbdir}",
  }
  ->

  file { "${name}-${percona::mysql_dbdir}":
    ensure => directory,
    path   => $percona::mysql_dbdir,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0755',
  }
  ->

  file { "${name}-${percona::mysql_tmpdir}":
    ensure => directory,
    path   => $percona::mysql_tmpdir,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0750',
  }
  ->

  file { "${name}-${percona::mysql_logdir}":
    ensure => directory,
    path   => $percona::mysql_logdir,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0750',
  }
  ->

  file { "${name}-${percona::var_log_mysql}":
    ensure => link,
    path   => '/var/log/mysql',
    target => $percona::mysql_logdir,
  }
  ->

  file { "${name}-${percona::mysql_binlogdir}":
    ensure => directory,
    path   => $percona::mysql_binlogdir,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0750',
  }
  ->

  file { "${name}-${percona::mysql_piddir}":
    ensure => directory,
    path   => $percona::mysql_piddir,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0750',
  }
  ->

  exec { "${name}-mysql_install_db":
    command => '/usr/bin/mysql_install_db',
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_datadir}/mysql",
  }
  ->

  class  { 'percona::prepare_db': }
  ->

  Service <| title == $percona::mysql_service_name |>

}
