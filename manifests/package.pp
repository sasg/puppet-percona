# == Class percona::package
#
class percona::package {

  case $::osfamily {
    'redhat': {

      if $percona::db_galera {
        if ! defined(Package['nc']) {
          package {'nc':
            ensure => present,
          }
        }
  
        if ! defined(Package['pv']) {
          package {'pv':
            ensure => present,
          }
        }
  
        if ! defined(Package['socat']) {
          package {'socat':
            ensure => present,
          }
        }
  
        if $percona::is_arbitrator {
  
          package {'Percona-XtraDB-Cluster-garbd-3':
            ensure => present,
          }
  
        } else {
  
          if ! defined(Package['xinetd']) {
            package {'xinetd':
              ensure => present,
            }
          }
  
          package {"Percona-XtraDB-Cluster-full-${percona::percona_version}":
            ensure => present,
          }
        }
      } else {
        package {"Percona-Server-server-${percona::percona_version}":
          ensure => present,
        }
      }
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }

  }

}
