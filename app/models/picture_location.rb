class PictureLocation < AbstractDatabase
  attr_accessible :location, :_id
  
  def self.setup
    unless @setup_done      
      validates :_id, :presence => true
      validates :location, :presence => true
      
      self.table_name = "pictureLocations"
      connection.create_table 'pictureLocations', :force => true do |t|
        t.integer :_id
        t.string :location
        t.timestamps
      end if !connection.table_exists?('pictureLocations')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.table_name
    'pictureLocations'
  end
  
  def self.schema
    {'_id' => 'integer',
     'location' => 'string'
     }
  end

  setup
  unless Conf.env['USERNAME'].downcase == 'manager'
    include WrapperHelper::ActiveRecordWrapper
    bind_wdl_relation
  end  
end