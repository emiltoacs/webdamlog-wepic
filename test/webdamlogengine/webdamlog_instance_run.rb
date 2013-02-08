require 'test_helper'
require 'test/unit'

class WebdamlogInstanceRun < Test::Unit::TestCase

  def setup
    properties = YAML.load_file('config/properties.yml')
    @name = 'tester'
    @port = properties['test_communication']['default_spawn_port'];
    @manager_port = properties['test_communication']['manager_port'];
  end

  def teardown
    WLLauncher.end_peer(@port)
  end

  def test_foo
    #TODO: Write test
    # assert_equal("foo", bar)
  end
end
