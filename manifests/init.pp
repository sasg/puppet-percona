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
# [*exported_resource*]
#   (only for XtraDB Cluster)
#   If set to true members will be exported and collected. Otherwise if false, you have to specify nodes via parameter node_list.
#
# [*node_ip*]
#   The IP of the node itself
#
# [*node_list*]
#   (only for XtraDB Cluster)
#   The node list of all galera members. incl. garb if used
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
#[*wsrep_cluster_name*]
#  The clustername 
#
#[*wsrep_cluster_options*]
#   see description in template wsrep.cnf.erb
#
#[*wsrep_provider_options*]
#   see description in template wsrep.cnf.erb
#
#[*wsrep_node_name*]
#   see description in template wsrep.cnf.erb
#
#[*wsrep_sst_method*]
#   see description in template wsrep.cnf.erb
#
#[*wsrep_sst_username*]
#   see description in template wsrep.cnf.erb
#
#[*wsrep_sst_password*]
#   see description in template wsrep.cnf.erb
#
#[*garbd_options*]
#   see description in template wsrep.cnf.erb
#
#[*percona_version*]
#   see description in template wsrep.cnf.erb
#
#[*mysql_dbdir*]
#   root directory for mysql instance
#
#[*mysql_datadir*]
#
#[*mysql_dbdir*]
#
#[*mysql_socket*]
#
#[*mysql_tmpdir*]
#
#[*mysql_logdir*]
#
#[*mysql_binlogdir*]
#
#[*mysql_admin_user*]
#   The main user with all permission to administer the database
#
#[*mysql_admin_password*]
#
#[*mysql_monitor_user*]
#   (only for XtraDB Cluster)
#   A monitoring user for the active checks which listen on port 9223   
#
#[*mysql_monitor_password*]
#

# === Examples
#
#  ## For Percona XtraDB Cluster with exported resource support
#  class {'percona':
#    db_galera              => true,
#    exported_resource      => true,
#    reserved_os_memory     => 128,
#    wsrep_cluster_name     => 'percona_test',
#    wsrep_sst_method       => 'xtrabackup-v2',
#    wsrep_sst_username     => 'sst',
#    wsrep_sst_password     => 'sst_pw',
#    mysql_admin_user       => 'mroot',
#    mysql_admin_password   => 'mroot_pw',
#    mysql_monitor_user     => 'mmonitor',
#    mysql_monitor_password => 'mmonitor_pw',
#  }
#
#
# ## For Percona Garbd with exported resource support
#  class {'percona':
#    db_galera              => true,
#    is_arbitrator          => true,
#    exported_resource      => true,
#    wsrep_cluster_name     => 'percona_test',
#  }
#
#
#  ## For Percona XtraDB Server (Standalone) with exported resource support
#  class {'percona':
#    reserved_os_memory     => 128,
#    mysql_admin_user       => 'mroot',
#    mysql_admin_password   => 'mroot_pw',
#  }
#
#  ## Set additional parameter in my.cnf config
#  mysql_config {'server-id':
#    value => 16,
#  )
#  mysql_config {'master-host':
#    value => '10.55.3.1',
#  )
#
# === Authors
#
# FILIADATA GmbH <lx-github@dm.de>
#
# === Copyright
#
#
class percona (
  $exported_resource        = $percona::params::exported_resource,
  $node_ip                  = $percona::params::node_ip,
  $node_list                = $percona::params::node_list,

  $db_galera                = $percona::params::db_galera,

  ## Memory in MB
  $reserved_os_memory       = $percona::params::reserved_os_memory,

  $is_arbitrator            = $percona::params::is_arbitrator,
  $wsrep_cluster_name       = $percona::params::wsrep_cluster_name,
  $wsrep_cluster_options    = $percona::params::wsrep_cluster_options,
  $wsrep_provider_options   = $percona::params::wsrep_provider_options,
  $wsrep_node_name          = $percona::params::wsrep_node_name,
  $wsrep_sst_method         = $percona::params::wsrep_sst_method,
  $wsrep_sst_username       = $percona::params::wsrep_sst_username,
  $wsrep_sst_password       = $percona::params::wsrep_sst_password,

  $garbd_options            = $percona::params::wsrep_cluster_options,

  $percona_version          = $percona::params::percona_version,

  $mysql_dbdir              = "${percona::params::mysql_dbdir}/percona",
  $mysql_datadir            = "${percona::params::mysql_dbdir}/percona/${percona::params::mysql_datadir}",
  $mysql_socket             = "${percona::params::mysql_dbdir}/percona/${percona::params::mysql_socket}",
  $mysql_tmpdir             = "${percona::params::mysql_dbdir}/percona/${percona::params::mysql_tmpdir}",
  $mysql_logdir             = "${percona::params::mysql_dbdir}/percona/${percona::params::mysql_logdir}",
  $mysql_binlogdir          = "${percona::params::mysql_dbdir}/percona/${percona::params::mysql_binlogdir}",

  $mysql_admin_user         = $percona::params::mysql_admin_user,
  $mysql_admin_password     = $percona::params::mysql_admin_password,

  $mysql_monitor_user       = $percona::params::mysql_monitor_user,
  $mysql_monitor_password   = $percona::params::mysql_monitor_password,

) inherits percona::params {

  validate_bool($exported_resource)
  validate_string($node_ip)
  validate_string($node_list)
  validate_bool($db_galera)
  validate_string($reserved_os_memory)
  validate_bool($is_arbitrator)
  validate_string($wsrep_cluster_name)
  validate_string($wsrep_cluster_options)
  validate_string($wsrep_provider_options)
  validate_string($wsrep_node_name)
  validate_string($wsrep_sst_method)
  validate_string($wsrep_sst_username)
  validate_string($wsrep_sst_password)
  validate_string($garbd_options)
  validate_string($percona_version)
  validate_string($mysql_dbdir)
  validate_string($mysql_datadir)
  validate_string($mysql_socket)
  validate_string($mysql_tmpdir)
  validate_string($mysql_logdir)
  validate_string($mysql_binlogdir)
  validate_string($mysql_admin_user)
  validate_string($mysql_admin_password)
  validate_string($mysql_monitor_user)
  validate_string($mysql_monitor_password)

  anchor {"${name}::begin":}
  -> class  {"${name}::package":}
  -> class  {"${name}::create":}
  -> anchor {"${name}::end":}

}
