class Comment < AbstractDatabase
  attr_accessible :author, :text, :_id, :date
  
  def self.setup
    unless @setup_done      
      validates :_id, :presence => true
      validates :text, :presence => true
      validates :author, :presence => true
      
      self.table_name = "comments"
      connection.create_table 'comments', :force => true do |t|
        t.integer :_id
        t.datetime :date
        t.string :author
        t.text :text
        t.timestamps
      end if !connection.table_exists?('comments')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def default_values
    self.date = DateTime.now
  end
  
  before_validation :default_values
  
  def self.table_name
    'comments'
  end
  
  def self.schema
    {'author' => 'string',
     '_id' => 'integer',
     'text' => 'string',
     'date' => 'datetime'
     }
  end
  setup
  include WrapperHelper::ActiveRecordWrapper
  bind_wdl_relation    
end
