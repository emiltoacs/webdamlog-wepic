require 'wl_tool'

class Peer < AbstractDatabase
  
  def self.setup
    unless @setup_done
      attr_accessible :ip, :port, :username, :protocol, :pid, :msg
      attr_accessible :active
      validates :username, :format => { :with => /\A[a-zA-Z_]+\z/,
        :message => "Only letters or underscore _ allowed (between 5 and 30)",
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

  # Check if a process is launched for this peer
  def refresh_active_field
    old= @active
    if WLTool.pid_exists?(pid)
      cmd = %x( pgrep -lf #{pid} )
      if cmd.include?('rails') and cmd.include?('sigmod')
        @active= true
      else
        @active=false
      end
    else
      @active=false
    end
    if old != @active
      logger.debug "update active status of #{username} to #{@active}"
      save
    end
  end
  
  setup
end
