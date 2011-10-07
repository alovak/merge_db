$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'aruba/cucumber'
require 'active_record'
require 'ruby-debug'

module CustomData
  def connection_params
    {
      :adapter => 'mysql2',
      :host => 'localhost',
      :username => 'root',
      :password => '',
    }
  end

  def created_databases
    @databases ||= []
  end
end

World(CustomData)
