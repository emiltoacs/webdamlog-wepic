# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WepimApp::Application.initialize!

# Initialize configuration with standard settings from files that describe
# manager environment
Conf.init(::Rails.env, { force:true })
#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
if WepimApp.is_manager?
  require 'wl_launcher'
else
  require 'debugger' ; debugger
  # Special config for peers
  # Change db
  Conf.db['database']="wp_#{Conf.env['USERNAME']}"
  require 'wl_peer'
  require 'webdamlog_engine'
  WLLogger.logger.info "Wepic peer of #{Conf.env['USERNAME']},#{Conf.env['PORT']} has finsihed initialization and is ready to send acknowedgement to manager"
  WebdamlogEngine::WebdamlogEngine.new
  WLPeer.send_acknowledgment(Conf.env['USERNAME'],Conf.env['MANAGER_PORT'],Conf.env['PORT'])
end

