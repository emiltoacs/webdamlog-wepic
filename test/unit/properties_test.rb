# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'yaml'
require 'test/unit'
require 'test/test_helper'

class PropertiesTest < Test::Unit::TestCase
  def setup
    @properties = YAML.load_file("config/properties.yml")
  end
  
  def test_config
    assert_not_nil(@properties['communication']['manager_port'])
    assert_not_nil(@properties['communication']['default_spawn_port'])
    assert_not_nil(@properties['communication']['port_spacing'])
    
    Rails.logger.info("Properties for wepic : \n\t#{@properties.inspect}")
    
  end
end
