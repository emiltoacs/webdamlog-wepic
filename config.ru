# This file is used by Rack-based servers to start the application.

# Use to sync message from heroku in the log for real time monitoring
$stdout.sync = true

require ::File.expand_path('../config/environment',  __FILE__)

run WepimApp::Application