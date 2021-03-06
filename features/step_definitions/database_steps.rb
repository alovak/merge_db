Given /^a schema "([^"]*)":$/ do |schema_name, string|
  Given %|a file named "temp/#{schema_name}" with:|, string
end

Given /^a database named "([^"]*)" with schema "([^"]*)"$/ do |db_name, schema_name|
  connection.drop_database db_name
  connection.create_database db_name

  created_databases << db_name

  connection.execute("use #{db_name}")

  schema = File.read("./tmp/aruba/temp/#{schema_name}")

  instance_eval schema
end

When /^I run in shell "([^"]*)"$/ do |command|
  @output = `#{command}`
end

When /^I prepare "([^"]*)"$/ do |target|
  MergeDb::Merger.new(:target => target).prepare
end

When /^I merge "([^"]*)" into "([^"]*)"$/ do |source, target|
  MergeDb::Merger.new(:source => source, :target => target).merge
end

Then /^I should see "([^"]*)"$/ do |str|
  @output.should include(str)
end

Then /^I should see the output$/ do
  puts @output
end

Given /^a table "([^"]*)" in "([^"]*)" with:$/ do |table_name, db_name, data|
  connection.execute("use #{db_name}")

  data.hashes.each do |fixture|
    connection.insert_fixture(fixture, table_name)
  end
end

When /^I use "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I connected to "([^"]*)"$/ do |db_name|
  connection.execute("use #{db_name}")
end

Then /^(\d+) (\w+)?s should exist$/ do |count, model_name|
  model = model_name.camelize.constantize
  model.count.should == count.to_i
end

Then /^the following (\w+)?s should exist:$/ do |model_name, table|
  model = model_name.camelize.constantize

  join_tables = table.column_names.collect { |name| name.split(".").first.singularize.to_sym if name =~ /\w+\.\w+/ }.delete_if(&:nil?)

  table.hashes.each do |attributes|
    model.joins(join_tables).where(attributes).should_not be_empty, "expected to find a record with attributes: #{attributes}"
  end
end

Then /^the following groups should exist:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

Then /debug/ do
  debugger
  a = 1
end
