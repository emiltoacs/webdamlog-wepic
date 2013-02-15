require 'yaml'
require 'active_support'

module Conf
  @@init = false
  @@current_env = Rails.env
  # Store in one object all the configuration related to this peer
  def self.init(rails_env='production')
    # if you change rails environment this allows you to reload configuration
    if @@current_env.nil? or @@current_env != rails_env
      @@current_env = rails_env
      @@init=false
    end
    # Reload configuration if needed
    unless @@init
      @@peer = read_yaml_file 'config/peer.yml', rails_env
      @@db = read_yaml_file 'config/database.yml', rails_env
      @@env = {}
      @@env['USERNAME'] = ENV['USERNAME']
      @@env['PORT'] = ENV['PORT']
      @@env['MANAGER_PORT'] = ENV['MANAGER_PORT']
      @@init = true
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

# Big multi-dimensional hash with the content of yaml file properties.yml used
# to set up the database
module PeerConf
  # Force to reread the config file
  def self.read_prop_file(rails_env = ENV["RAILS_ENV"])
    rails_env ||= 'development'
    return YAML.load_file('./config/properties.yml')[rails_env]
  end
  def self.config
    @@config ||= {}
  end
  #  def self.config=(hash)
  #    @@config = hash
  #  end
  def self.init
    @@config ||= PeerConf.read_prop_file
    @@config
  end
end

module DBConf
  def self.read_prop_file(rails_env = ENV["RAILS_ENV"])
    rails_env ||= 'development'
    return YAML.load_file('./config/database.yml')[rails_env]
  end
  def self.config
    @@config ||= {}
  end
  def self.init
    @@config ||= DBConf.read_prop_file
    @@config
  end
end

# Relate here all the parameter linked to a specific user
#
module UserConf
  def self.config
    @@config ||= {}
  end

  #  def self.config=(hash)
  #    @@config.merge! hash
  #  end

  def self.init(hash)
    @@config ||= hash
    @@config
  end
end

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

  # This method return the smallest port number in a range of available ports
  # large enough for our purposes. This number is called the root port number.
  # If no such number can be found, this returns an invalid port.
  #
  # TODO: this looks for adjacent port number only, relax to return a list of
  # ports
  #
  def self.find_ports(ip,number_of_ports_required,root_port)
    root_port = Integer(root_port)
    number_of_ports_required = Integer(number_of_ports_required)
    if root_port + number_of_ports_required > SOCKET_MAX_PORT
      WLLogger.logger.debug "not enough port number SOCKET_MAX_PORT=#{SOCKET_MAX_PORT} and you try #{root_port+number_of_ports_required}"
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