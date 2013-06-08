class AdminController < ApplicationController
  # before_filter :require_no_admin, :only => [:new, :create]
  # before_filter :require_admin, :only => [:show, :edit, :update]
  
  def index
    @users = User.all
    @pictures = Picture.all
  end
  
  def new
    @admin = Admin.new
  end
  
  def create
    @admin = Admin.new(params[:admin])
    @users = User.all
    @pictures = Picture.all
    if @admin.save
      flash[:notice] = "Account registered!"
      render :action => :index
    else
      render :action => :new
    end
  end
  
  def show
    @admin = @current_admin
  end

  def edit
    @admin = @current_admin
  end
  
  def update
    @admin = @current_admin # makes our views "cleaner" and more consistent
    if @admin.update_attributes(params[:admin])
      flash[:notice] = "Account updated!"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end  
end
