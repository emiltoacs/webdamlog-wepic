require 'open-uri'

class Picture < AbstractDatabase
  
  @storage = :database
  
  def self.setup
    unless @setup_done
      connection.create_table 'pictures', :force => true do |t|
        t.integer :_id
        t.string :title
        t.string :owner
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
  
  attr_accessible :title, :image, :owner, :image_url, :_id
  validates :title, :presence => true
  validates :owner, :presence => true
  
  has_attached_file :image,
    :storage => @storage, 
    :styles => {
    :thumb => "150x150>",
    :small => "600x600>"
  },
    :url => '/:class/:id/:attachment.:extension?style=:style'
  
  if @storage==:database
    default_scope select_without_file_columns_for(:image)
  end
  
  # def initialize(args)
    # self._id = rand(0xFFFFFF)
    # super(args)
  # end
  
  def default_values
    self._id = rand(0xFFFFFF)
  end
  
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