require 'spec_helper'

describe 'percona', :type => :class do
  context 'on a RedHat OS' do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
        :memorysize_mb          => '1024',
      }
    end
    it { should compile.with_all_deps }
    it { is_expected.to contain_class("percona::package") }
    it { is_expected.to contain_class("percona::create") }

    context 'with galera' do
      let :params do
        { :db_galera => true }
      end
      it { should contain_package('nc') }
      it { should contain_package('pv') }
      it { should contain_package('socat') }

      context 'without arbitor' do
        let :params do
          { :db_galera => true,
            :is_arbitrator => false }
        end
        it { should contain_package('xinetd') }
      end

      context 'with low memory' do
        let :facts do
          {
            :id                     => 'root',
            :kernel                 => 'Linux',
            :osfamily               => 'RedHat',
            :operatingsystem        => 'RedHat',
            :operatingsystemrelease => '6',
            :concat_basedir         => '/dne',
            :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            :is_pe                  => false,
            :memorysize_mb => '128'
          }
        end
        it { should_not compile }
      end
    end
  end
  context 'with unsupported osfamily' do
    let :facts do
      { :osfamily        => 'Darwin',
        :operatingsystemrelease => '13.1.0',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end

    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, /Unsupported osfamily Darwin/)
    end
  end
end
