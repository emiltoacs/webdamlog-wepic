class User < ActiveRecord::Base
  db_name = "db/database_#{ENV['USERNAME']}.db"
  establish_connection :adapter => 'sqlite3', :database => db_name
  self.table_name = "users"
  connection.create_table 'users', :force => true do |t|
    t.string :username
    t.string :email
    t.string :crypted_password
    t.string :password_salt
    t.string :persistence_token
    t.timestamps
  end if !connection.table_exists?('users')
  before_validation :default_values
  def default_values
    self.username ||= ENV['USERNAME']
  end  
  acts_as_authentic do |c|
    c.logged_in_timeout = 10.minutes # default is 10.minutes
  end
  def self.schema
    {'username' => 'string',
     'email' => 'string',
     'crypted_password' => 'string',
     'password_salt' => 'string',
     'persistence_token' => 'string'
    }
  end
  def self.open_connection
    establish_connection @configuration
  end
  def self.remove_connection
    super
  end  
end