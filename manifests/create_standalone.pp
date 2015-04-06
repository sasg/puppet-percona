# == Class percona::create_standalone
#
class percona::create_standalone {

  include ::percona::virtual::service

  exec { "${name}-mysql_install_db":
    command => '/usr/bin/mysql_install_db',
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_datadir}/mysql",
  }
  ->

  Service <| title == $percona::mysql_service_name |> {
    ensure => running,
    enable => true,
  }

  unless str2bool($::percona_db_prepared) {
    class { '::percona::prepare_db':
      require => Service[$percona::mysql_service_name],
    }
  }

}
