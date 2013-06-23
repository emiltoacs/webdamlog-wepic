require 'open-uri'
class Picture < AbstractDatabase  
  @storage = :database
  attr_accessor :created
  attr_accessor :downloaded
  
  def self.setup
    unless @setup_done
      attr_accessible :title, :owner, :image, :_id, :date, :image_url, :url
      validates :title, :presence => true
      validates :owner, :presence => true
      after_save :define_url, :on => :create
      before_validation :default_values, :on => :create
      before_validation :download_image, :if => :should_download?, :on => :create
      connection.create_table 'pictures', :force => true do |t|
        t.integer :_id
        t.string :title
        t.string :url
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
  },
   :url => '/:class/:id/:attachment.:extension?style=:style'
  
  if @storage==:database
    default_scope select_without_file_columns_for(:image)
  end
  
  def default_values
    self._id = rand(0xFFFFFF) unless self._id
    self.date = DateTime.now unless self.date
    #You shoul have only one of these three fields not nil on create.
    if self.url
      #Image was created at bootstrap or comes from a foreign peer through webdamlog
      self.image_url = self.url
    elsif self.image_url
      #Image was uploaded from url
    elsif self.image
      #Image was uploaded from file
    else
      WLLogger.logger.error "One of [url,image_url,image] should not be nil on create!"
    end
    WLLogger.logger.debug "Default values for picture #{self._id} added!"
    return true
  end
  
  def define_url
    if !self.created and self.url.blank?
      config = Conf.peer['peer']
      self.update_column(:url,"#{config['protocol']}://#{config['ip']}:#{config['web_port']}#{self.image.url}")
      self.created = true
      if Conf.env['USERNAME']!='manager'
        save(:no_skip) #This will add the record to webdamlog
      end
    end
  end
  
  # private
  
  def url_provided_remote?
    uri = URI.parse(self.image_url)
    return ((uri.is_a?(URI::HTTP) || uri.is_a?(URI::FTP) || uri.is_a?(URI::HTTPS)) and uri.host!='localhost')
  end
  
  def url_provided_local?
    uri = URI.parse(self.image_url)
    uri.host=='localhost'
  end
  
  def should_download?
    !self.image_url.blank?
  end
  
  def download_image
    unless self.downloaded #Don't want to download more than once!
        if url_provided_remote?
          self.image = do_download_remote_image
        elsif url_provided_local?
          self.image = get_local_image
        else
          # #Do nothing
        end
      self.downloaded=true
    end
  end
  
  def get_local_image
    io = open(image_url)
  rescue => import_error
    WLLogger.logger.error "Could not download file : #{import_error.message}"
  end
  
  def do_download_remote_image
    io = open(URI.parse(image_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue => import_error
    WLLogger.logger.error "Could not download file : #{import_error.message}" # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  
  unless Conf.env['USERNAME'].downcase == 'manager'
    include WrapperHelper::ActiveRecordWrapper
    include WrapperHelper::PictureWrapper
    bind_wdl_relation
  end
end