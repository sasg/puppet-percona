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
    data   => {
      mysql_logdir           => $percona::mysql_logdir,
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

  exec { "${name}-mysql_install_db":
    command => '/usr/bin/mysql_install_db',
    onlyif  => "/usr/bin/test ! -d ${percona::mysql_datadir}/mysql",
  }

  unless str2bool($::percona_db_prepared) {
    class { '::percona::prepare_db':
      require => Exec["${name}-mysql_install_db"],
    }
  }
}
