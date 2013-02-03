class WepicController < ApplicationController
  include Database
  def index
    @picture = Picture.new
    @pictures = Picture.all
    @relation_classes = database(ENV['USERNAME']).relation_classes
    @contacts = @relation_classes['Contacts'].all
  end
end
