class Rating < AbstractDatabase
  attr_accessible :_id, :rating
  belongs_to :picture
  
  def self.setup
    unless @setup_done      
      validates :_id, :presence => true
      validates :rating, :presence => true
      validates_numericality_of :rating, :less_than_or_equal_to => 5
      validates_numericality_of :rating, :greater_than_or_equal_to => 0
      
      self.table_name = "ratings"
      connection.create_table 'ratings', :force => true do |t|
        t.integer :_id
        t.integer :rating
        t.integer :picture_id
        t.timestamps
      end if !connection.table_exists?('ratings')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.table_name
    'ratings'
  end
  
  def self.schema
    {'_id' => 'integer',
     'rating' => 'integer'
     }
  end
  
  setup  
end
