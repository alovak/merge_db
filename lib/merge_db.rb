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

  class << self
    def merge(source, target)
      Source.establish_connection(Configuration.database[source])
      Target.establish_connection(Configuration.database[target])

      prepare_tables_in_target
      copy_data_from_source_to_target
      update_association_ids

      puts "Databases were merged."
    end

    private

    def prepare_tables_in_target
      Target.connection.tables.each do |table|
        Target.connection.columns(table).each do |column|
          if column.name =~ /id$/
            Target.connection.add_column(table, new_column_name(column.name), column.type)  
          end
        end
      end
    end

    def copy_data_from_source_to_target
      Source.connection.tables.each do |table|
        query = "select * from #{table}"

        Source.connection.select_all(query).each do |fixture|
          fixture_with_saved_ids = prepare_for_merge(fixture)
          Target.connection.insert_fixture(fixture_with_saved_ids, table)
        end
      end
    end

    def update_association_ids
      # Update references
      # for each table go through __id columns
      # find __id of the association
      # get id
      # set association_id
    end

    def prepare_for_merge(fixture)
      {}.tap do |new_fixture|
        fixture.each do |key, value|
          next if key == "id"

          new_fixture[new_column_name(key)] = value
        end
      end
    end

    def new_column_name(name)
      if name =~ /id$/
        name = name.gsub(/id$/, "_id")
      else
        name
      end
    end
  end
end
