class WepicController < ApplicationController
  include WLDatabase
  def index    
    @picture = Picture.new
    @pictures = Picture.all
    @relation_classes = database(UserConf.config[:name]).relation_classes
    
    @contacts = @relation_classes['Contact'].all
  end
end
