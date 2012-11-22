class Picture < ActiveRecord::Base
  attr_accessible :title, :image
  has_attached_file :image,
    :storage => :database, 
    :styles => {
    	:thumb => "150x150>",
    	:small => "300x300>"
    },
    :url => '/:class/:id/:attachment?style=:style'
  default_scope select_without_file_columns_for(:image)  
  
end
