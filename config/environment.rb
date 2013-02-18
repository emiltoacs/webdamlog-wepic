# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize configuration with standard settings from files that describe
# manager environment
#require 'wl_tool'
#Conf.init({ force:true })

# Initialize the rails application
WepimApp::Application.initialize!

#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
if Conf.manager?
  require 'wl_launcher'
else  
  require 'wl_peer'
  require 'webdamlog_engine'
  WLLogger.logger.info "Wepic peer of #{Conf.env['USERNAME']},#{Conf.env['PORT']} has finsihed initialization and is ready to send acknowedgement to manager"
  WebdamlogEngine::WebdamlogEngine.new
  WepicPeer.send_acknowledgment(Conf.env['USERNAME'],Conf.env['MANAGER_PORT'],Conf.env['PORT'])
end

