# Load the rails application
require File.expand_path('../application', __FILE__)


# Initialize the rails application
WepimApp::Application.initialize!

#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
#
if WepimApp.is_manager?
  require 'lib/wl_launcher'
else
  require 'lib/wl_peer'
  require 'lib/webdamlog/wlbud'
  WLPeer.send_acknowledgment(ENV['USERNAME'],ENV['MANAGER_PORT'],ENV['PORT'])

  # Create a subclass of WL
#  klass = Class.new(WLBud::WL)
#  # TODO find a good name for the sub class, it should be uniq
#  self.class.class_eval "ClassWL#{ENV['USERNAME']}on#{ENV['MANAGER_PORT']} = klass"
#  peername="peername_#{ENV['USERNAME']}on#{ENV['MANAGER_PORT']}"
#  peername="programfile_of_#{ENV['USERNAME']}on#{ENV['MANAGER_PORT']}"
#  @webdamlog = eval("ClassWL#{ENV['USERNAME']}on#{ENV['MANAGER_PORT']}.new(:port => 12352)")
#  @webdamlog.run_bg
  
end