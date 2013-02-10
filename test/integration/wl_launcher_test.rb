require 'test_helper'
require 'test/unit'

class WLLauncherTest < ActionController::IntegrationTest
  include Properties
    
  def setup
    @root_port = properties['test_peer']['root_port']
    @ports_used = properties['test_peer']['ports_used']
    @ip = properties['test_peer']['ip']
  end
    
  def teardown
      
  end
  
  def test_port_available
    #Assume test root port is available as defined in setup and port 80 unavailable.
    assert_equal(true,WLLauncher.port_available?(@ip,@root_port))
    assert_equal(false,WLLauncher.port_available?(@ip,80))
  end
    
  def test_find_ports
    #This test first assumes that all ports are available.
    assert_equal(@root_port,WLLauncher.find_ports(@ip,@ports_used,@root_port)) 
      
    #Now the test blocks a port and check that method behaves appropriately
    begin 
      s = TCPServer.new(@ip,@root_port+@ports_used-1)
      assert_equal(@root_port+@ports_used,WLLauncher.find_ports(@ip,@ports_used,@root_port))
      s.close
    rescue => error
      WLLogger.logger.warn error.inspect
    end
  end
  
  def test_create_peer
    #Create a new peer
    username = "jules"
    WLLauncher.create_peer(username)
    #Wait for some time and then check if the peer has been succesfully launched by checking
    #if the acknowledgement it is supposed to send back has been recieved.
    sleep(1)
    @account = Peer.find(:username=>username)
    assert_equal(true,@account.active)
  end
end