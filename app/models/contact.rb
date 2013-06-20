class Contact < AbstractDatabase 
  
  def self.setup
    unless @setup_done
      attr_accessible :username
      attr_accessible :ip
      attr_accessible :port
      attr_accessible :online
      attr_accessible :email
      
      validates :username, :presence => true, :uniqueness => true
      validates :ip, :presence => true
      validates :port, :presence => true
      
      connection.create_table 'contacts', :force => true do |t|
        t.string :username
        t.string :ip
        t.integer :port
        t.boolean :online
        t.string :email
        t.timestamps
      end if !connection.table_exists?('contacts')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup

  # map the webdamlog schema
  def self.schema
    {'username' => 'string',
      'ip' => 'integer',
      'port' => 'integer',
      'online' => 'boolean',
      'email' => 'string'}
  end
  
  setup
  unless Conf.env['USERNAME'].downcase == 'manager'
    include WrapperHelper::ActiveRecordWrapper
    include WrapperHelper::ContactWrapper
    bind_wdl_relation
  end
end