After do
  created_databases.each do |db_name|
    connection.drop_database db_name
  end
end
