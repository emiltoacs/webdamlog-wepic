require 'wl_tool'

class Delegation < AbstractDatabase
  attr_accessible :peername, :timestamp, :accepted, :wdlrule
  
  def self.setup
    unless @setup_done
      validates :peername, :presence => true
      validates :timestamp, :presence => true
      validates :wdlrule, :presence => true
            
      self.table_name = "Delegation"
      connection.create_table 'Delegation', :force => true do |t|
        t.text :peername
        t.integer :timestamp
        t.boolean :accepted
        t.text :wdlrule
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
    return true
  end
  
  setup  
  
  before_validation :default_values
  

  # wedamlog link
  def self.refresh_delegations
    new_delegations = EngineHelper::WLENGINE.flush_delegations
    new_delegations.each { |peer, value| value.each { |tmst, value| value.each { |rules| rules.each { |rule|
          self.new(:peername => peer.to_s, :timestamp => tmst, :wdlrule => rule).save }}}}
  end
end