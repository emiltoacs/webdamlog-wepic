require 'lib/wl_launcher'

class WelcomeController < ApplicationController
  include WLLauncher
  
  def index
    @account = Account.new
    @accounts = Account.all
  end
  
  def login
    username = params[:username]
    @account = Account.find(:first,:conditions => {:username=>username})
    #If the account cannot be found
    if @account.nil?
      new(username)
      return
    end
    #If the server for account is down.
    url = "http://#{@account.ip}:#{@account.port}"
    if port_open?(@account.ip,@account.port)
      thread = start_peer(ENV['USERNAME'],@account.username,ENV['PORT'],@account.port)
      thread.join
      @account.active=true
      respond_to do |format|
        format.html {redirect_to url, :notice => "Server was rebooted"}
      end
      #If the server for account is up.
    else
      respond_to do |format|
        format.html {redirect_to url}
      end
    end    
  end
  
  def new(ext_username)
    #Temporary, need a better specification of URL.
    port_spacing = 5
    ip = "localhost"
    default_port_number = 9999
    #Here is specification of port
    max = Account.maximum(:id)
    max = 0 if max.nil?
    ext_port = default_port_number + max + port_spacing
    #This will override the port
    exit_server(ext_port) if !port_open?(ip,ext_port)
    puts "starting server..."
    start_peer(ENV['USERNAME'],ext_username,ENV['PORT'],ext_port)
    #This code does not check if call to rails failed. This operations requires interprocess communication.
    @account = Account.new(:username => ext_username, :ip=> ip, :port => ext_port, :active => true)
    if @account.save
      respond_to do |format|
        format.html {redirect_to "http://#{ip}:#{ext_port}"}
      end
    else
      respond_to do |format|
        format.html {redirect_to :welcome, :alert => "New WebdamLog Instance was not set properly"}
      end
    end
  end
  
  def shutdown
    @account = Account.find(params[:id])
    if (exit_server(@account.port))
      @account.active = false
      @account.save
      respond_to do |format|
        format.html {redirect_to :welcome, :notice => "The WebdamLog Instance was properly shut down."}
      end
    else
      respond_to do |format|
        format.html {redirect_to :welcome, :alert => "The WebdamLog Instance was not properly shut down."}
      end
    end
  end
  
  def start
    @account = Account.find(params[:id])
    start_peer(ENV['USERNAME'],@account.username,ENV['PORT'],@account.port)
    @account.active=true
    @account.save
    respond_to do |format|
      format.html {redirect_to :welcome, :notice => "The WebdamLog Instance was properly restarted."}
    end   
  end
  
  #This method is not supposed to be used by webdamlog instance
  def start_peer(name,ext_name,manager_port,ext_port)
    if name=='MANAGER'
      puts "Starting server"
      start_server(ext_name,manager_port,ext_port) if !ext_name.nil?
      server = TCPServer.new(manager_port.to_i+1)
      wait_for_acknowledgment(server,ext_port)      
#      thread = Thread.new do
#      end
#      return thread
    end
    false
  end  
end