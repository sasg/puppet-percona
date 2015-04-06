# == Define percona::wsrep_config
#
define percona::wsrep_config (
  $value = undef,
) {

  datacat_fragment { "${name}-${percona::wsrep_config_file}_fragment":
    target => $percona::wsrep_config_file,
    data   => {
      config_wsrep_additional => [ $name, $value ],
    },
  }

}
