require 'wl_tool'

class DescribedRule < AbstractDatabase
  attr_accessible :description, :rule, :role
  
  def self.setup
    unless @setup_done      
      validates :description, :presence => false
      validates :rule, :presence => true, :wl => true
      validates :role, :presence => true
      validates_inclusion_of :role, :in => ['query','update']
            
      self.table_name = "describedRule"
      connection.create_table 'describedRule', :force => true do |t|
        t.text :description
        t.text :rule
        t.string :role
        t.timestamps
      end if !connection.table_exists?('describedRule')
      
      begin
        ContentHelper::query_create
      rescue => error
        WLLogger.logger.warn "Error occured : #{error.message}"
      end
      
      
      @setup_done = true
    end 
  end
  
  def self.table_name
    'describedRule'
  end
  
  def default_values
    self.description = "No description" unless self.description
  end
  
  def self.schema
    {'rule' => 'string',
     'description' => 'string'
     }
  end
  
  setup  
  
  before_validation :default_values
  
end