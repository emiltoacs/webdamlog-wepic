# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'test/unit'
require 'app/helpers/wl_launcher'

class WLLauncherTest < Test::Unit::TestCase
  include WLLauncher
  
  #For most of the tests, please refer to acknowledgment_test under test/integration.
  
  def test_ack_server
    server1, port1 = ack_server(4999)
    server2, port2 = ack_server(4999)
    assert_equal(5000,port1)
    assert_equal(5001,port2)
    server1.close    
    server3, port3 = ack_server(4999)
    assert_equal(5000,port3)
    server2.close
    server3.close
  end
end
