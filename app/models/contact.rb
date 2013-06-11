class Contact < AbstractDatabase
  # #has_many :pictures, :dependent => :destroy
   
  
  def self.setup
    unless @setup_done
      attr_accessible :username
      # This describes where the contact can be found. This might be how to
      # contact it directly or might be an index location such as the sigmod
      # peer. For now this should be an ip:port combination.
      attr_accessible :peerlocation
      attr_accessible :online
      attr_accessible :email
      attr_accessible :facebook
      
      validates :username, :presence => true, :uniqueness => true
      validates :peerlocation, :presence => true
      
      connection.create_table 'contacts', :force => true do |t|
        t.string :username
        t.string :peerlocation
        t.boolean :online
        t.string :email
        t.string :facebook
        t.timestamps
      end if !connection.table_exists?('contacts')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.schema
    {'username' => 'string',
      'peerlocation' => 'string',
      'online' => 'boolean',
      'email' => 'string',
      'facebook' => 'string'}
  end

  include WrapperHelper::ActiveRecordWrapper

  setup
end