ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'test/unit'

ENV['USERNAME'] = "test_user"

begin
  require 'debugger'
rescue LoadError => e
  begin
    require 'ruby-debug'
  rescue LoadError => e
    puts "debugger disabled"
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  def self.logger
    Rails.logger
  end
  # Add more helper methods to be used by all tests here...
end
