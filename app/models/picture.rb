#TODO : Due to change in the rating model, need to change rated and rated= methods. 
require 'rest-open-uri'

class Picture < AbstractDatabase
  has_one :picture_location, :dependent => :destroy
  has_one :rating, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  
  attr_accessible :title, :image, :owner, :image_url, :_id, :date
  validates :title, :presence => true
  validates :owner, :presence => true  
  #validates :image_url, :presence => true
  
  @storage = :database
  
  def self.setup
    unless @setup_done
      connection.create_table 'pictures', :force => true do |t|
        t.integer :_id
        #t.integer  :contact_id
        t.string :title
        t.string :owner
        t.datetime :date
        t.string :image_file_name
        t.string :image_content_type
        t.integer :image_file_size
        t.datetime :image_updated_at
        t.binary :image_file
        t.binary :image_small_file
        t.binary :image_thumb_file
        t.string :image_url
        t.timestamps
      end if !connection.table_exists?('pictures')
      @setup_done = true
    end
  end
  
  setup
  
  def self.schema
    { '_id' => 'integer',
      'title'=>'string',
      'owner'=>'string',
      'image_file_name'=>'string',
      'image_content_type'=>'string',
      'image_file_size'=>'integer',
      'image_updated_at'=>'datetime',
      'image_file'=>'binary',
      'image_small_file'=>'binary',
      'image_thumb_file'=>'binary',
      'image_url' => 'string'
    }
  end
  
  def rated
    return self.rating.rating if self.rating && self.rating.rating
    0
  end
  
  def rated=(rating)
    self.rating.rating = rating
    self.rating.save
    WLLogger.logger.debug "Rating for picture #{self._id} : #{rated}"
  end
  
  def located
    return self.picture_location.location if self.picture_location && self.picture_location.location
    "unknown"
  end
  
  def dated
    self.date
  end
  
  def dated=(date)
    self.date = date
    self.save
    WLLogger.logger.debug "Date for picture #{self._id} : #{dated}"
  end
  
  def titled
    self.title
  end
  
  def titled=(title)
    self.title = title
    self.save
    WLLogger.logger.debug "Title for picture #{self._id} : #{titled}"
  end
  
  def located=(location)
    self.picture_location.location = location
    self.picture_location.save
    WLLogger.logger.debug "Location for picture #{self._id} : #{located}"
  end
  
  has_attached_file :image,
    :storage => @storage, 
    :styles => {
    :thumb => "206x206!",
    :small => "500x500>"
  },
    :url => '/:class/:id/:attachment.:extension?style=:style'
  
  if @storage==:database
    default_scope select_without_file_columns_for(:image)
  end
  
  def default_values
    self._id = rand(0xFFFFFF) unless self._id
    self.date = DateTime.now unless self.date
  end
  
  def create_defaults
    create_rating(:_id => self._id, :rating => 0)
    create_picture_location(:_id => self._id, :location => "unknown")
    self.image_url = self.image_file_name unless self.image_url
  end
  
  before_create :create_defaults
  before_validation :default_values
  before_validation :download_image, :if => :image_url_provided?
  
     
  private
  
  def url_provided_remote?
    uri = URI.parse(self.image_url)
    return uri.is_a?(URI::HTTP) || uri.is_a?(URI::FTP) || uri.is_a?(URI::HTTPS)
  end
  
  def url_provided_local?
    URI.parse(self.image_url).instance_of?(URI::Generic) 
  end
  
  def image_url_provided?
    !self.image_url.blank?
  end
  
  def download_image
    #self.image = do_download_remote_image
    if url_provided_remote?
      self.image = do_download_remote_image
    elsif url_provided_local?
      self.image = get_local_image
    else
      #Do nothing
    end
  end
  
  def get_local_image
  io = File.new(URI.parse(image_url).path)
  rescue
  end
  
  def do_download_remote_image
    io = open(URI.parse(image_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
end