class Program < ActiveRecord::Base  
  def self.setup
    unless @setup_done
      db_name = "db/database_#{ENV['USERNAME']}.db"
      @configuration = UserConf.config[:connection]
      establish_connection DBConf.init
      self.table_name = 'programs'
      connection.create_table 'programs', :force => true do |t|
        t.string :name
        t.string :author
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
      'author' => 'string',
      'data' => 'string',
      'source' => 'string'
    }
  end
  
  setup
  attr_accessible :name, :author, :data, :source
  validates_uniqueness_of :name
end
