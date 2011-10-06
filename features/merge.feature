Feature: Background
  In order to migrate from multiple databases to single database in my application
  As a developer
  I want to merge all databases

  Scenario:
    Given a database named "db_one"
    And a table "users" in "db_one" with:
      | id | name  | group_id |
      | 1  | John  | 1        |
      | 2  | Marry | 2        |
    And a table "groups" in "db_one" with:
      | id | name   |
      | 1  | First  |
      | 2  | Second |
    Given a database named "db_two"
    And a table "users" in "db_two" with:
      | id | name  | group_id |
      | 1  | Piter | 1        |
      | 2  | James | 2        |
      | 2  | Bill  | 3        |
    And a table "groups" in "db_two" with:
      | id | name   |
      | 1  | One    |
      | 2  | Two    |
      | 3  | Three    |
    And a database named "db_merged"
    When I run `merge_db`
    Then 5 users should exist
    And  5 groups should exist
    And the following users should exist:
      | name  | group name | origin |
      | John  | First      | db_one |
      | Marry | Second     | db_one |
      | Piter | One        | db_two |
      | James | Two        | db_two |
      | Bill  | Three      | db_two |
