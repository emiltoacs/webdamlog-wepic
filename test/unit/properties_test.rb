require 'yaml'
require 'test/unit'
require 'test_helper'

class PropertiesTest < Test::Unit::TestCase
  def setup
    
  end
  
  def test_config
    @properties = YAML.load_file("config/properties.yml")

    assert_not_nil(@properties['test_communication']['manager_port'])
    assert_equal 4100, @properties['test_communication']['manager_port']
    assert_not_nil(@properties['test_communication']['default_spawn_port'])
    assert_equal 30000, @properties['test_communication']['default_spawn_port']
    assert_not_nil(@properties['test_communication']['port_spacing'])
    assert_equal 3, @properties['test_communication']['port_spacing']
    
    assert_equal "http", @properties['test_peer']['protocol']
    assert_equal "localhost", @properties['test_peer']['ip']
    assert_equal 3, @properties['test_peer']['ports_used']
    assert_equal 10000, @properties['test_peer']['root_port']
    assert_equal "prog1.wl", @properties['test_peer']['program']['name']
    assert_equal "johndoe", @properties['test_peer']['program']['author']
    assert_equal "app/assets/wlprogram/prog1.wl", @properties['test_peer']['program']['source']
    # We don't want to output huge message while tesing !
#    assert_nothing_raised do
#      Rails.logger.info("Properties for wepic : \n\t#{@properties.inspect}")
#    end
  end
end
