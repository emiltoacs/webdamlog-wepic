require 'wl_tool'

class Delegation < AbstractDatabase
  attr_accessible :wdlrule, :wdl_rule_id, :accepted
  
  def self.setup
    unless @setup_done
      validates :wdlrule, :presence => true, :wl => true
      validates :wdlrule, :presence => true
            
      self.table_name = "Delegation"
      connection.create_table 'Delegation', :force => true do |t|
        t.text :wdlrule
        t.boolean :accepted
        t.integer :wdl_rule_id, :limit => 8
        t.timestamps
      end if !connection.table_exists?('Delegation')
      
      @setup_done = true
    end
  end
  
  def self.table_name
    'Delegation'
  end

  # schema used by wdl
  def self.schema
    {
      'wdlrule' => 'text',
      'accepted' => 'boolean',
      'wdl_rule_id' => 'integer'
    }
  end
  
  def default_values
    self.accepted = false unless self.accepted
  end
  
  setup  
  
  
  
  before_validation :default_values
  
end