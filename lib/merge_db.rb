require "rubygems"
require "bundler/setup"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record'
# require 'ruby-debug'
require 'logger'

require 'merge_db/configuration'
require 'merge_db/merger'

ActiveRecord::Base.logger = Logger.new('log.txt')

module MergeDb
end

require "./config/merge.rb"
