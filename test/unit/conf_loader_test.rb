require 'yaml'
require 'test/unit'
require 'test_helper'

class ConfTest < Test::Unit::TestCase
    
  def test_config
    rails_env = Rails.env
    assert rails_env.test?
    assert_equal "test", rails_env
    Conf.init(:rails_env=>rails_env)
    assert_not_nil(Conf.peer['manager'])
    assert_not_nil(Conf.peer['manager']['default_spawn_port'])

    assert_not_nil Conf.peer['peer']['username']
    assert_not_nil Conf.peer['peer']['protocol']
    assert_equal "localhost", Conf.peer['peer']['ip']
    assert_not_nil Conf.peer['peer']['web_port']
    assert_not_nil Conf.peer['peer']['program']['file_path']

    assert_equal "postgresql", Conf.db['adapter']
    assert_equal "wepic", Conf.db['username']
    assert Conf.db['password'].nil?
    assert_equal "unicode", Conf.db['encoding']
    assert_not_nil Conf.db['pool']
    assert_equal "wp_test", Conf.db['database']
  end
  
end
