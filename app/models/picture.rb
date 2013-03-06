require 'open-uri'

class Picture < AbstractDatabase
  
  def self.setup
    unless @setup_done
      attr_accessible :title, :image, :owner, :image_url
      validates_uniqueness_of :title
      has_attached_file :image,
        :storage => :database, 
        :styles => {
        :thumb => "150x150>",
        :small => "300x300>"
      },
        :url => '/:class/:id/:attachment?style=:style'
      default_scope select_without_file_columns_for(:image)
      before_validation :download_remote_image, :if => :image_url_provided?
      validates :owner, :presence => true
      connection.create_table 'pictures', :force => true do |t|
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
  
  def self.schema
    {'title'=>'string',
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
  
  setup
  
  private
  
  def image_url_provided?
    !self.image_url.blank?
  end
  
  def download_remote_image
    self.image = do_download_remote_image
  end
  
  def do_download_remote_image
    io = open(URI.parse(image_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
end