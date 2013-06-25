# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WepimApp::Application.initialize!

# Once the application is initialized, if the application is a peer (and not a
# manager), it signals to its manager that it is ready to receive requests).
if Conf.manager?
  require 'webdamlog_wrapper/wl_launcher'
else  
  require 'webdamlog_wrapper/wl_peer'
  require 'webdamlog_wrapper/engine_helper'

  if Conf.standalone?
    WLLogger.logger.info "Wepic peer of #{Conf.env['USERNAME']},#{Conf.env['PORT']} has finished standalone initialization"
  else
    WLLogger.logger.info "Wepic peer of #{Conf.env['USERNAME']},#{Conf.env['PORT']} has finished initialization and is ready to send acknowedgement to manager"
    WepicPeer.send_acknowledgment(Conf.env['USERNAME'],Conf.env['MANAGER_PORT'],Conf.env['PORT'])
  end
end # if Conf.manager?

