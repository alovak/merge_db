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
        end

        create_table "groups", :force => true do |t|
          t.integer  "id"
          t.string   "name"
        end
      end
      """
    And a database named "db_first" with schema
    And a database named "db_second" with schema
    And a database named "db_target" with schema
    And a table "users" in "db_first" with:
      | id | name  | group_id |
      | 1  | John  | 1        |
      | 2  | Marry | 2        |
      | 3  | Jane  | 2        |
    And a table "groups" in "db_first" with:
      | id | name   |
      | 1  | First  |
      | 2  | Second |
    And a table "users" in "db_second" with:
      | id | name  | group_id |
      | 1  | Jeff  | 1        |
      | 2  | Frank | 1        |
      | 3  | Adam  | 2        |
    And a table "groups" in "db_second" with:
      | id | name     |
      | 1  | First 2  |
      | 2  | Second 2 |
    And a table "users" in "db_target" with:
      | id | name  | group_id |
      | 1  | Piter | 1        |
      | 2  | James | 2        |
      | 3  | Bill  | 3        |
    And a table "groups" in "db_target" with:
      | id | name  |
      | 1  | One   |
      | 2  | Two   |
      | 3  | Three |
    When I prepare "db_target"
    When I merge "db_first" into "db_target"
    And I merge "db_second" into "db_target"
    # When I run in shell "thor db:merge -s db_source -t db_target"
    # Then I should see "Databases were merged."
    When I connected to "db_target"
    Then 9 users should exist
    And  7 groups should exist
    Then the following users should exist:
      | name  | groups.name |
      | Piter | One         |
      | James | Two         |
      | Bill  | Three       |
      | John  | First       |
      | Marry | Second      |
      | Jane  | Second      |
      | Jeff  | First 2     |
      | Frank | First 2     |
      | Adam  | Second 2    |
