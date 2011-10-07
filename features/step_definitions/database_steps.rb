Given /^a schema:$/ do |string|
  Given 'a file named "temp/schema.rb" with:', string
end

Given /^a database named "([^"]*)" with schema$/ do |db_name|
  connection.drop_database db_name
  connection.create_database db_name

  created_databases << db_name

  connection.execute("use #{db_name}")

  schema = File.read("./tmp/aruba/temp/schema.rb")

  instance_eval schema
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

Then /^(\d+) users should exist$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^(\d+) groups should exist$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the following users should exist:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

Then /^the following groups should exist:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end
