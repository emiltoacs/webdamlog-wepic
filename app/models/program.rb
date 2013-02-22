class Program < AbstractDatabase
  def self.setup
    unless @setup_done
      self.table_name = 'programs'
      connection.create_table 'programs', :force => true do |t|
        t.string :name
        t.text :data
        t.string :source
        t.timestamps
      end if !connection.table_exists?('programs')  
      @setup_done = true
    end
  end
  
  #This method returns a schema to be used in the WLSchema table
  #to comply with the standards of that table. This should represent
  #a hash of the attributes of this record.
  #
  def self.schema
    {'name' => 'string',
      'data' => 'string',
      'source' => 'string'
    }
  end
  
  setup
  attr_accessible :name, :data, :source
  validates_uniqueness_of :name
end
