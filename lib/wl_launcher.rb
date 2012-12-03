# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'set'

module WLLauncher
  def start_server(port)
    pid = fork do
        exec "/bin/bash -l -c \"rails server -p #{port}\""
    end
    Process.detach(pid)
    #This code does not check if call to rails failed. This operations requires interprocess communication.
    true
  end
  
  #This method kills the wl server if it located on the same machine only.
  def exit_server(port)
    pids = Set.new
    `ps -ef | grep rails`.split("\n").each_with_index do |line,i|
       line_tokens = line.split(" ")
       puts "line_tokens : #{line_tokens.inspect}"
       pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
    end
    pids.each do |pid|
      system "kill -9 #{pid}"
      puts "Process #{pid} killed"
    end
    pids.size
  end
end