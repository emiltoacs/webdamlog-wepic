class WepicController < ApplicationController
  include WLDatabase
  
  def index    
    @picture = Picture.new
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @pictures = @relation_classes['Picture'].all unless @relation_classes['Picture'].nil?    
    @contacts = @relation_classes['Contact'].all unless @relation_classes['Contact'].nil?
    unless @relation_classes['ImageLocation'].nil?
      @imagelocations = @relation_classes['ImageLocation'].all
      @imagelocation = Hash.new
      @pictures.each do |picture|
        @imagelocation["#{picture.title}@#{picture.owner}"] = find_location(picture)
      end
    end  
  end
  
  #This method assumes a relation called location exists with fields title, owner and place.
  def find_location(picture)
    unless @imagelocations.nil?
      @imagelocations.each do |imagelocation|
        if picture.title==imagelocation.title and picture.owner==imagelocation.owner
          return imagelocation
        end
      end
      nil
    else
      nil
    end
  end  
end