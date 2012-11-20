class AdminController < ApplicationController
  
  def index
    @users = Users.All
  end
end
