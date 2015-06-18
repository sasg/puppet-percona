# == Class percona::create_node
#
class percona::automatic_bootstrap {

  $min_nodes_required = 3
  if $::percona::wsrep_cnf['mysqld']['wsrep_cluster_name'] {
    $wsrep_cluster_name = $::percona::wsrep_cnf['mysqld']['wsrep_cluster_name']
  } else {
    fail("${name}: wsrep cluster name is not set")
  }
  if $::percona::wsrep_cnf['mysqld']['wsrep_node_address'] {
    $node_address = $::percona::wsrep_cnf['mysqld']['wsrep_node_address']
  } else {
    $node_address = $::ipaddress
  }

  # Are we on the bootstrap node?
  if $::percona::bootstrapnode {
    # Have we been bootstrapped, yet?
    if $::percona_db_initially_restarted {
      # Node has been bootstrapped
      # - export ourself as clusternode
      @@::percona::stubs::clusternode { $::fqdn:
        ip  => $node_address,
        tag => "percona-cluster-${wsrep_cluster_name}",
      }
    } else {
      # Node has not been bootstrapped, yet.
      # - do nothing if the cluster has already been started once
      # - export ourself as bootstrapnode
      # - start the percona service in bootstrap mode
      # - set fact to prevent automatic restarts in the future
      if percona_cluster_nodecount("percona-cluster-${wsrep_cluster_name}") == 0 {
        @@::percona::stubs::bootstrapnode { $::fqdn:
          ip  => $node_address,
          tag => "percona-bootstrap-${wsrep_cluster_name}",
        }

        service { $::percona::mysql_service_name:
          ensure  => running,
          enable  => false,
          start   => $::percona::bootstrap_start_cmd,
          require => Class['::percona::package'],
        }

        if defined(Class['::percona::prepare_db']) {
          Service <| title == $::percona::mysql_service_name |> {
            require +> Class['::percona::prepare_db'],
          }
        }
      }

      # Is the mysql service running and the fact percona_wsrep_cluster_size avaliable?
      if $::percona_wsrep_cluster_size != undef {
        # If the required node count is online, let's exit bootstrap mode
        if $::percona_wsrep_cluster_size >= $min_nodes_required {

          exec { "${name}-mysqld_restart_to_exit_bootstrap_mode":
            path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
            command => $::percona::bootstrap_stop_cmd,
            onlyif  => 'test ! -z "$(pgrep -f wsrep-new-cluster)"',
          }

          ->
          file { "${name}-percona_db_initially_restarted":
            ensure  => file,
            path    => '/etc/facter/facts.d/percona_db_initially_restarted.txt',
            content => 'percona_db_initially_restarted=true',
          }
        }
      }
    }
  } else {
    # Not on the bootstrap host: start service once only if the master is available in bootstrap mode
    $bootstrap_node_ip = percona_bootstrapnode_ip("percona-bootstrap-${wsrep_cluster_name}")

    # This collector is functionally not necessary, we just add it for visibility
    Percona::Stubs::Bootstrapnode <<| tag == "percona-bootstrap-${wsrep_cluster_name}" |>>

    if $bootstrap_node_ip {
      if $::percona_db_initially_started {
        # Node has already been started automatically
        # - export ourself as clusternode
        @@::percona::stubs::clusternode { $::fqdn:
          ip  => $node_address,
          tag => "percona-cluster-${wsrep_cluster_name}",
        }
      } else {
        # Node has never been startet automatically
        # - check connectivity
        # - start service
        # - set fact to prevent automatic starts in the future
        percona_conn_validator { 'bootstrap-node' :
          server => $bootstrap_node_ip,
          port   => '4567', # Connect on the port for group communication to make sure percona is running with galera
        }

        service { $::percona::mysql_service_name:
          ensure  => running,
          enable  => false,
          require => Percona_conn_validator['bootstrap-node'],
        }
        ->
        file { "${name}-percona_db_initially_started":
          ensure  => file,
          path    => '/etc/facter/facts.d/percona_db_initially_started.txt',
          content => 'percona_db_initially_started=true',
        }
      }
    }
  }
}
