# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WepimApp::Application.initialize!

# Initialize configuration with standard settings from files that describe
# manager environment
Conf.init
#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
if WepimApp.is_manager?
  require 'wl_launcher'
else
  # Special config for peers
  # Change db
  Conf.db['database'] == "database_#{ENV['USERNAME']}"
  require 'wl_peer'
  require 'webdamlog_engine'
  WLLogger.logger.info "Wepic peer of #{ENV['USERNAME']},#{ENV['PORT']} has finsihed initialization and is ready to send acknowedgement to manager"
  WebdamlogEngine::WebdamlogEngine.new
  WLPeer.send_acknowledgment(ENV['USERNAME'],ENV['MANAGER_PORT'],ENV['PORT'])
end

