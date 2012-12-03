require 'lib/wl_launcher'

class WelcomeController < ApplicationController
  inlcude WLLauncher
  
  def index
    @account = Account.new
  end
  
  def existing
    username = params[:username]
    @account = Account.find(:first,:conditions => {:username=>username})
    if @account.nil?
      respond_to do |format|
        format.html {redirect_to :welcome, :alert => 'No account exists with this username.'}
      end
      return
    end
    port = @account.url.split(':').last
    if !@account.active
      @account.active = system("rails server -p #{port} #{username}")
      @account.save
    end
    respond_to do |format|
      format.html {redirect_to @account.location, :notice => "Server was rebooted"}
    end    
  end
  
  def new
    username = params[:username]
    #Temporary, need a better specification of URL.
    ip = "localhost"
    default_port_number = 9999
    #Here is specification of port
    max = Account.maximum(:id)
    max = 0 if max.nil?
    port = default_port_number + max + 1
    
    if @account.active && @account.save
      respond_to do |format|
        format.html {redirect_to @account.location}
      end
    else
      respond_to do |format|
        format.html {redirect_to :welcome, :alert => "New WLInstance was not set properly"}
      end
    end
  end
  
  def start_wl(username,ip,port)
    url = "http://#{ip}:#{port}"
    
    #This code does not check if call to rails failed. This operations requires interprocess communication.
    @account = Account.new(:username => username, :location => url, :active => true, :pid => start_server(username,ip,port))
  end
  
end