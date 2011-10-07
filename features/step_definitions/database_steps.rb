Given /^a database named "([^"]*)"$/ do |db_name|
  ActiveRecord::Base.establish_connection(connection_params)
  ActiveRecord::Base.connection.create_database db_name

  created_databases << db_name
end

Given /^a table "([^"]*)" in "([^"]*)" with:$/ do |arg1, arg2, table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
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
