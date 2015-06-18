# == Class: percona
#
# A Puppet module for providing a Percona XtraDB Cluster or Percona XtraDB Server (Standalone)
# Currently VERY limited - assumes Redhat setup.
#
# === Requirement/Dependencies:
#
# Currently requires the richardc/datacat and puppetlabs/stdlib module on the Puppet Forge and
# uses storeconfigs on the Puppet Master to export/collect resources
# from all node members.
#
# === Parameters
#
# [*mysql_cnf*]
#   A Hash of config variables for my.cnf
#
# [*wsrep_cnf*]
#   A Hash of config variables for wsrep.cnf
#
# [*exported_resource*]
#   (only for XtraDB Cluster)
#   If set to true members will be exported and collected. Otherwise if false, you have to specify nodes via parameter node_list.
#
# [*node_list*]
#   (only for XtraDB Cluster)
#   Node list (IPV4 addresses comma separated) of all galera members. incl. garb if used
#
# [*db_galera*]
#   If set to true, Percona XtraDB Cluster will be installed and configured. Otherwise Percona XtraDB Server (Standalone)
#
# [*reserved_os_memory*]
#   A possibility to reserve extra OS memory which will not be calculate for buffer_pool size inside my.cnf
#
# [*is_arbitrator*]
#   If set to true a Garb will be installed and configured.
#
#[*percona_version*]
#   e.g. 56 for Percona Releases 5.6
#
#[*mysql_admin_user*]
#   The main user with all permission to administer the database server
#
#[*mysql_admin_password*]
#   The main user password
#
#[*mysql_monitor_user*]
#   (only for XtraDB Cluster)
#   A monitor user for the active checks which listen on port 9223
#
#[*mysql_monitor_password*]
#   The monitor user password
#
#[*wsrep_cluster_options*]
#   to add wsrep options to gcomm string
#
#[*automatic_bootstrap*]
#   to bootstrap a galera cluster automagically
#
#[*bootstrapnode*]
#   are we the node that should be started with bootstrap-pxc
#
# === Examples
#
#  ## For Percona XtraDB Cluster with exported resource support
#  class { '::percona':
#    db_galera              => true,
#    exported_resource      => true,
#    reserved_os_memory     => 128,
#    wsrep_cnf              => {
#      mysqld => {
#        wsrep_cluster_name => 'percona_test',
#        wsrep_sst_method   => 'xtrabackup-v2',
#        wsrep_sst_auth     => 'sst_user:78sdu4538',
#        wsrep_node_name    => "${::hostname}_${::ipaddress_eth1}",
#        wsrep_node_address => $::ipaddress_eth1,
#      },
#    },
#    mysql_admin_user       => 'mroot',
#    mysql_admin_password   => 'mroot_pw',
#    mysql_monitor_user     => 'mmonitor',
#    mysql_monitor_password => 'mmonitor_pw',
#  }
#
#
# ## For Percona Garbd with exported resource support
#  class { '::percona':
#    db_galera         => true,
#    is_arbitrator     => true,
#    exported_resource => true,
#    wsrep_cnf         => {
#      mysqld => {
#        wsrep_cluster_name => 'percona_test',
#      },
#    },
#  }
#
#
#  ## For Percona XtraDB Server (Standalone)
#  class { '::percona':
#    reserved_os_memory     => 128,
#    mysql_admin_user       => 'mroot',
#    mysql_admin_password   => 'mroot_pw',
#  }
#
#  ## Set additional parameter in my.cnf config
#  mysql_config { 'server-id':
#    value => 16,
#  }
#  mysql_config { 'master-host':
#    value => '10.55.3.1',
#  }
#
# === Authors
#
# FILIADATA GmbH <lx-github@dm.de>
#
# === Copyright
#
#
class percona (
  $mysql_cnf              = {},
  $wsrep_cnf              = {},
  $exported_resource      = $percona::params::exported_resource,
  $node_list              = $percona::params::node_list,

  $db_galera              = $percona::params::db_galera,

  ## Memory in MB
  $reserved_os_memory     = $percona::params::reserved_os_memory,

  $is_arbitrator          = $percona::params::is_arbitrator,

  $percona_version        = $percona::params::percona_version,

  $mysql_admin_user       = $percona::params::mysql_admin_user,
  $mysql_admin_password   = $percona::params::mysql_admin_password,

  $mysql_monitor_user     = $percona::params::mysql_monitor_user,
  $mysql_monitor_password = $percona::params::mysql_monitor_password,

  $wsrep_cluster_options  = $percona::params::wsrep_cluster_options,

  $automatic_bootstrap    = false,
  $bootstrapnode          = false,

) inherits percona::params {

  validate_hash($mysql_cnf)
  validate_hash($wsrep_cnf)
  validate_bool($exported_resource)
  validate_string($node_list)
  validate_bool($db_galera)
  validate_string($reserved_os_memory)
  validate_bool($is_arbitrator)
  validate_string($percona_version)
  validate_string($mysql_admin_user)
  validate_string($mysql_admin_password)
  validate_string($mysql_monitor_user)
  validate_string($mysql_monitor_password)

  ## Merge mysql_cnf and wsrep_cnf with the default values from params.pp
  ## And for datacat, we cannot use facts directly, therefore added hash elements with fact information
  $mysql_cnf_hash = deep_merge(
    $percona::params::mysql_cnf,
    $mysql_cnf, {
      reserved_os_memory => $reserved_os_memory,
      memorysize_mb      => $::memorysize_mb,
      processorcount     => $::processorcount,
    }
  )

  $wsrep_cnf_hash = deep_merge(
    $percona::params::wsrep_cnf,
    $wsrep_cnf, {
      processorcount        => $::processorcount,
      wsrep_cluster_options => $wsrep_cluster_options,
    }
  )

  $wsrep_cred = split($wsrep_cnf_hash['mysqld']['wsrep_sst_auth'], ':')
  $wsrep_sst_username = $wsrep_cred[0]
  $wsrep_sst_password = $wsrep_cred[1]

  $mysql_datadir   = $mysql_cnf_hash['mysqld']['datadir']
  $mysql_socket    = $mysql_cnf_hash['mysqld']['socket']
  $mysql_socketdir = dirname($mysql_cnf_hash['mysqld']['socket'])
  $mysql_tmpdir    = $mysql_cnf_hash['mysqld']['tmpdir']
  $mysql_logdir    = dirname($mysql_cnf_hash['mysqld']['log-error'])
  $mysql_binlogdir = dirname($mysql_cnf_hash['mysqld']['log-bin'])
  $mysql_piddir    = dirname($mysql_cnf_hash['mysqld']['pid-file'])

  anchor {"${name}::begin":}
  -> class  {"${name}::package":}
  -> class  {"${name}::create":}
  -> anchor {"${name}::end":}

}
