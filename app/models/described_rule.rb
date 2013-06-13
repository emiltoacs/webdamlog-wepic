require 'wl_tool'

class DescribedRule < AbstractDatabase
  attr_accessible :description, :wdlrule, :role
  
  def self.setup
    unless @setup_done
      validates :wdlrule, :presence => true, :wl => true
      validates :role, :presence => true
      validates_inclusion_of :role, :in => ['query','update']
            
      self.table_name = "describedRule"
      connection.create_table 'describedRule', :force => true do |t|
        t.text :description
        t.text :wdlrule
        t.string :role
        t.timestamps
      end if !connection.table_exists?('describedRule')
      
      @setup_done = true
    end 
  end
  
  def self.table_name
    'describedRule'
  end
  
  def default_values
    self.description = "No description" unless self.description
  end

  # schema used by wdl
  def self.schema
    {'wdlrule' => 'text',
     'description' => 'text'
     }
  end
  
  setup  
  
  before_validation :default_values
  
end