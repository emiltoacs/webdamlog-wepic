require 'wl_logger'
class Picture < ActiveRecord::Base
  
  def self.setup
    unless @setup_done
      db_name = "db/database_#{ENV['USERNAME']}.db"
      @configuration = {:adapter => 'sqlite3', :database => db_name}
      establish_connection @configuration
      attr_accessible :title, :image, :owner
      validates_uniqueness_of :title
      validates :owner, :presence => true
      self.table_name = 'pictures'
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
      'image_thumb_file'=>'binary'
    }
  end

  def self.open_connection
    establish_connection @configuration
  end

  def self.remove_connection
    super
  end
  
  setup
  has_attached_file :image,
    :storage => :database, 
    :styles => {
    :thumb => "150x150>",
    :small => "300x300>"
  },
    :url => '/:class/:id/:attachment?style=:style'
  default_scope select_without_file_columns_for(:image)
  
end
