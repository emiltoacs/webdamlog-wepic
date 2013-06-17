require 'yaml'
require 'active_support'
require 'active_record'
require './lib/wl_logger'
require './lib/monkey_patch'

module Conf  
  @@init = false
  @@current_env = ENV["RAILS_ENV"] || 'development'
  # Store in one object all the configuration related to this peer
  # * :force=> true in options to force reloading of conf
  # * :rails_env => [test,development,production] to change environment of
  #   configuration files
  # * :ymlconf => path_to_conf to specify a custom path to scenarios
  #
  def self.init(options={})
    options[:force] ||= false
    @@init=false if options[:force]
    # if you change rails environment this allows you to reload configuration
    options[:rails_env] ||= @@current_env
    if options[:rails_env] != @@current_env
      @@current_env = options[:rails_env]
      @@init=false
    end
    # Reload configuration if needed
    unless @@init
      path_to_conf = options[:ymlconf] ||= 'config'
      if !File.exists? path_to_conf
        if defined?(Rails) and File.exists?( File.join(Rails.root, path_to_conf) )
          path_to_conf = File.join(Rails.root, path_to_conf)
        else          
          path_to_conf = 'config'
          WLLogger.logger.warn "custom path to config file does not exists fall back to default #{path_to_conf}"
        end
      end      
      @@peer = read_yaml_file File.join(path_to_conf, 'peer.yml'), @@current_env
      @@db = read_yaml_file 'config/database.yml', @@current_env
      # store all parameter for manager db useful for regular peer that change
      # database
      @@db['manager_db']=@@db.clone
      @@env = {}
      
      # setup username from env or conf file
      if ENV['USERNAME'].nil?
        if @@peer['peer']['username'].nil?
          # #WLLogger.logger.warn "No name for the peer in ENV['USERNAME'] or in
          # peer.yml peer:username hence it will launch a manager"
          WLLogger.logger.fatal "Variable ENV['USERNAME'] must not be nil or the peername should be set in peer.yml peer:username"
          # #@@env['USERNAME'] = 'manager' #@@peer['peer']['username'] =
          # 'manager'
        else
          @@env['USERNAME'] = @@peer['peer']['username']
        end
      else
        @@env['USERNAME'] = ENV['USERNAME']
        @@peer['peer']['username'] = @@env['USERNAME']
      end
      
      # setup port from env or conf file
      if ENV['PORT'].nil?
        if @@peer['peer']['web_port'].nil?
          WLLogger.logger.fatal "Variable ENV['PORT'] must not be nil or the port for the current peer should be set in peer.yml peer:web_port"
        else
          if @@peer['peer']['web_port'].is_i?
            @@env['PORT'] = @@peer['peer']['web_port']
          else
            WLLogger.logger.fatal "web_port #{@@peer['peer']['web_port']} is not an integer"
          end
        end
      else
        if ENV['PORT'].is_i?
          @@env['PORT'] = ENV['PORT']
          @@peer['peer']['web_port'] = @@env['PORT']
        else
          WLLogger.logger.fatal "port in ENV['PORT'] #{ENV['PORT']} is not an integer"
        end
      end

      # define manager
      if @@env['USERNAME'] == 'manager'
        @@manager = true
      else
        @@manager = false
        # Special config for regular peers Change default db
        @@db['database']="wp_#{@@env['USERNAME']}"
      end
      
      # Setup manager port from env or conf file. Nil is OK if the peer as been
      # run as a stand-alone (ie. not launched via the manager interface). This
      # will be copied from peer:web_port if it is itself a manager.
      mport = ENV['MANAGER_PORT'] if ENV['MANAGER_PORT'].is_i?
      if mport.nil?
        mport = @@peer['manager']['manager_port'] if not @@peer['manager'].nil? and @@peer['manager']['manager_port'].is_i?
        if mport.nil?
          if @@manager
            @@env['MANAGER_PORT'] = @@env['PORT']
            @@standalone = false
          else
            @@standalone = true
            WLLogger.logger.info "a new peer in standalone mode is launched"
          end
        else
          @@env['MANAGER_PORT'] = mport
          @@standalone = false
        end
      else
        @@env['MANAGER_PORT'] = mport
        @@peer['manager']['manager_waiting_port'] = @@env['MANAGER_PORT']
        @@peer['manager']['manager_port'] = 4000 unless @@peer['manager']['manager_port'] #Manager port defaults to 4000
        @@standalone = false
      end

      @@init = true
      
    end # end unless init    
  end # end def self.init

  def self.manager?
    unless @@init
      self.init
    end
    @@manager
  end
  def self.standalone?
    unless @@init
      self.init
    end
    @@standalone
  end
  def self.peer
    unless @@init
      self.init
    end
    @@peer
  end
  def self.db
    unless @@init
      self.init
    end
    @@db
  end
  def self.env
    unless @@init
      self.init
    end
    @@env
  end
  def self.current_env
    @@current_env
  end
  
  # This methods reads our Yaml configuration and return the corresponding hash
  #
  # rails_env allow to return only the sub-hash that is concerned by the subtree
  #
  def self.read_yaml_file(pathfile, rails_env)
    hash = YAML.load_file(pathfile)
    return hash[rails_env]
  end
end

# General useful tools for ruby
#
module WLTool
    
  def create_class(class_name, superclass, &block)
    klass_name = class_name.classify
    klass = Class.new superclass, &block
    Object.const_set klass_name, klass
  end

  def delete_class(klass)
    Object.class_eval do
      unless klass.name.nil?
        if const_defined?(klass.name) and const_defined?(klass.name.to_sym)
          remove_const(klass.name.to_sym)
        end
      end
    end
  end
  
  # Test if the class class_name of type klass exists in the current ObjectSpace
  # and return the class object if it exists
  #
  def self.class_exists(class_name, klass = Module)
    cl = Module.const_get(class_name)
    if cl.is_a?(Class) and cl.ancestors.include? klass
      return cl
    end
  rescue NameError
    return nil
  end

  # Sanitize the string ie. + Remove leading and trailing whitespace + Downcase
  # + Replace internal space by _ + Remove " or '
  #
  def self.sanitize(string)
    str = string.strip.downcase
    ['"', "'", "."].each do |c|
      str.delete!(c)
    end
    str = str.gsub(/\s+/, '_')
    return str
  end

  # Sanitize the string ie. + Remove leading and trailing whitespace + Downcase
  # + Replace internal space by _ + Remove " or '
  #
  def self.sanitize!(string)
    string.strip!
    string.downcase!
    ['"', "'", "."].each do |c|
      string.delete!(c)      
    end
    string.gsub!(/\s+/, '_')
    return string
  end

  # Work under UNIX, special signal 0 send nothing but return errors if any
  def self.pid_exists? (pid)
    system "kill -0 #{pid}"
    return $? == 0
  end
end # module WLTool

module Network

  SOCKET_MAX_PORT = 65535
  SOCKET_PORT_INVALID = -1
  # This method returns true if the given port is available
  #
  def self.port_available?(ip, port, protocol=:TCP)
    begin
      Timeout::timeout(1) do
        begin
          case protocol
          when :TCP
            test_open_port = TCPServer.new(ip, port)
            if test_open_port
              test_open_port.close
              return true
            else
              return false
            end
          when :UDP
            test_open_port = UDPSocket.new
            test_open_port.bind ip, port
            if test_open_port
              test_open_port.close
              return true
            else
              return false
            end
          end                    
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => error
          WLLogger.logger.info error.inspect
          return false
        end
      end
    rescue Timeout::Error, StandardError => error
      WLLogger.logger.fatal error.inspect
      return false
    end
    return false
  end

  # Return an open port for the given protocol
  def self.find_port(ip='localhost', protocol=:TCP)
    case protocol

    when :TCP
      begin
        Timeout::timeout(1) do
          socket = TCPServer.new ip, 0
          addr = socket.local_address # the addrinfo struct of this socket
          socket.close
          return addr.ip_port
        end
      rescue Timeout::Error, StandardError => error
        WLLogger.logger.fatal error.inspect
        return nil
      end
      
    when :UDP
      begin
        Timeout::timeout(1) do
          socket = UDPSocket.new
          socket.bind ip, 0
          addr = socket.local_address # the addrinfo struct of this socket
          socket.close
          return addr.ip_port
        end
      rescue Timeout::Error, StandardError => error
        WLLogger.logger.fatal error.inspect
        return nil
      end

    end # case
  end # find_port

  # This method return the smallest port number in a range of available ports
  # large enough for our purposes. This number is called the root port number.
  # If no such number can be found, this returns an invalid port.
  #
  # TODO: this looks for adjacent port number only, relax to return a list of
  # ports
  #
  def self.find_ports(ip, number_of_ports_required, port)
    port = Integer(port)
    number_of_ports_required = Integer(number_of_ports_required)
    if port + number_of_ports_required > SOCKET_MAX_PORT
      WLLogger.logger.fatal "not enough port number SOCKET_MAX_PORT=#{SOCKET_MAX_PORT} and you try #{port+number_of_ports_required}"
      return SOCKET_PORT_INVALID
    end
    increment = 0
    port_range_usable = true
    while increment < number_of_ports_required and port_range_usable do
      if !port_available?(ip,port+increment)
        port_range_usable = false
        WLLogger.logger.info "Address:port #{ip}:#{port+number_of_ports_required} required but impossible to use"
      end
      increment += 1
    end
    if port_range_usable
      port
    else
      # look for the next possible free port range
      find_ports(ip,number_of_ports_required,port+increment)
    end
  end
end # end module Network


module PostgresHelper

  def self.db_exists? db_name
    # #conn = PGconn.new('localhost', 5432, '', '', db_name, db_username, "") #
    # to use when password needed
    conn = PGconn.open(:dbname => 'postgres', :user => 'postgres')
    sql = "select count(1) from pg_catalog.pg_database where datname = '#{db_name}'"
    rs = conn.exec(sql)
    database_cpt = rs.first['count']
    database_cpt = database_cpt.to_i
    if database_cpt == 0
      return false
    else
      return true
    end
    conn.close
  end

  # Create the manager db as a child of postgres db
  def self.create_manager_db config={'adapter'=>'postgresql', 'username'=>'postgres', 'password'=>'', 'database'=>'postgres'}
    # if there is no database for the manager you should create one
    unless PostgresHelper.db_exists?(Conf.db['manager_db']['database'])
      ActiveRecord::Base.establish_connection({'adapter'=>'postgresql', 'username'=>'postgres', 'password'=>'', 'database'=>'postgres'})
      ActiveRecord::Base.connection.create_database Conf.db['manager_db']['database']
    end
  end

  # Create the regular peer db as a child of the manager db
  def self.create_user_db config={'adapter'=>'postgresql', 'username'=>'wepic', 'password'=>'', 'database'=>'wepic'}
    # if there is no database for the peer you should create one
    unless PostgresHelper.db_exists?(config['database'])
      ActiveRecord::Base.establish_connection Conf.db['manager_db']
      ActiveRecord::Base.connection.create_database config['database']
    end
  end
end # module PostgresHelper

module SampleHelper
  #FIXME This sample helper has become obsolete
  def self.wepic_create
      # if defined?(Conf) #and Conf.env['USERNAME']!='manager'
        # WLLogger.logger.debug "Samples added for user #{Conf.env['USERNAME']} : #{Conf.db['sample_content']}"
        # sample_content_file_name = "#{Rails.root}/config/scenario/samples/#{Conf.env['USERNAME']}_sample.yml"
        # if (File.exists?(sample_content_file_name))
          # content = YAML.load(File.open(sample_content_file_name))
          # WLLogger.logger.info "Load sample specification from yaml file"
          # content['contacts'].values.each do |contact|
            # #We should check if users are online using Webdamlog rules.
            # Contact.new(:username=>contact['name'],:peerlocation=>contact['peerlocation'],:online=>false,:email=>contact['email'],:facebook=>contact['facebook']).save
          # end unless content['contacts'].values.nil?
          # content['pictures'].values.each do |picture|
            # owner = if picture['owner'] then picture['owner'] else Conf.env['USERNAME'] end
            # Picture.new(:image_url=>picture['url'],:owner=>owner,:title=>picture['title']).save
          # end unless content['pictures'].values.nil?
          # content['locations'].values.each do |imagelocation|
            # owner = if imagelocation['owner'] then imagelocation['owner'] else Conf.env['USERNAME'] end
            # Picture.where(:title=>imagelocation['title'],:owner=>owner).first.located = imagelocation['location']
          # end unless content['locations'].values.nil?
          # content['ratings'].values.each do |rating|
            # owner = if rating['owner'] then rating['owner'] else Conf.env['USERNAME'] end
            # Picture.where(:title=>rating['title'],:owner=>owner).first.rated = rating['rating']
          # end unless content['ratings'].values.nil?
          # content['comments'].values.each do |comment|
            # owner = if comment['owner'] then comment['owner'] else Conf.env['USERNAME'] end
            # picture = Picture.where(:title=>comment['title'],:owner=>owner).first
            # Comment.insert(:_id=>picture._id,:text=>comment['text'],:author=>comment['author']) if picture
          # end
        # else
          # raise "file #{sample_content_file_name} does not exist!"
        # end
      # else
      # raise "The Conf object has not been setup!"
      # end
  end
  
  def self.query_create
    if defined?(Conf) #and Conf.env['USERNAME']!='manager'
      WLLogger.logger.debug "Query Samples for user : #{Conf.env['USERNAME']}"
      sample_content_file_name = "#{Rails.root}/config/scenario/samples/query/sample.yml"
      if (File.exists?(sample_content_file_name))
        content = YAML.load(File.open(sample_content_file_name))
        content['described_rules'].values.each do |drule|
          DescribedRule.insert(:wdlrule => drule['wdlrule'],:description => drule['description'])
        end
      else
        error = "File #{sample_content_file_name} does not exist!"
        WLLogger.logger.warn error
        raise error 
      end
    else
      error =  "The Conf object has not been setup!"
      WLLogger.logger.warn error
      raise error    
    end
  end          
end
