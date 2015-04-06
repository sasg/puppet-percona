# == Class percona::prepare_db
#
class percona::prepare_db {

  include ::percona::virtual::service

  $db_default_user = 'root'

  if $percona::db_galera {

    exec { "${name}-mysqld_start_for_grants":
      path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
      command => 'service mysql start --wsrep-provider=none',
      before  => Percona::Mysql_query["${name}-add_admin_user"],
    }
    ->

    percona::mysql_query { "${name}-add_wsrep_sst_user":
      query  => "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '${percona::wsrep_sst_username}'@'localhost' IDENTIFIED BY '${percona::wsrep_sst_password}';",
    }
    ->

    percona::mysql_query { "${name}-add_monitor_user":
      query   => "GRANT USAGE,PROCESS ON *.* TO '${percona::mysql_monitor_user}'@'localhost' IDENTIFIED BY '${percona::mysql_monitor_password}';",
    }

    Service <| title == $percona::mysql_service_name |> {
      ensure  => stopped,
      require => Percona::Mysql_query["${name}-remove_default_user_localhost"],
    }

  }

  percona::mysql_query { "${name}-add_admin_user":
    query  => "GRANT ALL PRIVILEGES ON *.* TO '${percona::mysql_admin_user}'@'localhost' IDENTIFIED BY '${percona::mysql_admin_password}' WITH GRANT OPTION;",
  }
  ->

  percona::mysql_query { "${name}-remove_default_user_127_0_0_1":
    query  => "DROP USER '${db_default_user}'@'127.0.0.1';",
  }
  ->

  percona::mysql_query { "${name}-remove_default_user_ipv6":
    query  => "DROP USER '${db_default_user}'@'::1';",
  }
  ->

  percona::mysql_query { "${name}-remove_default_user_fqdn":
    query  => "DROP USER '${db_default_user}'@'${::fqdn}';",
  }
  ->

  percona::mysql_query { "${name}-remove_empty_default_user_localhost":
    query  => "DROP USER ''@'localhost';",
  }
  ->

  percona::mysql_query { "${name}-remove_empty_default_user_fqdn":
    query  => "DROP USER ''@'${::fqdn}';",
  }
  ->

  percona::mysql_query { "${name}-remove_default_user_localhost":
    query  => "DROP USER '${db_default_user}'@'localhost';",
  }
  ->

  file { "${name}-percona_db_prepared":
    ensure  => file,
    path    => '/etc/facter/facts.d/percona_db_prepared.txt',
    content => 'percona_db_prepared=true',
  }

}
