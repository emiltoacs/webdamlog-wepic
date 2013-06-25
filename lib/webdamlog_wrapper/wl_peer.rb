# This module will replace the wl_launcher a file as a new communication
# protocol between the manager and the peer it manages. This protocol will be
# simpler to understand and less error-prone than the previous one.
#
require "./lib/wl_logger"


module WepicPeer
  # Send a acknowledgment to the manager who launched the peer. It does nothing
  # if the peer launched is a standalone (ie. launched directly on the machine
  # without any manager).
  #
  # This method is not supposed to be used by the manager, whose environment
  # variable MANAGER_PORT should be undefined (or nil).
  #
  def self.send_acknowledgment(name,manager_port,port)
    if Conf.manager?
      WLLogger.logger.warn "unexpected behavior trying to send a acknowledgement from the manager"
    else
      unless Conf.standalone?
        socket = TCPSocket.open('localhost', manager_port)
        socket.puts "Peer #{name} on port #{port} ready"
        socket.close
      end
    end
  end
end
