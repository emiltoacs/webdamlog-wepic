require 'test_helper'
require 'test/unit'

class WLLauncherTest < ActionController::IntegrationTest
    
  def setup
    ENV["USERNAME"] = "manager"
    ENV["PORT"] = "4000"
    ENV["MANAGER_PORT"] = nil
    Conf.init({rails_env:'test', force: true })
    @root_port = Conf.peer['peer']['root_port']
    @ip = Conf.peer['peer']['ip']    
  end
    
  def teardown
      
  end

  # Test the port given in the PeerProperties.config.yml file
  #
  # Test the methods port_availaibles? and find_ports
  #
  def test_1_port_in_config_file_available
    ip = Conf.peer['manager']['ip']
    port = Conf.peer['manager']['manager_port']
    assert Network.port_available?(ip,port),
      "check your PeerProperties.config.yml file the #{ip}:#{port} port should be availaible"
    assert_equal port, Network.find_ports(ip,1,port)
    ip = Conf.peer['peer']['ip']
    port = Conf.peer['peer']['root_port']
    assert Network.port_available?(ip,port),
      "check your PeerProperties.config.yml file the #{ip}:#{port} port should be availaible"
  end

  # Test find port behavior when a port in the range is not availaible
  #
  # This test is based on the adjacent port range discovery (see TODO in
  # find_port)
  #
  # TODO here the test does not work socket_block_port is suppose to block the
  # port to see how find port works when a port is blocked but it seems that
  # once I call WLLauncher everything goes as if the port would have never been
  # closed.
  #
  def test_2_find_ports_when_port_not_free
    #This test first assumes that all ports are available.
    assert_equal(@root_port, Network.find_ports(@ip,1,@root_port))
    #Now the test blocks a port and check that method behaves appropriately
    begin
      port_reserved = @root_port
      socket_block_port = TCPServer.new(@ip, port_reserved)
      # FIXME assert_equal(@root_port+1, WLLauncher.find_ports(@ip, @ports_used, @root_port))
      socket_block_port.close
    rescue => error
      WLLogger.logger.warn error.inspect
    end
  end

  # Test manager creates a new peer in the database
  #
  def test_3_create_peer
    username = "new_peer_for_testing"
    p Conf.env
    p ENV['USERNAME']
    peer, st, msg = WLLauncher.create_peer(username, Conf.peer)
    sleep(2)
    assert st
    assert_not_nil peer
    assert_equal username, peer.username
    tuples = Peer.where("username = ?",username)
    assert_equal 1, tuples.length
  end
end