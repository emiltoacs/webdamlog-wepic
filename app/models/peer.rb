class Peer < ActiveRecord::Base
  
  def self.setup
    unless @setup_done
      db_name = "db/database_#{ENV['USERNAME']}.db"
      @configuration = {:adapter => 'sqlite3', :database => db_name}
      establish_connection @configuration
      attr_accessible :ip, :port, :username
      attr_accessible :active
      validates :username, :format => { :with => /\A[a-zA-Z]+\z/,
                                        :message => "Only letters allowed (between 5 and 20)",
                                        :length => {:minimum => 5, :maximum => 20} }
      self.table_name = "peers"
      connection.create_table 'peers', :force => true do |t|
        t.string :username
        t.string :ip
        t.integer :port
        t.boolean :active
        t.timestamps
      end if !connection.table_exists?('peers')      
      @setup_done = true
    end
  end  
  
  setup
end
