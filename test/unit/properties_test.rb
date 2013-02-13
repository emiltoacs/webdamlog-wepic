require 'yaml'
require 'test/unit'
require 'test_helper'

class PropertiesTest < Test::Unit::TestCase
    
  def test_config
    config = PeerConf.init

    assert_not_nil(config['communication']['manager_port'])
    assert_equal 4100, config['communication']['manager_port']
    assert_not_nil(config['communication']['default_spawn_port'])
    assert_equal 30000, config['communication']['default_spawn_port']
    assert_not_nil(config['communication']['port_spacing'])
    assert_equal 3, config['communication']['port_spacing']
    
    assert_equal "http", config['peer']['protocol']
    assert_equal "localhost", config['peer']['ip']
    assert_equal 3, config['peer']['ports_used']
    assert_equal 10000, config['peer']['root_port']
    assert_equal "prog1.wl", config['peer']['program']['name']
    assert_equal "johndoe", config['peer']['program']['author']
    assert_equal "app/assets/wlprogram/prog1.wl", config['peer']['program']['source']
  end
end
