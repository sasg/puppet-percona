source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :test do
  gem "rspec", "~> 3.1.0"
  gem "rake"
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "ci_reporter_rspec"
  gem 'puppet-lint', '>= 1'
  gem 'puppet-lint-unquoted_string-check'
  gem 'puppet-lint-empty_string-check'
  gem 'puppet-lint-spaceship_operator_without_tag-check'
  gem 'puppet-lint-variable_contains_upcase'
  gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-undef_in_function-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-trailing_comma-check'
  gem 'puppet-lint-file_ensure-check'
end

if facterversion = ENV['FACTER_GEM_VERSION']
    gem 'facter', facterversion, :require => false
else
    gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion, :require => false
else
    gem 'puppet', :require => false
end

# vim:ft=ruby
