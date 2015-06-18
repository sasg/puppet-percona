Puppet::Type.newtype(:percona_conn_validator) do

  @doc = "Verify that a connection can be successfully established between a node
  and the Percona instance. It could potentially be used for other
  purposes such as monitoring."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:server) do
    desc 'DNS name or IP address of the server where the Percona instance should be running.'
    defaultto 'localhost'
  end

  newparam(:port) do
    desc 'The port that the Percona instance should be listening on.'
    defaultto 3306
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up and deciding that the Percona instance is not running; defaults to 60 seconds.'
    defaultto 60
    validate do |value|
      # This will raise an error if the string is not convertible to an integer
      Integer(value)
    end
    munge do |value|
      Integer(value)
    end
  end

end
