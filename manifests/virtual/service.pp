# == Class percona::virtual:service
#
class percona::virtual::service {

  @service { $percona::mysql_service_name: }

}
