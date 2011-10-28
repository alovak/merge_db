module MergeDb
  class Configuration
    class << self
      attr_accessor :scope_name, :scoped_tables

      def scoped_tables
        @scoped_tables || []
      end

      def database
        require 'erb'
        YAML::load(ERB.new(IO.read('./config/database.yml')).result)
      end
    end
  end
end
