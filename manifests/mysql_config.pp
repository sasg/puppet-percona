# == Define percona::mysql_config
#
define percona::mysql_config (
  $value = undef,
  $area  = 'mysqld',
) {


  ## defining hash keys with any expression does not work
  ## quoting keys because of: https://tickets.puppetlabs.com/browse/PUP-2523
  $data = {
    "${area}" => {
      "${name}" => $value,
    },
  }

  datacat_fragment { "${name}-${percona::mysql_config_file}_fragment":
    target => $percona::mysql_config_file,
    data   => $data,
  }
}
