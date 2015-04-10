#percona

[![Build Status](https://img.shields.io/travis/FILIADATAGmbH/puppet-percona/master.svg)](https://travis-ci.org/FILIADATAGmbH/puppet-percona)
[![By FILIADATA](https://img.shields.io/badge/by-filiadata-fb7047.svg)](https://www.dm.de/de_homepage/arbeiten-und-lernen/arbeiten_bei_uns/arbeiten_bei_filiadata/)

####Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)

##Overview

This module installs and configures a Percona XtraDB Cluster.

##Usage

For Percona XtraDB Cluster with exported resource support

```puppet
  class {'percona':
    db_galera              => true,
    exported_resource      => true,
    reserved_os_memory     => 128,
    wsrep_cluster_name     => 'percona_test',
    wsrep_sst_method       => 'xtrabackup-v2',
    wsrep_sst_username     => 'sst',
    wsrep_sst_password     => 'sst_pw',
    mysql_admin_user       => 'mroot',
    mysql_admin_password   => 'mroot_pw',
    mysql_monitor_user     => 'mmonitor',
    mysql_monitor_password => 'mmonitor_pw',
  }
```

For Percona Garbd with exported resource support

```puppet
  class {'percona':
    db_galera              => true,
    is_arbitrator          => true,
    exported_resource      => true,
    wsrep_cluster_name     => 'percona_test',
  }
```

For Percona XtraDB Server (Standalone) with exported resource support

```puppet
  class {'percona':
    reserved_os_memory     => 128,
    mysql_admin_user       => 'mroot',
    mysql_admin_password   => 'mroot_pw',
  }
```

Set additional parameter in my.cnf config

```puppet
  mysql_config {'server-id':
    value => 16,
  )
  mysql_config {'master-host':
    value => '10.55.3.1',
  )
```
