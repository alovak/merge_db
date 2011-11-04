module MergeDb
  class Source < ActiveRecord::Base
  end

  class Target < ActiveRecord::Base
  end

  class Merger

    def initialize(params)
      @source_name = params[:source]
      @target_name = params[:target]
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

    def restore_associations
      restore_association_references
      clean_backedup_primary_keys
    end

    private

    def prepare_tables_in_target
      puts "Prepare target"

      pbar = ProgressBar.new("tables", target.tables.size)

      target.tables.each do |table|

        pbar.inc

        add_scope_id_column(table) if Configuration.scoped_tables.include? table

        target.columns(table)
        .find_all {|column| column.name =~ /id$/}
        .each do |column|
          add_backup_id_column(table, column)
        end
      end

      pbar.finish
    end

    def add_db_to_scope
      @scope_id = target.insert("insert into #{Configuration.scope_name.pluralize} (db_name) values ('#{@source_name}')")
    end

    def copy_data_from_source_to_target
      puts "Copy data into target"

      source.tables.each do |table|
        puts "\nCopy #{table} records "
        query = "select * from #{table}"

        records = source.select_all(query)

        pbar = ProgressBar.new("#{table}", records.size)

        records.each do |fixture|

          pbar.inc

          fixture_with_saved_ids = prepare_for_merge(fixture)

          if Configuration.scoped_tables.include? table
            fixture_with_saved_ids[scope_id_column] = @scope_id
          end

          target.insert_fixture(fixture_with_saved_ids, table)
        end

        pbar.finish
      end
    end

    def restore_association_references
      puts "Restore association references"

      target.tables.each do |table|
        query = "select * from #{table}"

        restored_columns = Hash.new {|hash, key| hash[key] = [] }

        records = target.select_all(query)

        pbar = ProgressBar.new("#{table}", records.size)

        records.each do |record|
          pbar.inc
          record.each do |column, old_id|
            if column =~ /__id$/ && !old_id.nil? && !restored_columns[column].include?(old_id)

              restored_columns[column] << old_id

              if association = find_association_by_old_id(column, old_id)

                new_id = association["id"]

                update_query = "update #{table} set #{normalize_column_name(column)} = #{new_id} where #{column} = #{old_id}"
                target.update(update_query)
              else
                ActiveRecord::Base.logger.error "Can't find #{column} with old id: #{old_id}"
              end
            end
          end
        end

        pbar.finish

        unless restored_columns.empty?
          columns_with_null = restored_columns.keys.collect {|column| "#{column} = NULL"}.join(", ")
          query = "update #{table} set #{columns_with_null}"
          target.execute(query)
        end
      end
    end

    def clean_backedup_primary_keys
      source.tables.each do |table|
        query = "update #{table} set _id = NULL"

        target.execute(query)
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

    def target
      @target_connection ||= connect(Target, @target_name)
    end

    def source
      @source_connection ||= connect(Source, @source_name)
    end

    def connect(constant, db_name)
      if db_name
        constant.establish_connection(Configuration.database[db_name])
        constant.connection
      end
    end
  end
end

