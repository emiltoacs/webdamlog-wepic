class Admin < AbstractDatabase
  # attr_accessible :title, :body
  
  def self.setup
    unless @setup_done
      self.table_name = "admins"
      connection.create_table 'admins', :force => true do |t|
        t.string    :login,               :null => false                # optional, you can use email instead, or both
        t.string    :crypted_password,    :null => false                # optional, see below
        t.string    :password_salt,       :null => false                # optional, but highly recommended
        t.string    :persistence_token,   :null => false                # required
        t.timestamps
      end if !connection.table_exists?('admins')      
      @setup_done = true
    end
  end
  
  setup
  acts_as_authentic do |c|
    
  end
end
