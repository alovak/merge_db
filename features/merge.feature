Feature: Background
  In order to migrate from multiple databases to single database in my application
  As a developer
  I want to merge all databases

  Scenario:
    Given a schema "old.rb":
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
    Given a schema "new.rb":
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

        create_table "studios", :force => true do |t|
          t.integer  "id"
          t.string   "db_name"
        end
      end
      """
    Given a database named "db_first" with schema "old.rb"
    And a database named "db_second" with schema "old.rb"
    And a database named "db_third" with schema "old.rb"
    And a database named "db_target" with schema "new.rb"
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
    And a table "users" in "db_third" with:
      | id | name  | group_id |
      | 1  | Piter | 1        |
      | 2  | James | 2        |
      | 3  | Bill  | 3        |
    And a table "groups" in "db_third" with:
      | id | name  |
      | 1  | One   |
      | 2  | Two   |
      | 3  | Three |
    When I prepare "db_target"
    When I merge "db_first" into "db_target"
    And I merge "db_second" into "db_target"
    And I merge "db_third" into "db_target"
    # When I run in shell "thor db:merge -s db_source -t db_target"
    # Then I should see "Databases were merged."
    When I connected to "db_target"
    Then 9 users should exist
    And  7 groups should exist
    Then the following users should exist:
      | name  | groups.name | studios.db_name |
      | Piter | One         | db_third        |
      | James | Two         | db_third        |
      | Bill  | Three       | db_third        |
      | John  | First       | db_first        |
      | Marry | Second      | db_first        |
      | Jane  | Second      | db_first        |
      | Jeff  | First 2     | db_second       |
      | Frank | First 2     | db_second       |
      | Adam  | Second 2    | db_second       |

