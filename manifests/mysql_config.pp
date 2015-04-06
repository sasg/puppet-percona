# == Define percona::mysql_config
#
define percona::mysql_config (
  $value = undef,
) {

  datacat_fragment { "${name}-${percona::mysql_config_file}_fragment":
    target => "${name}-${percona::mysql_config_file}",
    data   => {
      config_mysqld_additional => [ $name, $value ],
    },
  }

}
