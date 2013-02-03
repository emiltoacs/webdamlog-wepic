#This is a dummy contact active record, the final result should be generated in WL.
class Contact < ActiveRecord::Base
  
  def self.setup
    unless @setup_done
      db_name = "db/database_#{ENV['USERNAME']}.db"
      @configuration = {:adapter => 'sqlite3', :database => db_name}
      establish_connection @configuration
      attr_accessible :username
      #This describes where the contact is to be found. This might be how to contact it directly
      #or might be an index location such as the sigmod peer. For now this should be a ip:port combination.
      attr_accessible :peerlocation
      attr_accessible :email
      attr_accessible :facebook
      validates :username, :presence => true, :uniqueness => true
      validates :peerlocation, :presence => true
      self.table_name = "contacts"
      connection.create_table 'contacts', :force => true do |t|
        t.string :username
        t.string :peerlocation
        t.string :email
        t.string :facebook
        t.timestamps
      end if !connection.table_exists?('contacts')      
      @setup_done = true
    end
  end  
  
  setup
end
