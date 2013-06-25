class UsersController < ApplicationController
  include WLDatabase
  
  def list
    @users = User.all
    respond_to do |format|
      format.html
      format.json { render :json => @users }
    end
  end

  # GET /users GET /users.json
  def index
    logger.debug "Session Resetted..." if reset_session
    @user = User.new
    @users = User.all
    @user_session = UserSession.new
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /users/1 GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new GET /users/new.json
  def new
    @user = User.new
    respond_to do |format|
      format.html
      format.json { render :json => @user }
    end
  end

  # POST /users POST /users.json
  def create
    @user = User.new(params[:user])
    flash[:notice] = params.inspect
    begin      
      if @user.save
        # all the big mechanics to load wdl
        @db = WLDatabase.setup_database_server #Should not setup database at each step.
        engine = EngineHelper::WLHELPER.run_engine
        #Create described rules
        #Load file for parsing for describedRules
        @collections = engine.bootstrap_collections
        @rules = engine.bootstrap_rules
        @rule_load_error = false
        @collections.each do |collection|
          saved, err = ContentHelper::add_to_described_rules(collection,'bootstrap','unknown',:skip_ar_wrapper)
          unless saved
            logger.error err
            @user.errors.add(:wdl,err)
            @rule_load_error = true
          end
        end
        @rules.each do |rule|
          saved, err = ContentHelper::add_to_described_rules(rule,'bootstrap','rule',:skip_ar_wrapper)
          unless saved
            logger.error err
            @user.errors.add(:wdl,err)
            @rule_load_error = true
          end
        end
        if engine.running_async
          engine.load_bootstrap_fact
          @db.save_facts_for_meta_data
          # TODO check if two previous are ok
          if @rule_load_error
            respond_to do |format|
              format.html { redirect_to(:wepic, :notice => "Registration successfull, but errors in program : #{@user.errors.messages}") }
              format.xml { render :xml => @user, :status => :created, :location => @user }
            end            
          else
            respond_to do |format|
              format.html { redirect_to(:wepic, :notice => "Registration successfull") }
              format.xml { render :xml => @user, :status => :created, :location => @user }
            end            
          end
        else
          logger.debug "fail to start running webdamlog engine"
          respond_to do |format|
            format.html { render :action => "new" , :alert => "#{@user.errors.messages.inspect}@\n\t#{backtrace[0..20].join("\n")}"}
            format.xml { render :xml => @user.errors, :status => :unprocessable_entity }            
          end
        end
      else
        logger.debug "#{@user.errors.messages.inspect}"
        respond_to do |format|
          format.html { render :action => "new" , :alert => @user.errors.messages.inspect}
          format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    rescue => error
      flash[:alert] ="#{error.message}"
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml { render :xml => {setup: error.message}, :status => :unprocessable_entity}
      end
    end # rescue => error
  end # create

  # PUT /users/1 PUT /users/1.json
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

  # DELETE /users/1 DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to :admin }
      format.json { head :no_content }
    end
  end
end
