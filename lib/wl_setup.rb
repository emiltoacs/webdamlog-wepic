root = File.expand_path('../../',  __FILE__)
require "#{root}/lib/wl_logger"
require "#{root}/lib/wl_tool"
require "#{root}/lib/monkey_patch"
require "#{root}/app/helpers/wl_launcher"
require "#{root}/app/helpers/wl_database"
require 'sqlite3'
require 'pg'
require 'optparse'
require 'ostruct'


module WLSetup
  
  # If the manager has no database it erase all other database since it would be
  # old peer database not belonging to any known manager.
  #
  # TODO dbsetup should also check the consistency between the databases present
  # and those that are cited in the account table for the manager database.
  #
  def self.clean_orphaned_peer
    config = Conf.db
    case config['adapter']
    when 'sqlite3'
      unless File.exists?(config["database"])
        Dir.foreach('db') do |file_name|
          if file_name=~/database_.*\.db/
            File.delete(File.join('db', file_name))
          end
        end
      end
    when 'postgres'
      
    end
  end

  def self.get_peer_ports_from_account(db_type='postgresql')
    rs=[]
    Conf.init
    db_name = Conf.db["database"]
    case db_type
    when 'sqlite3'
      if File.exists?(db_name)
        begin
          database = SQLite3::Database.open db_name
          stm = database.prepare "select port from accounts"
          rs = stm.execute
        rescue SQLite3::Exception => e
          WLLogger.logger.info e.inspect
        end
      else
        WLLogger.logger.info "no file for database for the manager"
      end
    when 'postgresql'
      conn = PGconn.open(:dbname => db_name)
      rs = conn.exec('select port from accounts')
      rs.flatten
    end
    rs
  end

  # Clean all database and reset the database given in parameter, usually the
  # manager.
  #
  def self.reset_peer_databases db_name, db_username, db_adapter
    case db_adapter
    when 'sqlite3'
      WLLogger.logger.info "Killing all of the peers launched that are remaining"
      get_peer_ports_from_account.each do |peer_port|
        WLLogger.logger.info "Peer at port #{peer_port} killed."
        WLLauncher.end_peer(peer_port)
      end
      WLLogger.logger.info "Reset option has been chosen for sqlite3. Removing the #{db_name} file. This will cause a reset of the system."
      if File.exists?("#{db_name}")
        system 'rm #{db_name}'
      else
        WLLogger.logger.info "#{db_name} does not exists nothing. The manager has been already erased."
      end
    when 'postgresql'
      WLLogger.logger.info "You start a cleanup of the postgres database server"
      PostgresHelper.create_manager_db
      PostgresHelper.create_user_db Conf.db
      conn = PGconn.open(:dbname => db_name, :user => db_username)

      # now you can drop all other databases
      sql2=<<-END
SELECT
  pg_database.datname AS name
FROM
  pg_catalog.pg_database
WHERE
  pg_database.datname != 'wp_manager' AND
  pg_database.datname != 'postgres' AND
  pg_database.datistemplate = false;
      END
      rs = conn.exec(sql2)
      rs.each do |t|
        sqldrop = "DROP DATABASE #{t['name']}"
        begin
          rs = conn.exec(sqldrop)
          p "#{sqldrop} succeed"
        rescue PG::Error => err
          p "Wepic Warning #{err.inspect}"
        end
      end

      # and now clean the database of the manager
      ddl_query=<<-END
SELECT
  'drop table if exists "' || tablename || '" cascade;' AS a
FROM
  pg_tables
WHERE
  schemaname = 'public';
      END
      dropper = []
      rs = conn.exec(ddl_query)
      p "Clean the database #{db_name} of #{db_username}"
      rs.each do |t|
        dropper << t['a']
      end
      dropper.each do |d|
        p d
        conn.exec d
      end
    end
    
    #Cleanup the rule_dir directory
    cleanup_cmd = "rm -rf #{File.expand_path File.dirname(__FILE__)}/../tmp/rule_dir/* && rm -rf #{File.expand_path File.dirname(__FILE__)}/webdamlog/wlrule_to_bud/*"
    system cleanup_cmd
  end

  # Parse the options given in the command line and modify it for subsequent
  # rails launch. Setup the Conf object with the default value (manager, 4000),
  # or the value found in the Yaml configuration file or in the command line.
  #
  def self.parse!(argv)
    # Assign default value
    options = OpenStruct.new
    #options.peername = "manager"
    #options.port = "4000"
    options.peername = nil
    options.port = nil
    options.debug = false
    options.manager_port = nil
    # Parse from command line
    opts = OptionParser.new do |opt|
      opt.banner = "Usage: rails s [options]"
      # -U take a mandatory argument, do not use -u since it is used by the
      # server after for debug flag
      opt.on("-U", "--username USERNAME",
        "Specify the user name for this peer, default is '#{options.peername}'") do |username|
        options.peername = username
      end
      opt.on("-p", "--port PORT", "give the port number on which this peer should listen") do |p|
        options.port = p
      end
      opt.on("--reset", "custom tasks used to remove all the database to start from scratch a new rails manager") do
        options.reset = true
      end
      opt.on("-m", "--manager-port MPORT", "give the port on which the manager is waiting your answer") do |mport|
        options.manager_port = mport
      end
      opt.on("-C", "--ymlconf path", "if not specified the default is config/") { |path| options.ymlconf = path }
      # options for server: see rails/commands/server
      opt.on("-b", "--binding=ip", String,
        "Binds Rails to the specified ip.", "Default: 0.0.0.0") { |v| options.Host = v }
      opt.on("-c", "--config=file", String,
        "Use custom rackup configuration file") { |v| options.config = v }
      opt.on("-d", "--daemon", "Make server run as a Daemon.") { options.daemonize = true }
      opt.on("-u", "--debugger", "Enable ruby-debugging for the server.") { options.debugger = true }
      opt.on("-e", "--environment=name", String,
        "Specifies the environment to run this server under (test/development/production).",
        "Default: development") { |v| options.environment = v }
      opt.on("-P","--pid=pid",String,
        "Specifies the PID file.",
        "Default: tmp/pids/server.pid") { |v| options.pid = v }
    end
    
    # All the options parsed previously are removed from the ARGV parameter tab
    # only -p for port is useful for server
    #
    opts.parse(argv)
    start_server = true
    
    if options.reset
      
      ENV['USERNAME'] = options.peername
      ENV['PORT'] = options.port
      ENV['MANAGER_PORT'] = options.manager_port
      Conf.init({force: true})
      start_server = false
      WLLogger.logger.info "Reset the databases"
      reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']

    else # continue to rails/command

      # setup kind of peer: will be stored in Conf
      #      if options.peername.nil? or options.peername.downcase == 'manager'
      #        WLLogger.logger.info "Setup a manager"
      #        options.peername = 'manager'
      #      else
      #        WLLogger.logger.info "Setup a regular peer"
      #      end
      # setup this environment variable are useful to avoid Conf file to fail
      # when loading
      ENV['USERNAME'] = options.peername
      ENV['PORT'] = options.port
      ENV['MANAGER_PORT'] = options.manager_port
      Conf.init({force: true, ymlconf: options.ymlconf })

      if Conf.peer['peer']['username'].downcase == 'manager'
        WLLogger.logger.info "Setup a manager"
      else
        WLLogger.logger.info "Setup a regular peer"
      end

      if argv[0] == 'server' or argv[0] == 's'
        start_server = true
        # purge custom options from command line for rails server
        ['-U', '--username', '-m', '--manager-port', '-C', '--ymlconf'].each do |switch|
          id = argv.index(switch)
          unless id.nil?
            2.times{argv.delete_at id}
          end
        end

        # push switch -p to specify the port the rake server will use
        inter = ['-p', '--port'] & ARGV
        if inter.empty?
          argv.push '-p'
          argv.push Conf.peer['peer']['web_port'].to_s
        end
        # setup the pid file
        argv.push('-P')
        argv.push("tmp/pids/#{Conf.peer['peer']['username']}.pid")

        clean_orphaned_peer if Conf.manager?
        setup_storage Conf.manager?, Conf.db
      end # end if server
      
    end # end if options.reset

    return start_server, options
  end

  # Use to create database before loading model, default db_config creates a
  # postgres database for the super user postgres
  #
  def self.setup_storage manager, db_config
    if manager
      PostgresHelper.create_manager_db  db_config
    else
      PostgresHelper.create_user_db db_config
    end
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
  #      ENV['PORT'] = properties['manager']['manager_port'].to_s
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