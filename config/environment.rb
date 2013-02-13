# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WepimApp::Application.initialize!

require 'wl_tool'
require 'wl_logger'
#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
#
if WepimApp.is_manager?
  require 'wl_launcher'
else
  require 'wl_peer'
  require 'webdamlog_engine'
  WLLogger.logger.info "Wepic peer of #{ENV['USERNAME']},#{ENV['PORT']} has finsihed initialization and is ready to send acknowedgement to manager"
  WLPeer.send_acknowledgment(ENV['USERNAME'],ENV['MANAGER_PORT'],ENV['PORT'])
end

# There is the general custom configuration options for this app
PeerConf.init
db_name = "db/database_#{ENV['USERNAME']}.db"
UserConf.init({
    name: ENV['USERNAME'],
    db_name: db_name,
    connection: {:adapter => 'sqlite3', :database => db_name}
  })
