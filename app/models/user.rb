require 'yaml'
require 'app/helpers/wl_database'

class User < ActiveRecord::Base
  include Database
  create_or_connect_db(ENV['USERNAME'])
  db_name = "#{Rails.env}_#{ENV['USERNAME']}"
  configuration = YAML::load(File.open(File.join(Rails.root,'config/database.yml')))[Rails.env]
  configuration['database']=db_name  
  establish_connection configuration
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
end