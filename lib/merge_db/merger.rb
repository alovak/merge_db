module MergeDb
  class Source < ActiveRecord::Base
  end

  class Target < ActiveRecord::Base
  end

  class Merger

    def initialize(params)
      @source_name = params[:source]
      @target_name = params[:target]

      Source.establish_connection(Configuration.database[@source_name]) if @source_name
      Target.establish_connection(Configuration.database[@target_name]) if @target_name
    end

    def prepare
      prepare_tables_in_target
    end

    def merge
      add_db_to_scope
      copy_data_from_source_to_target
      restore_association_references
      clean_backedup_primary_keys
    end

    private

    def target
      Target.connection
    end

    def source
      Source.connection
    end

    def add_db_to_scope
      @scope_id = target.insert("insert into #{Configuration.scope_name.pluralize} (db_name) values ('#{@source_name}')")
    end

    def clean_backedup_primary_keys
      source.tables.each do |table|
        query = "update #{table} set _id = NULL"

        target.execute(query)
      end
    end

    def prepare_tables_in_target
      target.tables.each do |table|
        target.columns(table).each do |column|
          add_backup_id_column(table, column) if column.name =~ /id$/
        end

        add_scope_id_column(table) if Configuration.scoped_tables.include? table
      end
    end

    def add_backup_id_column(table, column)
      target.add_column(table, backup_column_name(column.name), column.type)  
    end

    def add_scope_id_column(table)
      target.add_column(table, scope_id_column, :integer)  
    end

    def scope_id_column
      Configuration.scope_name + "_id"
    end

    def copy_data_from_source_to_target
      source.tables.each do |table|
        query = "select * from #{table}"

        source.select_all(query).each do |fixture|
          fixture_with_saved_ids = prepare_for_merge(fixture)
          fixture_with_saved_ids[scope_id_column] = @scope_id if Configuration.scoped_tables.include? table
          target.insert_fixture(fixture_with_saved_ids, table)
        end
      end
    end

    def restore_association_references
      target.tables.each do |table|
        query = "select * from #{table}"

        updated_columns = Hash.new {|hash, key| hash[key] = [] }

        target.select_all(query).each do |record|
          record.each do |column, value|

            if column =~ /__id$/ && !value.nil? && !updated_columns[column].include?(value)
              
              association = find_association_by_old_id(column, value)
              
              # remember restored column ids
              updated_columns[column] << value

              # restore association references
              update_query = "update #{table} set #{normalize_column_name(column)} = #{association["id"]} where #{column} = #{value}"
              target.update(update_query)
            end
          end
        end

        # clean values in updated columns
        unless updated_columns.empty?
          columns_with_null = updated_columns.keys.collect {|column| "#{column} = NULL"}.join(", ")
          query = "update #{table} set #{columns_with_null}"
          target.execute(query)
        end
      end
    end

    def find_association_by_old_id(column, value)
      association_table = column.split("__").first.pluralize
      query = "select * from #{association_table} where _id = #{value}"
      association = target.select_one(query)
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

