require 'wl_tool'

class DescribedRule < AbstractDatabase
  attr_accessible :description, :wdlrule, :role, :wdl_rule_id
  
  def self.setup
    unless @setup_done
      validates :wdlrule, :presence => true, :wl => true
      validates :role, :presence => true
      validates_inclusion_of :role, :in => ['extensional','intentional','rule', 'unknown']
            
      self.table_name = "describedRule"
      connection.create_table 'describedRule', :force => true do |t|
        t.text :description
        t.text :wdlrule
        t.string :role
        t.integer :wdl_rule_id, :limit => 8
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
    { 'description' => 'text',
      'wdlrule' => 'text',
      'role' => 'text',
      'wdl_rule_id' => 'integer'
    }
  end
  
  setup  
  
  before_validation :default_values
  if EngineHelper::WLENGINE
    include WrapperHelper::ActiveRecordWrapper
    include WrapperHelper::RuleWrapper
    bind_wdl_relation
  end
end