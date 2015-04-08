# == Class percona::package
#
class percona::package {

  case $::osfamily {
    'redhat': {

      if $percona::db_galera {
        ensure_packages(['nc', 'pv', 'socat'])

        if $percona::is_arbitrator {

          package {'Percona-XtraDB-Cluster-garbd-3':
            ensure => present,
          }

        } else {
          ensure_packages('xinetd')

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
