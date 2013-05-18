class PictureLocation < ActiveRecord::Base
  attr_accessible :location, :owner, :title
  has_one :picture
  
  def self.setup
    unless @setup_done      
      validates :owner, :presence => true
      validates :location, :presence => true
      validates :title, :presence => true
      
      self.table_name = "PictureLocations"
      connection.create_table 'PictureLocations', :force => true do |t|
        t.string :title
        t.string :owner
        t.string :location
        t.timestamps
      end if !connection.table_exists?('PictureLocations')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.table_name
    'PictureLocations'
  end
  
  def self.schema
    {'title' => 'string',
     'owner' => 'string',
     'location' => 'string'
     }
  end
  
  def self.insert(values)
    self.new(values).save
  end

  setup  
end