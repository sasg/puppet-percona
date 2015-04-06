# == Define percona::mysql_query
#
define percona::mysql_query (
  $client_auth = false,
  $query = undef,
  $onlyif = undef,
) {

  if ( $client_auth == true) {
    $client_auth_option = '--defaults-file=/etc/my.cnf.d/client/admin_auth.cnf'
  } else {
    $client_auth_option = '' # lint:ignore:empty_string_assignment
  }

  if ( ! $onlyif ) {
    $exec_onlyif = $onlyif
  } else {
    $exec_onlyif = '/bin/true'
  }

  if ( ! $query ) {
    exec { "${name}-query":
      path      => ['/usr/bin','/bin',],
      command   => "mysql ${client_auth_option} -e \"${query}\"",
      logoutput => 'on_failure',
      onlyif    => $exec_onlyif,
    }
  }
}
