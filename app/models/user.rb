#The user class which defines the machine on which the user is.
#
class User < AbstractDatabase
  
  def self.setup
    unless @setup_done
      self.table_name = "users"
      connection.create_table 'users', :force => true do |t|
        t.string :username
        t.string :email
        t.string :crypted_password
        t.string :password_salt
        t.string :persistence_token
        t.timestamps
      end if !connection.table_exists?('users')      
      @setup_done = true
    end
  end
  
  def default_values
    self.username ||= ENV['USERNAME']
  end
  
  def self.schema
    {'username' => 'string',
      'email' => 'string',
      'crypted_password' => 'string',
      'password_salt' => 'string',
      'persistence_token' => 'string'
    }
  end
  
  #Try to put class action at the end
  setup
  before_validation :default_values
  acts_as_authentic do |c|
    # optional block for Authlogic
  end
end