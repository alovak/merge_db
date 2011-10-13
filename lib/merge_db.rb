require "rubygems"
require "bundler/setup"

require 'active_record'
require 'ruby-debug'
require 'logger'

ActiveRecord::Base.logger = Logger.new('./log/log.txt')

module MergeDb
  class Configuration
    def self.database
      require 'erb'
      YAML::load(ERB.new(IO.read('./config/database.yml')).result)
    end
  end

  class Source < ActiveRecord::Base
  end

  class Target < ActiveRecord::Base
  end

  def self.merge(source, target)
    Source.establish_connection(Configuration.database[source])
    Target.establish_connection(Configuration.database[target])

    Source.connection.tables.each do |table|
      query = "select * from #{table}"

      Source.connection.select_all(query).each do |fixture|
        fixture.delete("id")
        Target.connection.insert_fixture(fixture, table)
      end
    end

    puts "Databases were merged."
  end
end
