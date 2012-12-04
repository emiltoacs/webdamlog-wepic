class User < ActiveRecord::Base
  db_name = "db/database_#{ENV['USERNAME']}.db"
  establish_connection :adapter => 'sqlite3', :database => db_name
  self.table_name = "users"
  puts "Users table exists : #{connection.table_exists?('users').inspect}"
  connection.create_table 'users', :force => true do |t|
    t.string :username
    t.string :email
    t.string :crypted_password
    t.string :password_salt
    t.string :persistence_token
    t.timestamps
  end if !connection.table_exists?('users')
  acts_as_authentic do |c|
    c.logged_in_timeout = 10.minutes # default is 10.minutes
  end
end