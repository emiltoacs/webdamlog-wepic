# To change this template, choose Tools | Templates
# and open the template in the editor.
root = File.expand_path('../../../../',  __FILE__) 
require 'test/unit'
require "#{root}/lib/webdamlog_wrapper/wl_launcher"
require "#{root}/lib/webdamlog_wrapper/wl_peer"
require 'yaml'

class AcknowledgmentTest < Test::Unit::TestCase
  
  def setup
    properties = YAML.load_file('config/peer.yml')
    @name = 'jules'
    @port = properties['test_communication']['default_spawn_port'];
    @manager_port = properties['test_communication']['manager_port'];    
    
  end
  
  def teardown
    WLLauncher.end_peer(@port)
  end
  
  def test_a_start_peer_without_server
    puts "TEST A"
    return_peer_value = true
    peer_thread = Thread.new do
      return_peer_value = WLLauncher.start_peer('manager',@port)
    end 
    sleep(0.5)
    WepicPeer.send_acknowledgment(@name,@manager_port,@port)
    peer_thread.join
    assert_equal(true, return_peer_value)
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
  end
  
  def test_b_start_peer_with_server
    puts "TEST B"
    assert_equal(true,WLLauncher.start_peer('JULES',@port))
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
    WLLauncher.end_peer(@port)
  end
end
