require 'lib/wl_launcher'
require 'yaml'
require 'lib/wl_logger'

# The controller of the manager
class WelcomeController < ApplicationController
  
  def index
    @account = Account.new if @account.nil?
    @accounts = Account.all
  end

  # Once clicked on the button go, launch or reconnect to a peer
  def login
    username = params[:username]
    @account = Account.find(:first,:conditions => {:username=>username})
    #If the account is new
    if @account.nil?
      new(username)
      return
    end
    #If the server for account is down.
    url = "http://#{@account.ip}:#{@account.port}"
    if WLLauncher.port_open?(@account.ip,@account.port)
      Thread.new do
        WLLauncher.start_peer(ENV['USERNAME'],@account.username,ENV['PORT'],@account.port,@account)
      end
      respond_to do |format|
        #XXX need to take care of url
        format.html {redirect_to "/waiting/#{@account.id}", :notice => "Server is rebooting..."}
      end
      #If the server for account is up.
    else
      respond_to do |format|
        format.html {redirect_to url}
      end
    end
  end
  
  def new(ext_username)
    
    #Use properties to define ports for spawned servers.
    properties = YAML.load_file('config/properties.yml')
    port_spacing = properties['communication']['port_spacing']
    ip = "localhost"
    default_port_number = properties['communication']['default_spawn_port']
    #Here is specification of port
    max = Account.maximum(:id)
    max = 0 if max.nil?
    ext_port = default_port_number + max + port_spacing
    
    #This will override the port
    WLLauncher.exit_server(ext_port) unless WLLauncher.port_open?(ip,ext_port)
    @account = Account.new(:username => ext_username, :ip=> ip, :port => ext_port, :active => false)
    #This code does not check if call to rails failed. This operations requires interprocess communication.
    if @account.save
      WLLogger.logger.info "#{@account.valid?}"
      respond_to do |format|
        Thread.new do
          WLLauncher.start_peer(ENV['USERNAME'],ext_username,ENV['PORT'],ext_port,@account)
        end
        #format.html {redirect_to "http://#{ip}:#{ext_port}"}
        #Take care of URL
        format.html {redirect_to "/waiting/#{@account.id}", :notice => "Please wait while your wepic instance is being created..."}
      end
    else
      respond_to do |format|
        format.html {redirect_to '/', :alert => "New WebdamLog Instance was not set properly. Reason : #{output_errors(@account)}"}
      end
    end
  end
  
  def shutdown
    @account = Account.find(params[:id])
    if (WLLauncher.exit_server(@account.port))
      @account.active = false
      @account.save
      respond_to do |format|
        format.html {redirect_to :welcome, :notice => "The WebdamLog Instance was properly shut down."}
      end
    else
      respond_to do |format|
        format.html {redirect_to :welcome, :alert => "The WebdamLog Instance was not properly shut down. Reason : #{output_errors(@account)}"}
      end
    end
  end
  
  def start
    @account = Account.find(params[:id])
    Thread.new do 
      WLLauncher.start_peer(ENV['USERNAME'],@account.username,ENV['PORT'],@account.port)
    end
    @account.active=true
    @account.save
    respond_to do |format|
      format.html {redirect_to :welcome, :notice => "The WebdamLog Instance is restarting...."}
    end   
  end
  
  def killall
    @accounts = Account.all
    @accounts.each do |account|
      WLLauncher.exit_server(account.port)
      account.active = false
      account.save      
    end
    respond_to do |format|
      format.html {redirect_to :welcome, :notice => "All peers were killed"}
    end
  end

  def confirm_server_ready
    @account = Account.find(params[:id])
    #WLLogger.logger.info "account : " + @account.inspect
    respond_to do |format|
      format.json { render :json => @account.active }
    end
  end
  
  def waiting
    @account = Account.find(params[:id])
  end
  
  def output_errors(account)
    s=""
    account.errors.full_messages.each do |msg|
      s+="\n\t#{msg}"
    end
    s
  end
end
