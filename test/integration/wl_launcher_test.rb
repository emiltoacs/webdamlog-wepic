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

  # Test the port given in the properties.yml file
  #
  # Test the methods port_availaibles? and find_ports
  #
  def test_1_port_in_config_file_available
    ip = properties['communication']['ip']
    port = properties['communication']['manager_port']
    assert WLLauncher.port_available?(ip,port),
      "check your properties.yml file the #{ip}:#{port} port should be availaible"
    port_spacing = properties['communication']['port_spacing']
    assert_equal port, WLLauncher.find_ports(ip,port_spacing,port)

    ip = properties['test_communication']['ip']
    port = properties['test_communication']['manager_port']
    assert WLLauncher.port_available?(ip,port),
      "check your properties.yml file the #{ip}:#{port} port should be availaible"
    port_spacing = properties['test_communication']['port_spacing']
    assert_equal port,WLLauncher.find_ports(ip,port_spacing,port)

    ip = properties['peer']['ip']
    port = properties['peer']['root_port']
    assert WLLauncher.port_available?(ip,port),
      "check your properties.yml file the #{ip}:#{port} port should be availaible"
    port_spacing = properties['peer']['ports_used']
    assert_equal port,WLLauncher.find_ports(ip,port_spacing,port)

    ip = properties['test_peer']['ip']
    port = properties['test_peer']['root_port']
    assert WLLauncher.port_available?(ip,port),
      "check your properties.yml file the #{ip}:#{port} port should be availaible"
    port_spacing = properties['test_peer']['ports_used']
    assert_equal port,WLLauncher.find_ports(ip,port_spacing,port)
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
    assert_equal(@root_port,WLLauncher.find_ports(@ip,@ports_used,@root_port))
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

  # Test creation of a new peer in the database
  #
  def test_3_create_peer
    username = "tester"
    peer, st = WLLauncher.create_peer(username, properties)
    sleep(2)
    assert st
    assert_not_nil peer
    assert_equal username, peer.username
    tuples = Peer.where("username = ?",username)
    p tuples.class
    assert_equal 1, tuples.length
  end
end