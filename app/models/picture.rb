require 'wl_logger'
class Picture < ActiveRecord::Base
  db_name = "db/database_#{ENV['USERNAME']}.db"  
  establish_connection :adapter => 'sqlite3', :database => db_name  
  attr_accessible :title, :image
  validates_uniqueness_of :title#,:image_file_name
  self.table_name = 'Pictures'
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
  default_scope select_without_file_columns_for(:image)  
  
end
