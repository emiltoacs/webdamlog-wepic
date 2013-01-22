# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'test/unit'
require 'lib/wl_launcher'
require 'lib/wl_peer'
require 'yaml'

class AcknowledgmentTest < Test::Unit::TestCase
  include WLLauncher
  include WLPeer
  
  def setup
    properties = YAML.load_file('config/properties.yml')
    @name = 'jules'
    @port = properties['test_communication']['default_spawn_port'];
    @manager_port = properties['test_communication']['manager_port'];    
    
  end
  
  def teardown
    exit_server(@port)
  end
  
  def test_a_start_peer_without_server
    puts "TEST A"
    return_peer_value = true
    peer_thread = Thread.new do
      return_peer_value = start_peer('MANAGER',nil,@manager_port,@port)
    end 
    sleep(0.5)
    send_acknowledgment(@name,@manager_port,@port)
    peer_thread.join
    assert_equal(true, return_peer_value)
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
  end
  
  def test_b_start_peer_with_server
    puts "TEST B"
    assert_equal(true,start_peer('MANAGER','JULES',@manager_port,@port))
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
    exit_server(@port)
  end
end
