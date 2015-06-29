# == Class percona::create_db_base
#
class percona::create_db_base {

  $facter_directories = [
    '/etc/facter',
    '/etc/facter/facts.d',
  ]

  $facter_directories_params = {
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  ensure_resource('file', $facter_directories, $facter_directories_params)

  file { "${name}-my_cnf_d_dir":
    ensure  => directory,
    path    => '/etc/my.cnf.d',
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0755',
    purge   => true,
    recurse => true,
    require => File[$facter_directories],
  }
  ->

  datacat { $percona::mysql_config_file:
    ensure   => file,
    path     => $percona::mysql_config_file,
    owner    => 'mysql',
    group    => 'mysql',
    mode     => '0644',
    template => 'percona/node/my.cnf.erb',
  }
  ->

  datacat_fragment { "${name}-${percona::mysql_config_file}_fragment":
    target => $percona::mysql_config_file,
    data   => $percona::mysql_cnf_hash,
  }
  ->

  file { "${name}-logrotate":
    ensure  => file,
    path    => '/etc/logrotate.d/percona',
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
  file { "${name}-client_admin_auth_file_root_home":
    ensure => link,
    path   => "${::root_home}/.my.cnf",
    target => '/etc/my.cnf.d/client/admin_auth.cnf',
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0640',
  }
  ->

  exec { "${name}-${percona::mysql_datadir}_mkdir":
    command => "/bin/mkdir -p ${percona::mysql_datadir}",
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_datadir}",
  }
  ->

  exec { "${name}-${percona::mysql_socketdir}_mkdir":
    command => "/bin/mkdir -p ${percona::mysql_socketdir}",
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_socketdir}",
  }
  ~>

  ## To ensure socket directory has the right permission
  file { "${name}-${percona::mysql_socketdir}":
    ensure => directory,
    path   => $percona::mysql_socketdir,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0755',
  }
  ->

  exec { "${name}-${percona::mysql_tmpdir}_mkdir":
    command => "/bin/mkdir -p ${percona::mysql_tmpdir}",
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_tmpdir}",
  }
  ->

  exec { "${name}-${percona::mysql_logdir}_mkdir":
    command => "/bin/mkdir -p ${percona::mysql_logdir}",
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_logdir}",
  }
  ->

  exec { "${name}-${percona::mysql_binlogdir}_mkdir":
    command => "/bin/mkdir -p ${percona::mysql_binlogdir}",
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_binlogdir}",
  }
  ->

  exec { "${name}-${percona::mysql_piddir}_mkdir":
    command => "/bin/mkdir -p ${percona::mysql_piddir}",
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_piddir}",
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
}
