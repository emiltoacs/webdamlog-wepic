# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'socket'
require 'timeout'
require 'set'
require 'pty'

#This module manages the launch by the Wepic Manager of the different 
#Wepic peers.
#
module WLLauncher
  
  #The manager waits for his peer 
  #this method is blocking until it receives an answer.
  def wait_for_acknowledgment(server)
    begin
      Timeout::timeout(5) do
        begin
          #XXX in case servers connect simultaneously  
          client = server.accept
          Rails.logger.info client.gets
          client.close
          server.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          Rails.logger.info "Connection Error..."
          return false
        end        
      end
    rescue Timeout::Error
      Rails.logger.info "Time out..."
      return false
    end
  end
  
  #Retrieves an available server for acknowledgment.
  #This method returns an available port on which to hook
  #the acknowledgement sever. Also returns the server itself
  #
  def ack_server(manager_port)
    ack_port = manager_port.to_i+1
    server=nil
    while !server do
      begin
        server = TCPServer.new(ack_port)
      rescue Errno::EADDRINUSE,Errno::ECONNREFUSED
        ack_port = ack_port+1
      end
    end
    puts "Expecting ack at : #{ack_port}"
    return server, ack_port
  end
  
  #This method is not supposed to be used by webdamlog instance
  #XXX bug fix : make sure the redirection works even if port is already taken.
  #XXX only works for local host.
  def start_peer(name,ext_name,manager_port,ext_port,account=nil)
    puts "safety check : #{name}"
    if name=='MANAGER'
      #XXX What happens when several peers want to log on at the same time?
      #Need to add support to ensure acknowledgement are recognized properly if several
      #peers attempt to connect at the same time.
      server, ack_port = ack_server(manager_port)
      Rails.logger.info "Ack_port : #{ack_port}"
      unless ext_name.nil?
        thread = Thread.new do
          start_server(ext_name,ack_port,ext_port)
        end
      else
        Rails.logger.warn "Ext_name parameter is nil, this should only happen in a testing environment."
      end
      
      ack_received = wait_for_acknowledgment(server)
      if ack_received && account
        account.active=true
        account.save
      end
      return ack_received
    end
    false
  end  
  
  #This method is not supposed to be used by the manager, whose environment
  #variable MANAGER_PORT should be undefined (or nil).
  def send_acknowledgment(name,ack_port,port)
    puts "sending ack at : #{ack_port}"
    if name!='MANAGER'
      begin 
        socket = TCPSocket.open('localhost',ack_port.to_i)
        socket.puts "Port #{port} ready"
        socket.close
      rescue Errno::ECONNREFUSED 
        raise Errno::ECONNREFUSED
      end

      puts "Acknowledgment sent!"
    end
  end
  
  #This method starts the server the peer with given *username* will be
  #running on. Ack_port is the port on which the manager waits for a notification
  #from the peer that tells him he is ready.
  #
  #
  def start_server(username,ack_port,peer_port,server_type=:thin)
    cmd =  "rails server -p #{peer_port} -u #{username}"
    begin
      PTY.spawn(cmd) do |stdin,stdout,pid|
        begin
          stdin.each do |line|
            Rails.logger.info "Peer #{username}@localhost:#{peer_port} : " + line
            case server_type
            when :webrick
              if line.include?("pid=") && line.include?("port=")
                send_acknowledgment(username,ack_port,peer_port)
              end
            when :thin
              if line.include?("Listening on") && line.include?(", CTRL+C to stop")
                send_acknowledgment(username,ack_port,peer_port)
              end
            end
          end
          Rails.logger.info "PTY process has finished outputing. "
        rescue Errno::EIO
          Rails.logger.error "Peer has shut down. No longer listening to server output (IOError)"
        rescue Errno::ECONNREFUSED
          Rails.logger.error "Peer has shut down. No longer listening to server output (Connection Refused)"
        end
      end
    rescue PTY::ChildExited
      Rails.logger.info "Child process exited!"
    end
  end
  
  #This method kills the wl server if it located on the same machine only.
  def self.exit_server(port,type=:rails)
    pids = Set.new
    case type
    when :rails
      `ps -ef | grep rails`.split("\n").each_with_index do |line,i|
        line_tokens = line.split(" ")
        pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
      end
    when :faye
      `ps -ef | grep rackup`.split("\n").each_with_index do |line,i|
        line_tokens = line.split(" ")
        pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
      end      
    end
    pids.each do |pid|
      system "kill -9 #{pid}"
      Rails.logger.info "Process #{pid} killed"
    end
    pids.size
  end
  
  def port_open?(ip, port)
    begin
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end  
end
