#
# percona_cluster_nodecount.rb
#
#
module Puppet::Parser::Functions
  newfunction(:percona_cluster_nodecount, :type => :rvalue, :arity => 1, :doc => <<-EOS
    Querys puppetdb and searches for percona cluster members that match the tag given as first parameter, returns the count
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "percona_cluster_nodecount(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1

      res_filter = [
        'and',
        ['=', 'type', 'Percona::Stubs::Clusternode'],
        ['=', 'exported', true],
        ['=', 'tag', arguments[0]],
      ]

      qry_res = self.function_query_resources([false, res_filter])

      qry_res.size
  end
end
