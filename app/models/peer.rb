class Peer < ActiveRecord::Base
  
  def self.setup
    unless @setup_done
      establish_connection DBConf.init
      attr_accessible :ip, :port, :username, :protocol
      attr_accessible :active
      validates :username, :format => { :with => /\A[a-zA-Z]+\z/,
                                        :message => "Only letters allowed (between 5 and 20)",
                                        :length => {:minimum => 5, :maximum => 20} }
      self.table_name = "peers"
      connection.create_table 'peers', :force => true do |t|
        t.string :username
        t.string :ip
        t.integer :port
        t.string :protocol
        t.boolean :active
        t.timestamps
      end if !connection.table_exists?('peers')      
      @setup_done = true
    end
  end

  def self.schema
    {'username'=>'string',
      'ip'=>'string',
      'port'=>'string',
      'protocol'=>'string',
      'active'=>'integer'
    }
  end
  
  setup
end
