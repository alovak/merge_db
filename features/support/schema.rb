class Schema < ActiveRecord::Migration
  def self.define(&block)
    schema = new
    schema.verbose = false
    schema.instance_eval(&block)
  end
end

