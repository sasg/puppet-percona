#
# percona_bootstrapnode_ip.rb
#
#
module Puppet::Parser::Functions
  newfunction(:percona_bootstrapnode_ip, :type => :rvalue, :arity => 1, :doc => <<-EOS
    Querys puppetdb and searches for a percona cluster member in bootstrap mode
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "percona_bootstrapnode_ip(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1

      res_filter = [
        'and',
        ['=', 'type', 'Percona::Stubs::Bootstrapnode'],
        ['=', 'exported', true],
        ['=', 'tag', arguments[0]],
      ]

      qry_res = self.function_query_resources([false, res_filter])

      if qry_res.size > 0
        raise(Puppet::ParseError, "percona_bootstrapnode_ip(): Found #{qry_res.size} percona nodes in bootstrap mode for tag '#{arguments[0]}', expected only one.") if qry_res.size > 1

        if qry_res.is_a?(Hash)
          qry_res = qry_res.values[0][0]['parameters']
        else
          qry_res = qry_res[0]['parameters']
        end

        raise(Puppet::ParseError, "percona_bootstrapnode_ip(): Can not find parameter ip.") unless qry_res.has_key?('ip')

        return qry_res['ip']

      end
      return nil
  end
end
