class WepicController < ApplicationController
  include WLDatabase
  
  def index    
    @picture = Picture.new
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @pictures = @relation_classes['Picture'].all unless @relation_classes['Picture'].nil?    
    @contacts = @relation_classes['Contact'].all unless @relation_classes['Contact'].nil?
    unless @relation_classes['Location'].nil?
      @locations = @relation_classes['Location'].all
      @location = Hash.new
      @pictures.each do |picture|
        @location[picture.title] = find_location(picture)
      end
    end  
  end
  
  #This method assumes a relation called location exists with fields title, owner and place.
  def find_location(picture)
    unless @locations.nil?
      @locations.each do |location|
        if picture.title==location.title and picture.owner==location.owner
          return location.place
        end
      end
    else
      nil
    end
  end  
end