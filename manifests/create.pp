# == Class percona::create
#
class percona::create {

  if $percona::db_galera {

    if $percona::is_arbitrator {
      anchor {"${name}::begin_arbitrator":}   ->
      class { 'percona::create_arbitrator': } ->
      anchor {"${name}::end_arbitrator":}
    } else {

      ## Should fail if system memory is smaller or equal then reserved memory + 128 (MB)
      if $percona::reserved_os_memory and str2bool(inline_template('<%= scope.lookupvar("percona::memorysize_mb").to_i <= scope.lookupvar("percona::reserved_os_memory").to_i + 128 ? true : false %>')) {
        fail('Reserved OS Memory is to high, please adjust!')
      }
  
      anchor {"${name}::begin":}        ->
      class  {'percona::create_node': } ->
      class  {'percona::monitor': }     ->
      anchor {"${name}::end":}

      Service <| title == "${name}-${percona::mysql_service_name}" |> {
        enable => false,
      }
    }
  } else {
    anchor {"${name}::begin":}              ->
    class  {'percona::create_standalone': } ->
    anchor {"${name}::end":}

    Service <| title == "${name}-${percona::mysql_service_name}" |> {
      enable => true,
    }
  }

}
