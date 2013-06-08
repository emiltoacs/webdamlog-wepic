class AdminSessionsController < ApplicationController
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => :destroy
  
  def index
    @admin_session = AdminSession.new
  end
  
  def new
    @admin_session = AdminSession.new
    puts @admin_session
  end
  
  def create
    @admin_session = AdminSession.new(params[:admin_session])
    if @admin_session.save
      flash[:notice] = "Login successful!"
      redirect_to '/'
    else
      render :action => :new
    end
  end
  
  def destroy
    current_admin_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to '/'
  end
end