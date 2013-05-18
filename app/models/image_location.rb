class ImageLocation < ActiveRecord::Base
  attr_accessible :location, :owner, :title
  def self.setup
    unless @setup_done      
      validates :owner, :presence => true
      validates :location, :presence => true
      validates :title, :presence => true
      
      self.table_name = "imagelcations"
      connection.create_table 'imagelocations', :force => true do |t|
        t.string :title
        t.string :owner
        t.string :location
        t.timestamps
      end if !connection.table_exists?('imagelocations')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.table_name
    'imagelocations'
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