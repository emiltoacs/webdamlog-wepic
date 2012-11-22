class AdminController < ApplicationController
  
  def index
    @users = User.all
    @pictures = Picture.all
  end
end
