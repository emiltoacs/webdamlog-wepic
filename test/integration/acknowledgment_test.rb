# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'test/unit'
require 'lib/wl_launcher'
require 'eventmachine'
require 'faye'

class AcknowledgmentTest < Test::Unit::TestCase
  include WLLauncher
  
  def setup
    @name = 'jules'
    @port = 20000;
    @manager_port = 3000;
  end
  
  def teardown
    exit_server(@port)
    exit_server(@port+2,:faye)
  end
  
  def test_a_start_peer_without_server
    puts "TEST A"
    return_value = true
    thread = Thread.new do
      return_value = start_peer('MANAGER',nil,@manager_port,@port)
    end
    sleep(0.5)
    send_acknowledgment(@name,@manager_port,@port)
    thread2 = Thread.new do
      EM.run do
        puts "Starting event machine"
        client = Faye::Client.new("http://localhost:#{@manager_port.to_i+2}/faye")
        puts "#{client.inspect}"
        message_received = false
        while(!message_received) do
          client.subscribe('/redirect') do |message|
            puts message.inspect
            assert_equal(true,message=="Client at port #{@port} is ready!")
            message_received = true
            EM.stop_event_loop
          end
        end
      end
    end
    thread.join
    thread2.join
    assert_equal(true, return_value)
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
  end
  
  def test_b_start_peer_with_server
    puts "TEST B"
    assert_equal(true,start_peer('MANAGER','JULES',@manager_port,@port))
    print "----------\n#{@name} has connected on port #{@port}!\n-----------"
    exit_server(@port)
  end  
end
