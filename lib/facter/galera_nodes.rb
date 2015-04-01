require 'facter'

## It's used to control the DB preparation
if File.exists?('/prepare_db')
  Facter.add('prepare_db') do
    setcode do
      true
     end
  end
end
