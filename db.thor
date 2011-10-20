$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'merge_db'

class Db < Thor
  desc "merge", "merge two databases"
  method_option :source, :aliases => "-s", :required => true, :desc => "Records will be copied from this database"
  method_option :target, :aliases => "-t", :required => true, :desc => "Records will be inserted into this database"

  def merge
    source = options[:source]
    target = options[:target]

    MergeDb::Merger.new(source, target).merge
  end
end
