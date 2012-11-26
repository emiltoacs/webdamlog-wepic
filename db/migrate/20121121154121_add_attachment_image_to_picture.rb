class AddAttachmentImageToPicture < ActiveRecord::Migration
  
  def change
    change_table :pictures do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.binary :image_file
      t.binary :image_small_file
      t.binary :image_thumb_file
    end
  end  
end
