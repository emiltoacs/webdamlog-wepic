# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'lib/wl_launcher'
require 'yaml'
require 'sqlite3'
require 'lib/wl_logger'

module WLSetup
  
  def self.get_peer_ports_from_account(db_type=:sqlite3)
    rs=[]
    case db_type
    when :sqlite3
      begin
        database = SQLite3::Database.open "db/database_MANAGER.db"
        stm = database.prepare "select port from accounts"
        rs = stm.execute
      rescue SQLite3::Exception => e
        WLLogger.logger.info e.inspect
      end
    end
    rs
  end  
  
  #The dbsetup method is used for clean up the database environment in case, for
  #instance, of a database reset, or if the manager database is missing.
  #TODO : dbsetup should also check the consistency between the databases present
  #and those that are cited in the account table for the manager database.
  #
  def self.dbsetup(db_type)
    case db_type
    when :sqlite3
      admin_present = false
      `ls -la db/*.db`.split("\n").each do |line|
        if line.split(" ").last.include?("database_MANAGER.db")
          #Do nothing, admin db is already present.
          admin_present=true;
        end
      end
      if !admin_present
        #Remove all .db files
        system 'rm db/*.db'
        WLLogger.logger.info "database_MANAGER.db file absent. Recreating database..."
        #Migrate the db appropriately
        system 'bundle exec rake db:migrate'
        WLLogger.logger.info "Database migrated."
      end
    end
  end
  
  #The argsetup method is used for preliminary setup (before conventional rails
  #setup is done) to take care of wepic-specific options given to the rails commandline
  #command.
  #
  def self.argsetup(args)
    properties = YAML.load_file('config/properties.yml')
    user_opt_index = args.index('-u')
    port_opt_index = args.index('-p')
    reset_opt_index = args.index('--reset')
    
    #The username is stored as an environment variable, as we do not know the name
    #of the users created beforehand.
    #
    ENV['USERNAME'] = args[user_opt_index+1].upcase if (user_opt_index)
    2.times { args.delete_at(user_opt_index)} if user_opt_index
    
    #The port is not other available everywhere in Rails, this is why it is added
    #as an environment variable here (if the -p option is chosen)
    #
    
    
    #Default values for username
    ENV['USERNAME'] = 'MANAGER' if ENV['USERNAME'].nil?
    
    #Port setup
    ENV['PORT'] = args[port_opt_index+1] if (port_opt_index)
    if port_opt_index.nil?
      ENV['PORT'] = properties['communication']['manager_port'].to_s 
      args.push('-p')
      args.push(ENV['PORT'])
      port_opt_index=args.size-2
    end
    #Generate a pid file
    args.push('-P')
    args.push("tmp/pids/#{ENV['USERNAME']}.pid")    
    
    #Ports and pids are not wanted in the args array if not running a server
    if args[0]!='s' && args[0]!='server'
      2.times {args.pop}
      2.times {args.delete_at port_opt_index}
    end
    
    # The reset switch has been used if reset_opt_index is true (i.e. is not
    # nil).
    #
    # TODO Maybe you want to end the rails initialization. It is not expected to
    # launch a new server while you type reset
    #
    if reset_opt_index
      WLLogger.logger.info "Killing all of the peers launched that are remaining"
      get_peer_ports_from_account.each do |peer_port|
        WLLogger.logger.info "Peer at port #{peer_port} killed."
        WLLauncher.exit_server(peer_port)
      end
      WLLogger.logger.info "Reset option has been chosen. Removing the database_MANAGER.db file. This will cause a reset of the system."
      system 'rm db/database_MANAGER.db'
      args.delete_at(reset_opt_index)
    end
    
    
    if  ENV['USERNAME']=='MANAGER'
      WLLogger.logger.info "Server is a WLInstance Manager."
      dbsetup(:sqlite3)
    else
      WLLogger.logger.info "Server is a WLInstance."
      #The manager_port option is only available on non-manager peers.
      #There is no default value for the MANAGER_PORT variable.
      mport_opt_index = args.index('-m')
      if mport_opt_index
        ENV['MANAGER_PORT'] = args[mport_opt_index+1]
        2.times {args.delete_at(mport_opt_index)}
      end
    end
    WLLogger.logger.info "#{ENV['USERNAME']} is running Wepic on port #{ENV['PORT']}"
  end
  
end
