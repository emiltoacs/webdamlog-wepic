require "./lib/wl_logger"
require 'socket'
require 'timeout'
require 'set'

# Define some methods to launch and manage new peers spawned by the manager
module WLLauncher
  
  # This method is responsible for giving the order to create a peer. It returns
  # the newly created active record for the peer as well as if the creation
  # process has been successful.
  #
  def self.create_peer(username, ymlconf=nil,directory=nil)
    ip=Conf.peer['manager']['ip']
    # FIXME here I use the protocol of the local default peer conf file instead
    # of the possible ymlconf ; also check if protocol is really necessary
    protocol=Conf.peer['peer']['protocol']

    if peername_valid? username
      if ymlconf && ymlconf[Conf.current_env]['peer']['web_port'] #If web_port is configured for a scenario, we will use it.
        web_port = ymlconf[Conf.current_env]['peer']['web_port']
      else
        web_port = Network::find_port ip, :TCP
      end
      if web_port==Network::SOCKET_PORT_INVALID
        WLLogger.logger.warn "Webport #{web_port} specified in #{directory} is invalid."
        return nil, false, "port not available to deploy this peer for #{username}. Try to remove webport configuration from scenario configuration file in case of wl scenario."
      else
        # Create the peer active record
        peer = Peer.new(:username => username, :ip=> ip, :port => web_port, :active => false, :protocol => protocol)
        WLLogger.logger.debug "New peer record created with port #{web_port}..."
        if peer.save
          Thread.new do
            WLLogger.logger.debug "Start peer thread launching..."
            st, msg = WLLauncher.start_peer(username, web_port, peer, ymlconf, directory)
            WLLogger.logger.debug "Start peer thread launched..."
          end
          return peer, true, "peer starting"
        else
          return peer, false, "fail to save user #{username} in database because #{peer.errors.messages.inspect}"
        end
      end
    else # peername_valid? username is wrong
      return nil, false, "peername is invalid or this machine already has a peer named #{username}"
    end
  end # self.create_peer
  
  # Start a new peer or restart a peer <peer_record> saved in the db
  #
  def self.start_peer(new_peer_name, new_peer_port, peer_record, ymlconf=nil, directory=nil)
    #TODO : investigate why this code is buggy. In the meantime, use a randomly generated port.
    # unless ymlfconf.nil?
      # manager_waiting_port = ymlconf[Conf.current_env]['manager']['manager_waiting_port']
    # else
      # manager_waiting_port = Conf.peer['manager']['manager_waiting_port']
    # end
    #Tell the peer record it should set remote peer offline when manager shuts down
    at_exit do
      WLLogger.logger.info "Peer : #{peer_record.username}[#{peer_record.ip}:#{peer_record.port}] is shutting down..."
      peer_record.active = false
      peer_record.save
    end
    manager_waiting_port = Network.find_port Conf.peer['manager']['ip'], :TCP
    if manager_waiting_port.nil? or !Network.port_available?(Conf.peer['manager']['ip'], manager_waiting_port)
      manager_waiting_port = Network.find_port Conf.peer['manager']['ip'], :TCP
    end
    WLLogger.logger.debug "Manager waiting port #{manager_waiting_port} chosen.."    
    listener = TCPServer.new(manager_waiting_port)
    WLLogger.logger.debug "Listener Server created..."
    if Conf.manager?
      WLLogger.logger.debug "#{new_peer_name} : #{new_peer_port}"
      if !new_peer_name.nil? and !new_peer_port.nil?
        cmd = "rails server -p #{new_peer_port} -U #{new_peer_name} -m #{manager_waiting_port} -e #{ENV['RAILS_ENV']}"
        if !directory.nil?
          if File.exists?(directory) or File.exists?( File.join(Rails.root, directory) )
            cmd << " -C #{directory}"
          else
            WLLogger.logger.warn "you specified an invalid path for -C, --ymlconf #{File.join(Rails.root, directory)}"
          end
        else
          WLLogger.logger.debug "start a peer with default configuration file"
        end
        WLLogger.logger.debug "execute: #{cmd}"
        child_pid = Process.spawn cmd
      else
        WLLogger.logger.fatal "try to launch a new peer without username or port"
      end
      status, msg = wait_for_acknowledgment(listener,new_peer_port)
      if !peer_record.nil? and status
        peer_record.active = true
        peer_record.pid = child_pid
        peer_record.msg = msg
        peer_record.save
      else
        peer_record.active = false
        peer_record.pid = child_pid
        peer_record.msg = msg
        peer_record.save
      end
      return status, msg
    else
      msg = "The non-manager #{Conf.env['USERNAME']} peer is trying to spawn a new peer"
      WLLogger.logger.warn msg
      return false, msg
    end
    listener.close
    WLLogger.logger.debug "Listener closed..."
  end # start_peer
  
  def self.wait_for_acknowledgment(tcp_server_socket, new_peer_port)
    # listener = TCPServer.new(manager_waiting_port)
    if tcp_server_socket.is_a? TCPServer
      begin
        Timeout::timeout(5000) do
          begin
            client = tcp_server_socket.accept
            str = client.gets
            if str.include? new_peer_port.to_s
              client.close
              # listener.close
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
    else
      return false, "wrong type argument, tcp_server_socket is a #{tcp_server_socket.class} and must be TCPServer"
    end
  end # wait_for_acknowledgment
  
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
  end # end_peer
  
  # Check if URL specified is local.
  def self.local?(url)
    url.include?('localhost') || url.include?('127.0.0.1')
  end
  
  # Checks if specified URL is reachable from this peer.
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
    # Checks if the peer object received is valid
    unless peer.ip && peer.port && peer.username
      return nil,false,false
    end

    # Compose URL
    url = "#{peer.protocol}://#{peer.ip}:#{peer.port}"

    # Check if url reachable.
    if reachable?(url, peer.port)
      accessible = true
      available = peer.active
      # If the peer is active we are done.
      WLLauncher.start_peer(peer.username, peer.port, peer) unless available
      return url,accessible,available
    else
      return nil,false,false
    end
  end

  # A peer could be launched with the given peername if no previous peer with
  # this name has been launched previously on this machine.
  #
  # Check peer table for peer launched by this manager, then check tmp/pids for
  # peers launched in stand alone
  #
  def self.peername_valid?(peername)
    # exists? in the db
    peer_exists = Peer.where(:username => peername).first
    return false unless peer_exists.nil?

    # exists? in the list of process launched
    if Rails.nil?
      dirname = Dir.getwd.join('tmp','pids') # used if launched without rails
    else
      dirname = Rails.root.join('tmp','pids')
    end
    return false if File.exists?( File.join(dirname, peername, '.pid') )

    # this peer name is available
    return true
  end # peername_valid?
  
end