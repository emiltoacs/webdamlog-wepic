class WepicController < ApplicationController
  include WLDatabase
  helper_method :find_picture_field
  
  def index    
    @picture = Picture.new
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @pictures = @relation_classes['Picture'].all unless @relation_classes['Picture'].nil?    
    @contacts = @relation_classes['Contact'].all unless @relation_classes['Contact'].nil?  
  end
  
  #This method could be enhanced to make sure caching is used.
  def find_picture_field(picture, classname,field=:all)
    unless @relation_classes[classname].nil?
      unless field==:all
        tuple = @relation_classes[classname].where(:title => picture.title, :owner => picture.owner)
        if tuple.first then tuple.first[field] else nil end
      else
        @relation_classes[classname].where(:title => picture.title, :owner => picture.owner)
      end
    else
      nil
    end
  end
end