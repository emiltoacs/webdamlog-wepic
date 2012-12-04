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
      start_server(@account.username,@account.port)
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
  
  def new(username)
    #Temporary, need a better specification of URL.
    ip = "localhost"
    default_port_number = 9999
    #Here is specification of port
    max = Account.maximum(:id)
    max = 0 if max.nil?
    port = default_port_number + max + 1
    #This will override the port
    exit_server(port) if !port_open?(ip,port)
    puts "starting server..."
    start_server(username,port)
    #This code does not check if call to rails failed. This operations requires interprocess communication.
    @account = Account.new(:username => username, :ip=> ip, :port => port, :active => true)
    if @account.save
      respond_to do |format|
        sleep(7) #very ugly of making the user wait for the external server to be ready. We probably can do better.
        format.html {redirect_to "http://#{ip}:#{port}"}
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
    start_server(@account.username,@account.port)
    @account.active=true
    @account.save
    respond_to do |format|
      format.html {redirect_to :welcome, :notice => "The WebdamLog Instance was properly restarted."}
    end   
  end
end