# Load the rails application
require File.expand_path('../application', __FILE__)
require 'lib/wl_launcher'
puts "----------------------\nBOOTING RAILS SERVER\n----------------------"
at_exit do
  include WLLauncher
  exit_server(9292,:faye) #Make sure to kill faye server at shutdown.
  puts 'Faye server exited..'
end
# Initialize the rails application
WepimApp::Application.initialize!