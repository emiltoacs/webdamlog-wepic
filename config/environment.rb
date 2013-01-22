# Load the rails application
require File.expand_path('../application', __FILE__)
require 'lib/wl_launcher'
# Initialize the rails application
WepimApp::Application.initialize!

#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
#
unless WepimApp.is_manager?
  WLLauncher.send_acknowledgment(ENV['USERNAME'],ENV['MANAGER_PORT'],ENV['PORT'])
end