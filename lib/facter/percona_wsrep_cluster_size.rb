Facter.add("percona_wsrep_cluster_size") do
  setcode do
    if File.file?("#{Facter.value(:root_home)}/.my.cnf")
      status = Facter::Util::Resolution.exec('pgrep -f mysqld')
      if ! status.empty?
        Facter::Util::Resolution.exec('mysql -nNE -e "SHOW STATUS LIKE \'wsrep_cluster_size\';" | tail -1')
      else
        nil
      end
    end
  end
end
