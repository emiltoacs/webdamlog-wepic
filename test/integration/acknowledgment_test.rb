# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'test/unit'
require 'lib/wl_launcher'

class AcknowledgmentTest < Test::Unit::TestCase
  include WLLauncher
  
  def setup
    @name = 'jules'
    @port = 20000;
    @manager_port = 3000;
  end
  
  def teardown
  end
  
  def test_a_start_peer_without_server
    thread = start_peer('MANAGER',nil,@manager_port,@port)
    sleep(0.5)
    send_acknowledgment(@name,@manager_port,@port)
    assert_equal(false,thread.nil?)
    thread.join
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
  end
  
  def test_a_start_peer_with_server
    thread = start_peer('MANAGER','JULES',@manager_port,@port)
    sleep(0.5)
    send_acknowledgment(@name,@manager_port,@port)
    assert_equal(false,thread.nil?)
    thread.join
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
    exit_server(@port)
  end  
end
