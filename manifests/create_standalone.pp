# == Class percona::create_standalone
#
class percona::create_standalone {

  exec { "${name}-mysql_install_db":
    command => '/usr/bin/mysql_install_db',
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_datadir}/mysql",
  }
  ->

  file { "${name}-is_mysql_standalone":
    ensure  => file,
    path    => '/etc/facter/facts.d/is_mysql_standalone.txt',
    content => 'is_mysql_standalone=true',
  }
  ->

  service { $::percona::mysql_service_name:
    ensure => running,
    enable => true,
  }

  unless str2bool($::percona_db_prepared) {
    class { '::percona::prepare_db':
      require => Service[$percona::mysql_service_name],
    }
  }

}
