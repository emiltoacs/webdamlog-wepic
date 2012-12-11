# Load the rails application
require File.expand_path('../application', __FILE__)
require 'lib/wl_launcher'
puts "----------------------\nBOOTING RAILS SERVER\n----------------------"
at_exit do
  include WLLauncher
  exit_server(ENV['PORT'].to_i+2,:faye) #Make sure to shutdown faye server at shutdown.
  puts 'bye..'
end
# Initialize the rails application
WepimApp::Application.initialize!