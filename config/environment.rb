# Load the rails application
require 'logger'
require 'app/helpers/wl_setup'
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WepimApp::Application.initialize!

ENV['RAILS_ROOT'] = Rails.root
ENV['RAILS_ENV'] = Rails.env

database_environmnent_setup