require 'socket'
require 'timeout'
require 'set'

# Define some methods to launch and manage new peers spawned by the manager
module WLLauncher
  
  def self.wait_for_acknowledgment(server,port)
    begin
      Timeout::timeout(5) do
        begin
          client = server.accept
          client.gets
          client.close
          server.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          WLLogger.logger.info "Connection Error..."
          return false
        end
      end
    rescue Timeout::Error
      WLLogger.logger.info "Time out..."
      return false
    end
  end

  # This method is responsible for giving the order to create a peer. It returns
  # the newly created active record for the peer as well as if the creation
  # process has been successful. This method does not check if it already
  # exists.
  #
  def self.create_peer(username, properties)    
    #Find an available port at the location given by the properties.
    ip = properties['peer']['ip']
    number_of_ports_required = properties['peer']['ports_used']
    root_port = properties['peer']['root_port']    
    root_port = Network::find_ports(ip,number_of_ports_required,root_port)
    if root_port==Network::SOCKET_PORT_INVALID
      return nil, false
    else
      properties['peer']['root_port'] = root_port + number_of_ports_required
    end

    #Create the peer active record.
    protocol = properties['peer']['protocol']
    peer = Peer.new(:username => username, :ip=> ip, :port => root_port, :active => false, :protocol => protocol)
    peer.save
    #Launch the peer in a new thread.
    #Thread.new do
      WLLauncher.start_peer(ENV['USERNAME'],username,ENV['PORT'],root_port,peer)
    #end
    return peer,true
  end

  # TODO keep the id of the child process launched to kill properly
  def self.start_peer(name,ext_name,manager_port,ext_port,peer=nil)
    if name=='MANAGER'
      launch(ext_name,manager_port,ext_port) if !ext_name.nil?
      server = TCPServer.new(manager_port.to_i+1)
      b = wait_for_acknowledgment(server,ext_port)
      if peer
        peer.active=true
        peer.save
      end
      return b
    end
    WLLogger.logger.warn "Non-manager peer is trying to spawn a new peer"
    false
  end

  #This method is used by the manager.
  def self.launch(username,manager_port,port,server_type=:thin)
    cmd =  "rails server -p #{port} -u #{username} -m #{manager_port}"
    #    child_pid=fork do
    #      exec cmd
    #    end
    child_pid = Process.spawn cmd
    child_pid
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
    pids.each do |pid|
      #system "kill -TERM #{pid}"
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
  def self.reachable?(url)
    if local?(url)
      true
    else
      begin
        Timeout::timeout(1) do
          s = TCPSocket.new(url,80)
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
    #Checks if the peer object receives is valid
    unless peer.ip && peer.port && peer.username
      return nil,false,false
    end

    #Compose URL
    url = "#{peer.protocol}://#{peer.ip}:#{peer.port}"

    #Check if url reachable.
    unless reachable?(url)
      return nil,false,false
    end

    #We know that the server is accessible
    accessible = true
    available = peer.active
    
    #If the peer is active we are done.
    if available
      return url,accessible,available
    end
    
    #The peer is inactive and we need to reboot it.
    Thread.new do
      WLLauncher.start_peer(ENV['USERNAME'],username,ENV['PORT'],root_port,peer)
    end
    
    return url,accessible,available    
  end
end