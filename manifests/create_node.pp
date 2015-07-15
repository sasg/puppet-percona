# == Class percona::create_node
#
class percona::create_node {

  if str2bool($percona::exported_resource) == true {
    @@datacat_fragment { "${name}-${::fqdn}_garb":
      target => $percona::garbd_config_file,
      data   => {
        nodes => [ $percona::wsrep_cnf_hash['mysqld']['wsrep_node_address'] ],
      },
      tag    => "galera_wsrep_${percona::wsrep_cnf_hash['mysqld']['wsrep_cluster_name']}",
    }

    @@datacat_fragment { "${name}-${::fqdn}_mysql":
      target => $percona::wsrep_config_file,
      data   => {
        nodes => [ $percona::wsrep_cnf_hash['mysqld']['wsrep_node_address'] ],
      },
      tag    => "galera_wsrep_${percona::wsrep_cnf_hash['mysqld']['wsrep_cluster_name']}",
    }

    Datacat_fragment <<| tag == "galera_wsrep_${percona::wsrep_cnf_hash['mysqld']['wsrep_cluster_name']}" |>>
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

  ## Can not have "$name" as part of resource naming because of exported resources
  ## for create_node and create_arbitrator
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
    data   => $percona::wsrep_cnf_hash,
  }
  ->

  exec { "${name}-mysql_install_db":
    command => '/usr/bin/mysql_install_db',
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_datadir}/mysql",
  }

  unless str2bool($::percona_db_prepared) {
    class { '::percona::prepare_db':
      require => Exec["${name}-mysql_install_db"],
    }
  }

  if $::percona::automatic_bootstrap {
    anchor {"${name}::begin": }          ->
    class  {'::percona::automatic_bootstrap':
      require => Class['::percona::prepare_db'],
    } ->
    anchor {"${name}::end": }
  }
}
