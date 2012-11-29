class LoginManagerController < ApplicationController
  def index
    @account = Account.new
  end
  
  def retrieve
    username = params[:username]
    @account = Account.find(:first,:conditions => {:username=>username})
    if @account.nil?
      respond_to do |format|
        format.html {redirect_to :login_manager, :alert => 'No account exists with this username.'}
      end
      return
    end
    port = @account.url.split(':').last
    if !@account.active
      @account.active = system("rails server -p #{port}")
      @account.save
    end
    respond_to do |format|
      format.html {redirect_to @account.url, :notice => "Server was rebooted"}
    end    
  end
  
  def create_account
    
  end
end
