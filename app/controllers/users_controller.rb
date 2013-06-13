class UsersController < ApplicationController
  include WLDatabase
  
  def list
    @users = User.all
    respond_to do |format|
      format.html
      format.json { render :json => @users }
    end
  end

  # GET /users
  # GET /users.json
  def index
    WLLogger.logger.debug "Session Resetted..." if reset_session
    @user = User.new
    @users = User.all
    @user_session = UserSession.new
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    flash[:notice] = params.inspect
    begin
      WLDatabase.setup_database_server
      if @user.save        
        EngineHelper::WLHELPER.run
        # When user is created, he is automatically logged in, which means we
        # need to start his Webdamlog session.
        respond_to do |format|          
          format.html { redirect_to(:wepic, :notice => "Registration successfull") }
          format.xml { render :xml => @user, :status => :created, :location => @user }
        end
      else
        WLLogger::WLLogger.logger.debug "#{@user.errors.messages.inspect}"
        respond_to do |format| 
          format.html { render :action => "new" , :alert => @user.errors.messages.inspect}
          format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
      
    rescue => error
      flash[:alert] = error.message
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml { render :xml => {setup: error.message}, :status => :unprocessable_entity}
      end
    end # rescue => error
  end # create

# PUT /users/1
# PUT /users/1.json
def update
  @user = User.find(params[:id])

  respond_to do |format|
    if @user.update_attributes(params[:user])
      format.html { redirect_to @user, :notice => 'User was successfully updated.' }
      format.json { head :no_content }
    else
      format.html { render :action => "edit" }
      format.json { render :json => @user.errors, :status => :unprocessable_entity }
    end
  end
end

# DELETE /users/1
# DELETE /users/1.json
def destroy
  @user = User.find(params[:id])
  @user.destroy

  respond_to do |format|
    format.html { redirect_to :admin }
    format.json { head :no_content }
  end
end
end
