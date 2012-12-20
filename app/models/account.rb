class Account < ActiveRecord::Base
  include Database
  attr_accessible :ip, :port, :username, :dbid
  attr_accessible :active
  validates_uniqueness_of :username, :dbid 
  self.table_name = "accounts"
  connection.create_table 'accounts', :force => true do |t|
      t.string :username
      t.string :dbid      
      t.string :ip
      t.integer :port
      t.boolean :active
      t.timestamps
  end if !connection.table_exists?('accounts')  
end
