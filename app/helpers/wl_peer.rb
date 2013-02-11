#This module will replace the wl_launcher a file as a new communication protocol between the manager and the peer
#it manages. This protocol will be simpler to understand and less error-prone than the previous one. 
#
#I intend to base most of the communication on udp sockets.
#
module WLPeer
  #This method is not supposed to be used by the manager, whose environment
  #variable MANAGER_PORT should be undefined (or nil).
  def self.send_acknowledgment(name,manager_port,port)
    if name!='MANAGER'
      socket = TCPSocket.open('localhost',manager_port.to_i + 1)
      socket.puts "Port #{port} ready"
      socket.close
    end
  end  
end
