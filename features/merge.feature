Feature: Background
  In order to migrate from multiple databases to single database in my application
  As a developer
  I want to merge all databases

  Scenario:
    Given a schema:
      """
      Schema.define do
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
    And a database named "db_source" with schema
    And a database named "db_target" with schema
    And a table "users" in "db_source" with:
    | id | name  | group_id |
    | 1  | John       | 1        |
    | 2  | Marry      | 2        |
    And a table "groups" in "db_source" with:
    | id | name   |
    | 1  | First  |
    | 2  | Second |
    And a table "users" in "db_target" with:
    | id | name  | group_id |
    | 1  | Piter | 1        |
    | 2  | James | 2        |
    | 3  | Bill  | 3        |
    And a table "groups" in "db_target" with:
    | id | name   |
    | 1  | One    |
    | 2  | Two    |
    | 3  | Three    |
    When I run in shell "thor db:merge -s db_source -t db_target"
    Then I should see "Databases were merged."
    When I connected to "db_target"
    Then 5 users should exist
    And  5 groups should exist
    Then the following users exist:
    | name  | group(name) | origin(name) |
    | John  | First      | db_one        |
    | Marry | Second     | db_one        |
    | Piter | One        | db_two        |
    | James | Two        | db_two        |
    | Bill  | Three      | db_two        |
    And the following groups exist:
      | name   | origin(name) |
      | First  | db_one       |
      | Second | db_one       |
      | One    | db_two       |
      | Two    | db_two       |
      | Three  | db_two       |
