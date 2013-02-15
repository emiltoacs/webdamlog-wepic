root = File.expand_path('../../',  __FILE__)
require "#{root}/lib/wl_logger"
require "#{root}/lib/wl_tool"
require "#{root}/app/helpers/wl_launcher"
require 'sqlite3'
require 'pg'
require 'optparse'
require 'ostruct'

module WLSetup
  
  # If the manager has no database it erase all other database since it would
  # be old peer database not belonging to any known manager.
  #
  # TODO dbsetup should also check the consistency between the databases present
  # and those that are cited in the account table for the manager database.
  #
  def self.clean_orphaned_peer
    config = DBConf.init
    unless File.exists?(config["database"])
      Dir.foreach('db') do |file_name|
        if file_name=~/database_.*\.db/
          File.delete(File.join('db', file_name))
        end
      end
    end
  end

  def self.get_peer_ports_from_account(db_type=:postgres)
    rs=[]
    config = DBConf.init
    db_file = config["database"]
    if File.exists?(db_file)
      case db_type
      when :sqlite3
        begin
          database = SQLite3::Database.open db_file
          stm = database.prepare "select port from accounts"
          rs = stm.execute
        rescue SQLite3::Exception => e
          WLLogger.logger.info e.inspect
        end
      when :postgres
        conn = PGconn.open(:dbname => db_file)
        rs = conn.exec('select port from accounts')
        rs.flatten
      end
    else
      WLLogger.logger.info "no file for database for the manager"
    end
    rs
  end

  def self.reset_peer_databases
    WLLogger.logger.info "Killing all of the peers launched that are remaining"
    get_peer_ports_from_account.each do |peer_port|
      WLLogger.logger.info "Peer at port #{peer_port} killed."
      WLLauncher.end_peer(peer_port)
    end
    WLLogger.logger.info "Reset option has been chosen. Removing the database_MANAGER.db file. This will cause a reset of the system."
    if File.exists?("db/database_MANAGER.db")
      system 'rm db/database_MANAGER.db'
    else
      WLLogger.logger.info "db/database_MANAGER.db does not exists nothing. The manager has been already erased."
    end
  end

  # Parse the options given in the command line and modify it for subsequent
  # rails launch. Setup the PeerConf and DBConf object with the default value,
  # or the value found in the Yaml configuration file or in the command line.
  #
  def self.parse(argv)
    # Assign default value
    options = OpenStruct.new
    options.peername = "MANAGER"
    options.port = "4000"
    options.manager_port = nil
    # Parse from command line
    opts = OptionParser.new do |opt|
      # -u take a mandatory argument 
      opt.on("-uUSERNAME", "--username USERNAME",
        "Specify the user name for this peer, default is 'MANAGER'") do |username|
        options.username = username
      end      
      opt.on("-pPORT", "--portPORT", "give the port number on which this peer should listen") do |p|
        options.port = p
      end
      opt.on("--reset", "custom tasks used to remove all the database to start from scratch a new rails manager") do
        options.reset = true
      end
      opt.on("-m MPORT", "--manager-port MPORT", "give the port on which the manager is waiting your answer") do |mport|
        options.manager_port = mport
      end
    end
    opts.parse(argv)
    if options.reset
      WLLogger.logger.info "Reset the databases"
      reset_peer_databases
    else
      if options.username.nil? or options.username.upcase == 'MANAGER'
        WLLogger.logger.info "Setup a manager"
        clean_orphaned_peer
        argv.push('-p')
        argv.push(options.port)
      else
        WLLogger.logger.info "Setup a regular peer"
        unless options.manager_port.nil?
          pos = argv.index '-m'
          2.times {argv.delete_at pos}          
        end
      end
      # Setup environement TODO check if it can be removed: replace all ENV[] by
      # reads in this objects
      ENV['USERNAME'] = options.peername
      ENV['PORT'] = options.port
      ENV['MANAGER_PORT'] = options.manager_port 
    end
    options
  end

  #  # The argsetup method is used for preliminary setup (before conventional rails
  #  # setup is done) to take care of wepic-specific options given to the rails
  #  # command.
  #  #
  #  def self.argsetup(args)
  #
  #    user_opt_index = args.index('-u')
  #    port_opt_index = args.index('-p')
  #    reset_opt_index = args.index('--reset')
  #
  #    # The username is stored as an environment variable, as we do not know the
  #    # name of the users created beforehand.
  #    #
  #    ENV['USERNAME'] = args[user_opt_index+1].upcase if (user_opt_index)
  #    2.times { args.delete_at(user_opt_index)} if user_opt_index
  #
  #    # The port is not other available everywhere in Rails, this is why it is
  #    # added as an environment variable here (if the -p option is chosen)
  #    #
  #    properties = PeerConf.init
  #    database = DBConf.init
  #
  #    # Default values for username
  #    ENV['USERNAME'] = 'MANAGER' if ENV['USERNAME'].nil?
  #
  #    # Port setup
  #    ENV['PORT'] = args[port_opt_index+1] if (port_opt_index)
  #    if port_opt_index.nil?
  #      ENV['PORT'] = properties['communication']['manager_port'].to_s
  #      args.push('-p')
  #      args.push(ENV['PORT'])
  #      port_opt_index=args.size-2
  #    end
  #    # Generate a pid file
  #    # XXX seems useless, who is using it ?
  #    args.push('-P')
  #    args.push("tmp/pids/#{ENV['USERNAME']}.pid")
  #
  #    #Ports and pids are not wanted in the args array if not running a server
  #    if args[0]!='s' && args[0]!='server'
  #      2.times {args.pop}
  #      2.times {args.delete_at port_opt_index}
  #    end
  #
  #    # The reset switch has been used if reset_opt_index is true (i.e. is not
  #    # nil).
  #    # TODO change that for a rake task instead of custom filter
  #    #
  #    if reset_opt_index
  #      reset_peer_databases
  #      args.delete_at(reset_opt_index)
  #    end
  #
  #    if  ENV['USERNAME']=='MANAGER'
  #      WLLogger.logger.info "Setup a manager"
  #      clean_orphaned_peer
  #    else
  #      WLLogger.logger.info "Setup a peer"
  #      #The manager_port option is only available on non-manager peers.
  #      #There is no default value for the MANAGER_PORT variable.
  #      mport_opt_index = args.index('-m')
  #      if mport_opt_index
  #        ENV['MANAGER_PORT'] = args[mport_opt_index+1]
  #        2.times {args.delete_at(mport_opt_index)}
  #      end
  #    end
  #    WLLogger.logger.info "#{ENV['USERNAME']} will be started on port #{ENV['PORT']}"
  #  end
end