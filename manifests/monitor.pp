# == Class percona::monitor
#
class percona::monitor {

  ## Set variable only for puppet-lint to have a valid syntax
  $mysql_check_name = 'mysqlchk'
  $mysql_check_port = '9223'

  file { "${name}-client_auth_dir":
    ensure => directory,
    path   => '/etc/my.cnf.d/monitor',
    owner  => 'nobody',
    group  => 'nobody',
    mode   => '0750',
  }
  ->

  file { "${name}-client_auth_file":
    ensure  => file,
    path    => '/etc/my.cnf.d/monitor/monitor_auth.cnf',
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '0640',
    content => template('percona/monitor/monitor_auth.cnf.erb'),
  }
  ->

  file { "${name}-monitor_check":
    ensure  => file,
    path    => '/usr/bin/clustercheck',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('percona/monitor/clustercheck.erb'),
  }
  ->

  augeas { "${name}-service_mysqlchk":
    context => '/files/etc/services',
    changes => [
      'ins service-name after service-name[last()]',
      "set service-name[last()] ${mysql_check_name}",
      "set service-name[. = '${mysql_check_name}']/port ${mysql_check_port}",
      "set service-name[. = '${mysql_check_name}']/protocol tcp",
    ],
    onlyif  => "match service-name[port = '${mysql_check_port}'] size == 0",
  }
  ->

  file { "${name}-xinetd_mysqlchk":
    ensure  => file,
    path    => '/etc/xinetd.d/mysqlchk',
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '0640',
    notify  => Service["${name}-xinetd"],
    content => template('percona/monitor/mysqlchk.xinetd.erb'),
  }
  ->

  service { "${name}-xinetd":
    ensure     => running,
    name       => 'xinetd',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
  }

}
