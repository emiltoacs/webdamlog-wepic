# The controller of the manager Wepic Peers do not use this controller.
#
class WelcomeController < ApplicationController
  
  def index
    @account = Peer.new if @account.nil?
    @accounts = Peer.all
    @protocol = Conf.peer['peer']['protocol']
    @scenarios = Scenario.all
  end

  # Once clicked on the button go, launch or reconnect to a peer
  def login
    username = params[:username]
    WLTool::sanitize!(username)
    @account = Peer.find(:first,:conditions => {:username=>username})
    
    if @account.nil?
      # If the account is new
      @account, launched, msg = WLLauncher.create_peer(username)
      if launched
        # The peer is being launched, we send the user to the waiting until the
        # peer is ready.
        respond_to do |format|
          format.html {redirect_to "/waiting/#{@account.id}", :notice => "Please wait while your wepic instance is being created..."}
        end
      else
        # The peer was not launched
        respond_to do |format|
          format.html {redirect_to '/', :alert => "New WebdamLog Instance was not set properly. Reason #{msg}"}
        end
      end
    else
      # If the account already exists
      url, accessible, available = WLLauncher.access_peer(@account)
      if accessible
        if available
          # The peer is already up an running, we just need to access it.
          respond_to do |format|
            format.html {redirect_to url}
          end
        else
          # The peer is accessible but has to be rebooted
          respond_to do |format|
            format.html {redirect_to "/waiting/#{@account.id}", :notice => "Server is rebooting..."}
          end
        end
      else
        # Worst case, peer cannot even be accessed (data missing, remote
        # location unreachable...)
        respond_to do |format|
          format.html {redirect_to '/', :alert => "The specified peer cannot be accessed. Please contact the service administrator."}
        end
      end
    end
    
  end # login

  def shutdown
    @account = Peer.find(params[:id])
    if (WLLauncher.end_peer(@account.port))
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
  end # shutdown

  def start
    @account = Peer.find(params[:id])
    Thread.new do
      WLLauncher.start_peer(@account.username,@account.port,@account)
    end
    @account.active=true
    @account.save
    respond_to do |format|
      format.html {redirect_to :welcome, :notice => "The WebdamLog Instance is restarting...." }
    end
  end

  # Kill all peers for which this manager is responsible.
  def killall
    @accounts = Peer.all
    @accounts.each do |account|
      WLLauncher.end_peer(account.port)
      account.active = false
      account.save
    end
    respond_to do |format|
      format.html {redirect_to :welcome, :notice => "All peers were killed" }
    end
  end

  # This method is called by the javascript inside
  # app/views/welcome/waiting.html.erb when the server is ready.
  def confirm_server_ready
    @account = Peer.find(params[:id])
    respond_to do |format|
      format.json {render :json => @account.active }
    end
  end

  # This method is used to redirect a user to a specific wepic peer homepage.
  def redirect
    @account = Peer.find(params[:id])
    respond_to do |format|
      format.html {redirect_to "#{Conf.peer['peer']['protocol']}://#{@account.ip}:#{@account.port}" }
    end
  end

  def waiting
    @account = Peer.find(params[:id])
  end

  def output_errors(account)
    s=""
    account.errors.full_messages.each do |msg|
      s+="\n\t#{msg}"
    end
    s
  end # output_errors

  # Handle the call to initialize the right scenario
  def start_scenario
    scenario = Scenario.new( params[:scenario_opt][:scenario_selected] )
    sigmodpeer, launched, msg = scenario.run
    @account = sigmodpeer
    if launched
      respond_to do |format|
        format.html {redirect_to "/waiting/#{sigmodpeer.id}", :notice => "Please wait while your sigmodpeer instance is being created..."}
      end
    else
      respond_to do |format|
        format.html {render :index, :alert => "sigmodpeer instance was not set properly. Reason #{msg}"}
      end
    end
  end # start_scenario

end # class WelcomeController < ApplicationController
