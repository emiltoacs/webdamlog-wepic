require 'wl_logger'
<<<<<<< HEAD
class Picture < ActiveRecord::Base 
  validates_uniqueness_of :title, :image
  attr_accessible :title, :image
  
  #The table is created in the database if it does not exist, since we use meta
  #programming information to create this table.
  #
=======
class Picture < ActiveRecord::Base
  db_name = "db/database_#{ENV['USERNAME']}.db"
  @configuration = {:adapter => 'sqlite3', :database => db_name}
  establish_connection @configuration
  attr_accessible :title, :image
  validates_uniqueness_of :title
>>>>>>> emilien
  self.table_name = 'Pictures'
  db_name = "db/database_#{ENV['USERNAME']}.db" 
  establish_connection :adapter => 'sqlite3', :database => db_name  
  connection.create_table 'Pictures', :force => true do |t|
    t.string :title
    t.string :image_file_name
    t.string :image_content_type
    t.integer :image_file_size
    t.datetime :image_updated_at
    t.binary :image_file
    t.binary :image_small_file
    t.binary :image_thumb_file
    t.timestamps
  end if !connection.table_exists?('Pictures')
  has_attached_file :image,
    :storage => :database, 
    :styles => {
    :thumb => "150x150>",
    :small => "300x300>"
  },
    :url => '/:class/:id/:attachment?style=:style'
<<<<<<< HEAD
  default_scope select_without_file_columns_for(:image)  
=======
  default_scope select_without_file_columns_for(:image)
  
  def self.schema
    {'title'=>'string',
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
>>>>>>> emilien
end
