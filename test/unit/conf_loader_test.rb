require 'yaml'
require 'test/unit'
require 'test_helper'

class ConfTest < Test::Unit::TestCase
    
  def test_config
    rails_env = Rails.env
    assert rails_env.test?
    assert_equal "test", rails_env
    Conf.init(:rails_env=>rails_env)
    assert_not_nil(Conf.peer['manager']['manager_port'])
    assert_equal 4100, Conf.peer['manager']['manager_port']
    assert_not_nil(Conf.peer['manager']['default_spawn_port'])
    assert_equal 30000, Conf.peer['manager']['default_spawn_port']
    
    assert_equal "http", Conf.peer['peer']['protocol']
    assert_equal "localhost", Conf.peer['peer']['ip']
    assert_equal 10000, Conf.peer['peer']['web_port']
    assert_equal "prog1.wl", Conf.peer['peer']['program']['name']
    assert_equal "app/assets/wlprogram/prog1.wl", Conf.peer['peer']['program']['source']

    assert_equal "postgresql", Conf.db['adapter']
    assert_equal "manager", Conf.db['username']
    assert_equal "password", Conf.db['password']
    assert_equal "unicode", Conf.db['encoding']
    assert_equal 5, Conf.db['pool']
    assert_equal "db_test", Conf.db['database']
    

    # These variable are set by wl_setup so see wl_setup test for more checking
#    assert_equal "", Conf.env['USERNAME']
#    assert_equal "", Conf.env['PORT']
#    assert_equal "", Conf.env['MANAGER_PORT']
  end
  
end
