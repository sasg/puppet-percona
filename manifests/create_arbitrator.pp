# == Class percona::create_arbitrator
#
class percona::create_arbitrator {

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
    datacat_fragment { "${name}-arbitrator_members":
      target => $percona::garbd_config_file,
      data   => {
        nodes => [ $percona::node_list ],
      },
    }
  } else {
    fail('Please define an arbitrator or activate exported resources')
  }

  ## Can not have "$name" as part of resource naming because of exported resources 
  ## for create_node and create_arbitrator
  datacat { $percona::garbd_config_file:
    ensure   => file,
    path     => $percona::garbd_config_file,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    template => 'percona/garbd/garb.erb',
  }
  ->

  datacat_fragment { "${name}-arbitrator_options":
    target => $percona::garbd_config_file,
    data   => {
      garbd_log_directory => $percona::garbd_log_directory,
      garbd_options       => $percona::garbd_options,
      wsrep_cluster_name  => $percona::wsrep_cluster_name,
    },
  }
  ->

  file { "${name}-logrotate":
    ensure  => file,
    path    => '/etc/logrotate.d/garb',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('percona/garbd/logrotate.garb.erb'),
  }
  ->

  file { "${name}-${percona::garbd_log_directory}":
    ensure => directory,
    path   => $percona::garbd_log_directory,
    owner  => 'nobody',
    group  => 'nobody',
    mode   => '0755',
  }
  ->

  service { "${name}-${percona::garbd_service_name}":
    name   => $percona::garbd_service_name,
    enable => true,
  }

}
