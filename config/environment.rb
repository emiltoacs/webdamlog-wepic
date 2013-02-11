# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WepimApp::Application.initialize!

#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
#
if WepimApp.is_manager?
  require 'wl_launcher'
else
  require 'wl_peer'
  require 'webdamlog_engine'
  #WepimApp::Application.config
  WLLogger.logger.info "Wepic peer of #{ENV['USERNAME']},#{WLPORT} has finsihed initialization and is ready to send acknowedgement to manager"
  WLPeer.send_acknowledgment(ENV['USERNAME'],ENV['MANAGER_PORT'],WLPORT)
end
