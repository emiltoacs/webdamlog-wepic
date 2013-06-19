require 'open-uri'
class Picture < AbstractDatabase  
  @storage = :database
  
  def self.setup
    unless @setup_done
      attr_accessible :title, :image, :owner, :image, :_id, :date, :image_url
      validates :title, :presence => true
      validates :owner, :presence => true
      before_create :create_defaults
      before_validation :default_values
      before_validation :download_image, :if => :image_url_provided?
      connection.create_table 'pictures', :force => true do |t|
        t.integer :_id
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
    rated = 0
    count = Rating.where(:_id => self._id).each {|rating| rated+=rating.rating}.size
    if count > 0 
      rated/count
    else
      0
    end
  end

  def located
    picture = PictureLocation.where(:_id => self._id)
    if picture then picture.first else "unknown" end
  end

  def dated
    self.date
  end

  def titled
    self.title
  end
  
  has_attached_file :image,
    :storage => @storage, 
    :styles => {
    :thumb => "206x206#",
    :small => "500x500>"
  },#, :conver_options => {
   # :thumb => "-gravity Center -crop 206x206"
  #},
   :url => '/:class/:id/:attachment.:extension?style=:style'
  
  if @storage==:database
    default_scope select_without_file_columns_for(:image)
  end
  
  def default_values
    # puts caller.join("\n")[0..20]
    self._id = rand(0xFFFFFF) unless self._id
    self.date = DateTime.now unless self.date
  end
  
  def create_defaults
    # #TODO replace by better thing #self.image_url = self.image_file_name
    # unless self.image_url    
  end
  
  # private
  
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
    if url_provided_remote?
      self.image = do_download_remote_image
    elsif url_provided_local?
      self.image = get_local_image
    else
      # #Do nothing or 
      self.image = do_download_remote_image
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