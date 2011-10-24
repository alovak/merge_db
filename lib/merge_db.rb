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

  class Merger

    def initialize(params)
      source = params[:source]
      target = params[:target]

      Source.establish_connection(Configuration.database[source]) if source
      Target.establish_connection(Configuration.database[target]) if target
    end

    def prepare
      prepare_tables_in_target
    end

    def merge
      copy_data_from_source_to_target
      restore_association_references
    end

    private

    def prepare_tables_in_target
      Target.connection.tables.each do |table|
        Target.connection.columns(table).each do |column|
          if column.name =~ /id$/
            Target.connection.add_column(table, backup_column_name(column.name), column.type)  
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

    def restore_association_references
      Target.connection.tables.each do |table|
        query = "select * from #{table}"

        updated_columns = Hash.new {|hash, key| hash[key] = [] }

        Target.connection.select_all(query).each do |record|
          record.each do |column, value|
            if column =~ /__id$/ && !value.nil? && !updated_columns[column].include?(value)
              
              association = find_association_by_old_id(column, value)
              
              # remember restored column ids
              updated_columns[column] << value

              # restore association references
              update_query = "update #{table} set #{normalize_column_name(column)} = #{association["id"]} where #{column} = #{value}"
              Target.connection.update(update_query)
            end
          end
        end

        # clean values in updated columns
        unless updated_columns.empty?
          columns_with_null = updated_columns.keys.collect {|column| "#{column} = NULL"}.join(", ")
          query = "update #{table} set #{columns_with_null}"
          Target.connection.execute(query)
        end
      end
    end

    def find_association_by_old_id(column, value)
      association_table = column.split("__").first.pluralize
      query = "select * from #{association_table} where _id = #{value}"
      association = Target.connection.select_one(query)
    end

    def prepare_for_merge(fixture)
      {}.tap do |new_fixture|
        fixture.each do |key, value|
          new_fixture[backup_column_name(key)] = value
        end
      end
    end

    def backup_column_name(name)
      if name =~ /id$/
        name = name.gsub(/id$/, "_id")
      else
        name
      end
    end

    def normalize_column_name(name)
      name.gsub(/__id$/, '_id')
    end
  end
end
