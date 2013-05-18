class Rating < ActiveRecord::Base
  attr_accessible :owner, :rating, :title
  def self.setup
    unless @setup_done      
      validates :owner, :presence => true
      validates :rating, :presence => true
      validates_numericality_of :rating, :less_than_or_equal_to => 5
      validates_numericality_of :rating, :greater_than_or_equal_to => 0
      validates :title, :presence => true
      
      self.table_name = "ratings"
      connection.create_table 'ratings', :force => true do |t|
        t.string :title
        t.string :owner
        t.integer :rating
        t.timestamps
      end if !connection.table_exists?('ratings')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.table_name
    'ratings'
  end
  
  def self.schema
    {'title' => 'string',
     'owner' => 'string',
     'rating' => 'integer'
     }
  end
  
  def self.insert(values)
    self.new(values).save
  end

  setup  
end
