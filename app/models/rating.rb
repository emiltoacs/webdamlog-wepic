#TODO Need to modify the rating model : ratings are not unique => add owner field to rating
#Have several ratings per picture.
class Rating < AbstractDatabase
  attr_accessible :_id, :rating, :owner
  before_validation :default_values
  # belongs_to :picture
  
  def self.setup
    unless @setup_done      
      validates :_id, :presence => true
      validates :rating, :presence => true
      validates :owner, :presence => true
      validates_numericality_of :rating, :less_than_or_equal_to => 5
      validates_numericality_of :rating, :greater_than_or_equal_to => 0
      
      self.table_name = "ratings"
      connection.create_table 'ratings', :force => true do |t|
        t.integer :_id
        t.string :owner
        t.integer :rating
        # t.integer :picture_id
        t.timestamps
      end if !connection.table_exists?('ratings')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.table_name
    'ratings'
  end
  
  def default_values
    self._id = rand(0xFFFFFF) unless self._id
  end
  
  def self.schema
    {'_id' => 'integer',
      'owner' => 'string',
     'rating' => 'integer'
     }
  end
  
  setup  
end
