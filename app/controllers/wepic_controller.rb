class WepicController < ApplicationController
  include WLDatabase
  
  def index    
    @picture = Picture.new
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @pictures = @relation_classes['Picture'].all unless @relation_classes['Picture'].nil?    
    @contacts = @relation_classes['Contact'].all unless @relation_classes['Contact'].nil?
    unless @relation_classes['PictureLocation'].nil?
      @picturelocations = @relation_classes['PictureLocation'].all
      @picturelocation = Hash.new
      @pictures.each do |picture|
        @picturelocation["#{picture.title}@#{picture.owner}"] = find_location(picture)
      end
    end  
  end
  
  #This method assumes a relation called location exists with fields title, owner and place.
  def find_location(picture)
    unless @picturelocations.nil?
      @picturelocations.each do |picturelocation|
        if picture.title==picturelocation.title and picture.owner==picturelocation.owner
          return picturelocation
        end
      end
      nil
    else
      nil
    end
  end  
end