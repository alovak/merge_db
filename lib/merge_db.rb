require "rubygems"
require "bundler/setup"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record'
require 'logger'
require 'progressbar'

require 'merge_db/configuration'

begin
  require './config/merge'
rescue LoadError
  puts <<-XML

  Warning!!!

  Please, create ./config/merge.rb file with the following content:

    MergeDb::Configuration.scope_name = 'studio' #singular name of table
    MergeDb::Configuration.scoped_tables = %w(users groups) #tables that should be scoped
  XML
  exit 1
end

require 'merge_db/merger'

ActiveRecord::Base.logger = Logger.new('log.txt')

module MergeDb
end

