require 'socket'
require 'timeout'
require 'set'

# Define some methods to launch and manage new peers spawned by the manager
module WLLauncher
  
  # This method is responsible for giving the order to create a peer. It returns
  # the newly created active record for the peer as well as if the creation
  # process has been successful. This method does not check if it already
  # exists.
  #
  def self.create_peer(username, properties)
    #Find an available port at the location given by the properties.
    ip = properties['peer']['ip']
    web_port = properties['manager']['default_spawn_port']
    web_port = Network::find_port ip, :TCP
    if web_port==Network::SOCKET_PORT_INVALID
      return nil, false, "no port available to deploy this peer for #{username}"
    else
      properties['peer']['web_port'] = web_port
      #Create the peer active record.
      protocol = properties['peer']['protocol']
      peer = Peer.new(:username => username, :ip=> ip, :port => web_port, :active => false, :protocol => protocol)
      peer.save
      Thread.new do
        st, msg = WLLauncher.start_peer(username, web_port, peer)
      end
      msg = "peer starting"
      return peer, true, msg
    end
  end
  
  # Start a new peer or restart a peer <peer_record> saved in the db
  #
  def self.start_peer(new_peer_name, new_peer_port, peer_record=nil)
    peer_name = Conf.env['USERNAME']
    manager_waiting_port = Conf.peer['manager']['manager_waiting_port']
    if manager_waiting_port.nil? or !Network.port_available?(Conf.peer['manager']['ip'], manager_waiting_port)
      manager_waiting_port = Network.find_port Conf.peer['manager']['ip'], :TCP
    end
    listener = TCPServer.new(manager_waiting_port)
    if Conf.manager?
      if !new_peer_name.nil?
        cmd = "rails server -p #{new_peer_port} -U #{new_peer_name} -m #{manager_waiting_port}"
        WLLogger.logger.debug "execute: #{cmd}"
        child_pid = Process.spawn cmd
      else
        WLLogger.logger.fatal "try to launch a new peer without username"
      end
      b, msg = wait_for_acknowledgment(listener,new_peer_port)
      unless peer_record.nil?
        peer_record.active=true
        peer_record.pid=child_pid
        peer_record.msg=msg
        peer_record.save
      end
      return b, msg
    else
      msg = "The non-manager #{peer_name} peer is trying to spawn a new peer"
      WLLogger.logger.warn msg
      return false, msg
    end
  end
  
  def self.wait_for_acknowledgment(listener, new_peer_port)
    begin
      Timeout::timeout(10000) do
        begin          
          client = listener.accept
          str = client.gets
          if str.include? new_peer_port.to_s
            client.close
            listener.close
            return true, "ack received #{str}"
          else
            return false, "peer may have failed to start, it sends #{str}"
          end
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          msg = "Connection Error..."
          WLLogger.logger.info msg
          return false, msg
        end
      end
    rescue Timeout::Error
      msg = "Time out..."
      WLLogger.logger.info msg
      return false, msg
    end
  end
  
  def self.end_peer(port,type=:thin)
    pids = Set.new
    case type
    when :thin
      `ps -ef | grep rails`.split("\n").each_with_index do |line,i|
        line_tokens = line.split(" ")
        pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
      end
    end
    WLLogger.logger.debug "Sending TERM signal to #{pids}"
    pids.each do |pid|
      Process.kill "TERM", Integer(pid)
    end
    pids.each do |pid|
      Process.wait Integer(pid)
      WLLogger.logger.info "Process #{pid} terminated"
    end
    pids.size
  end
  
  #Check if URL specified is local.
  def self.local?(url)
    url.include?('localhost') || url.include?('127.0.0.1')
  end
  
  #Checks if specified URL is reachable from this peer.
  def self.reachable?(url, port)
    if local?(url)
      true
    else
      begin
        Timeout::timeout(1) do
          s = TCPSocket.new(url, port)
          s.close
          return true
        end
      rescue => error
        WLLogger.logger.warn error.inspect
      end
      false
    end
  end
  
  # This method is used to access a peer that has already been created and
  # assigned an address (ip:port)
  #
  def self.access_peer(peer)
    #Checks if the peer object received is valid
    unless peer.ip && peer.port && peer.username
      return nil,false,false
    end

    #Compose URL
    url = "#{peer.protocol}://#{peer.ip}"

    #Check if url reachable.
    if reachable?(url, peer.port)
      accessible = true
      available = peer.active
      #If the peer is active we are done.
      WLLauncher.start_peer(peer.username, peer.port, peer) unless available
      return url,accessible,available
    else
      return nil,false,false
    end
  end
  
end