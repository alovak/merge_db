Feature: Background
  In order to migrate from multiple databases to single database in my application
  As a developer
  I want to merge all databases

  Scenario:
    Given a file named "temp/schema.rb" with:
      """
      ActiveRecord::Schema.define do
        create_table "users" do |t|
          t.integer  "id"
          t.string   "name"
          t.integer  "group_id"
          t.datetime "created_at"
          t.datetime "updated_at"
        end

        create_table "groups", :force => true do |t|
          t.integer  "id"
          t.string   "name"
          t.datetime "created_at"
          t.datetime "updated_at"
        end
      end
      """
    And a database named "db_source" with "schema.rb"
    And a database named "db_target" with "schema.rb"
    # And the following fields in "db_destination.users"
      # | name     | type     |
      # | id       | integer  |
      # | name     | string   |
      # | group_id | integer  |
    # And the following fields in "db_destination.group"
      # | name     | type     |
      # | id       | integer  |
      # | name     | string   |
    # Given a database named "db_one"
    # And a table "users" in "db_one" with:
      # | id | name  | group_id |
      # | 1  | John  | 1        |
      # | 2  | Marry | 2        |
    # And a table "groups" in "db_one" with:
      # | id | name   |бк
      # | 1  | First  |
      # | 2  | Second |
    # Given a database named "db_two"
    # And a table "users" in "db_two" with:
      # | id | name  | group_id |
      # | 1  | Piter | 1        |
      # | 2  | James | 2        |
      # | 2  | Bill  | 3        |
    # And a table "groups" in "db_two" with:
      # | id | name   |
      # | 1  | One    |
      # | 2  | Two    |
      # | 3  | Three    |
    # When I run `merge_db db_one db_two -in db_merged`
    # And I use "db_merged"
    # Then 5 users should exist
    # And  5 groups should exist
    # And the following users should exist:
      # | name  | group(name) | origin(name) |
      # | John  | First      | db_one        |
      # | Marry | Second     | db_one        |
      # | Piter | One        | db_two        |
      # | James | Two        | db_two        |
      # | Bill  | Three      | db_two        |
    # And the following groups should exist:
      # | name   | origin(name) |
      # | First  | db_one       |
      # | Second | db_one       |
      # | One    | db_two       |
      # | Two    | db_two       |
      # | Three  | db_two       |
