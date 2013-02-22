require 'yaml'
require 'active_support'
require 'active_record'
require './lib/wl_logger'

module Conf  
  @@init = true
  @@current_env = 'development'
  # Store in one object all the configuration related to this peer
  # + put :force => true in options to force reloading of conf
  # + put :rails_env => [test,development,production] to change environment of configuration files
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
      @@peer = read_yaml_file 'config/peer.yml', @@current_env
      @@db = read_yaml_file 'config/database.yml', @@current_env
      # store all parameter for manager db usefull for peer that change database
      @@db['manager_db']=@@db.clone
      @@env = {}
      
      # setup username from env or conf file
      if ENV['USERNAME'].nil?
        if @@peer['peer']['username'].nil?
          WLLogger.logger.error "Variable ENV['USERNAME'] must not be nil or the peername should be set in peer.yml peer:username"
        else
          @@env['USERNAME'] = @@peer['peer']['username']
        end
      else
        @@env['USERNAME'] = ENV['USERNAME']
      end

      # setup port from env or conf file
      if ENV['PORT'].nil?
        if @@peer['peer']['web_port'].nil?
          WLLogger.logger.error "Variable ENV['PORT'] must not be nil or the port for the current peer should be set in peer.yml peer:web_port"
        else
          @@env['PORT'] = @@peer['peer']['web_port']
        end
      else
        @@env['PORT'] = ENV['PORT']
      end      
      
      if @@env['USERNAME'] == 'manager'
        @@manager = true        
      else
        @@manager = false        
        # Special config for regular peers
        # Change default db and 
        Conf.db['database']="wp_#{Conf.env['USERNAME']}"
      end

      # setup manager port from env or conf file of nil is OK if it is itself the manager
      if ENV['MANAGER_PORT'].nil?
        if @@peer['manager']['manager_port'].nil?
          if @@manager
            @@env['MANAGER_PORT'] = nil
          else
            WLLogger.logger.warn "the regular peer must have a pararameter MANAGER_PORT"
          end
        else
          @@env['MANAGER_PORT'] = @@peer['manager']['manager_port']
        end
      else
        @@env['MANAGER_PORT'] = ENV['MANAGER_PORT']
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
  
  # This methods reads our Yaml configuration and return the corresponding hash
  #
  # rails_env allow to return only the sub-hash that is concerned by the
  # subtree
  #
  def self.read_yaml_file(pathfile, rails_env)
    hash = YAML.load_file(pathfile)
    return hash[rails_env]
  end
end

## Big multi-dimensional hash with the content of yaml file properties.yml used
## to set up the database
#module PeerConf
#  # Force to reread the config file
#  def self.read_prop_file(rails_env = ENV["RAILS_ENV"])
#    rails_env ||= 'development'
#    return YAML.load_file('./config/properties.yml')[rails_env]
#  end
#  def self.config
#    @@config ||= {}
#  end
#  #  def self.config=(hash)
#  #    @@config = hash
#  #  end
#  def self.init
#    @@config ||= PeerConf.read_prop_file
#    @@config
#  end
#end
#
#module DBConf
#  def self.read_prop_file(rails_env = ENV["RAILS_ENV"])
#    rails_env ||= 'development'
#    return YAML.load_file('./config/database.yml')[rails_env]
#  end
#  def self.config
#    @@config ||= {}
#  end
#  def self.init
#    @@config ||= DBConf.read_prop_file
#    @@config
#  end
#end
#
## Relate here all the parameter linked to a specific user
##
#module UserConf
#  def self.config
#    @@config ||= {}
#  end
#
#  #  def self.config=(hash)
#  #    @@config.merge! hash
#  #  end
#
#  def self.init(hash)
#    @@config ||= hash
#    @@config
#  end
#end

# General usefull tool for ruby
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
end

module Network

  SOCKET_MAX_PORT = 65535
  SOCKET_PORT_INVALID = -1
  # This method returns true if the given port is available
  #
  def self.port_available?(ip, port)
    begin
      Timeout::timeout(1) do
        begin
          test_open_port = TCPServer.new(ip, port)
          test_open_port.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => error
          WLLogger.logger.info error.inspect
          return false
        rescue => error
          WLLogger.logger.error error.inspect
          return false
        end
      end
    end
    return false
  end

  
  def self.find_port
    
  end

  # This method return the smallest port number in a range of available ports
  # large enough for our purposes. This number is called the root port number.
  # If no such number can be found, this returns an invalid port.
  #
  # TODO: this looks for adjacent port number only, relax to return a list of
  # ports
  #
  def self.find_ports(ip, number_of_ports_required, root_port)
    root_port = Integer(root_port)
    number_of_ports_required = Integer(number_of_ports_required)
    if root_port + number_of_ports_required > SOCKET_MAX_PORT
      WLLogger.logger.error "not enough port number SOCKET_MAX_PORT=#{SOCKET_MAX_PORT} and you try #{root_port+number_of_ports_required}"
      return SOCKET_PORT_INVALID
    end
    increment = 0
    port_range_usable = true
    while increment < number_of_ports_required and port_range_usable do
      if !port_available?(ip,root_port+increment)
        port_range_usable = false
        WLLogger.logger.info "Address:port #{ip}:#{root_port+number_of_ports_required} required but impossible to use"
      end
      increment += 1
    end
    if port_range_usable
      root_port
    else
      # look for the next possible free port range
      find_ports(ip,number_of_ports_required,root_port+increment)
    end
  end
end

module PostgresHelper

  def self.db_exists? db_name
    #conn = PGconn.new('localhost', 5432, '', '', db_name, db_username, "") # to use when password needed
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
  end

  # Create the manager db as a child of postgres db
  def self.create_manager_db db_name
    # if there is no database for the manager you should create one
    unless PostgresHelper.db_exists?(db_name)
      ActiveRecord::Base.establish_connection adapter:'postgresql', username:'postgres', password:'', database:'postgres'
      ActiveRecord::Base.connection.create_database db_name
    end
  end

  # Create the regular peer db as a child of the manager db
  def self.create_user_db db_name
    # if there is no database for the peer you should create one
    unless PostgresHelper.db_exists?(db_name)
      ActiveRecord::Base.establish_connection Conf.db['manager_db']
      ActiveRecord::Base.connection.create_database db_name
    end
  end
end