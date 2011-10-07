After do
  connection = ActiveRecord::Base.establish_connection(connection_params)

  created_databases.each do |db_name|
    connection.connection.drop_database db_name
  end
end
