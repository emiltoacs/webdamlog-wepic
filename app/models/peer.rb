class Peer < AbstractDatabase
  
  def self.setup
    unless @setup_done
      attr_accessible :ip, :port, :username, :protocol, :pid, :msg
      attr_accessible :active
      validates :username, :format => { :with => /\A[a-zA-Z]+\z/,
                                        :message => "Only letters allowed (between 5 and 30)",
                                        :length => {:minimum => 5, :maximum => 30} }
      self.table_name = "peers"
      connection.create_table 'peers', :force => true do |t|
        t.string :username
        t.string :ip
        t.integer :port
        t.string :protocol
        t.integer :pid
        t.string :msg
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
