class WepicController < ApplicationController
  include WLDatabase
  def index
    debugger
    @picture = Picture.new
    #Picture.open_connection
    @pictures = Picture.all
    #Picture.remove_connection
    @relation_classes = database(ENV['USERNAME']).relation_classes
    #puts "WepicController#index:#{ENV['USERNAME']}"
    
    #FIXME check how to optimize database connections.
    #@relation_classes['Contacts'].open_connection
    @contacts = @relation_classes['Contacts'].all
    #@relation_classes['Contacts'].remove_connection
  end
end
