require 'yaml'

#The class picture contains all the pictures.
#XXX Need to create custom classes for pictures in the database module.
# We have to find a way around the has_attached_file method. 
class Picture < ActiveRecord::Base
  attr_accessible :title, :image
  self.table_name = 'Pictures'
  connection.create_table 'Pictures', :force => true do |t|
    t.string :title
    t.string :image_file_name
    t.string :image_content_type
    t.integer :image_file_size
    t.datetime :image_updated_at
    #The use of LONGBLOB is required for mysql
    case connection.class
    when ActiveRecord::ConnectionAdapters::SQLite3Adapter
      t.binary :image_file
      t.binary :image_small_file
      t.binary :image_thumb_file
    when ActiveRecord::ConnectionAdapters::Mysql2Adapter
      execute "ALTER TABLE users ADD COLUMN #{:image_file} LONGBLOB"
      execute "ALTER TABLE users ADD COLUMN #{:image_small_file} LONGBLOB"
      execute "ALTER TABLE users ADD COLUMN #{:image_thumb_file} LONGBLOB"        
    end
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