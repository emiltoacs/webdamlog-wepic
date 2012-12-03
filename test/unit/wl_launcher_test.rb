# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'test/unit'
require 'lib/wl_launcher'

class WLLauncherTest < Test::Unit::TestCase
  include WLLauncher
  
  def setup
    @port = 10000
  end
  
  def teardown
    
  end
  
  def test_a_start_server
    start_server(@port)
  end
  
  def test_b_port_open
    sleep(8)
    assert_equal(true,port_open?('localhost',@port))
    assert_equal(false,port_open?('localhost',@port+1))
  end
  
  def test_c_destroy_server
    #The method should destroy one process
    sleep(10)
    assert_equal(1,exit_server(@port))
  end
end
