# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'socket'
require 'timeout'
require 'set'
require 'pty'
require 'lib/wl_logger'

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

  # TODO keep the id of the child process launched to kill properly
  def self.start_peer(name,ext_name,manager_port,ext_port,account=nil)
    if name=='MANAGER'
        spawn_server(ext_name,manager_port,ext_port) if !ext_name.nil?
      server = TCPServer.new(manager_port.to_i+1)
      b = wait_for_acknowledgment(server,ext_port)
      if account
        account.active=true
        account.save
      end
      return b
    end
    false
  end
  
  #This method is used by the manager.
  def self.spawn_server(username,manager_port,port,server_type=:thin)
    cmd =  "rails server -p #{port} -u #{username} -m #{manager_port}"
    child_pid=fork do
      exec cmd
    end
    child_pid
  end
  
  #This method kills the wl server if it located on the same machine only
  #TODO: This is not a proper method to kill a server. Change this method to a
  #more central method: se the pid of child that can get in start_peer.
  #Moreover, we need the peer to be killed to be be able to perform some actions
  #and this cannot be done if we use signals to kill the peers.
  #
  def self.exit_server(port,type=:thin)
    pids = Set.new
    case type
    when :thin
      `ps -ef | grep rails`.split("\n").each_with_index do |line,i|
        line_tokens = line.split(" ")
        pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
      end    
    end
    pids.each do |pid|
      system "kill -9 #{pid}"
      WLLogger.logger.info "Process #{pid} killed"
    end
    pids.size
  end

  def self.port_open?(ip, port)
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
    end
    return false
  end
end
