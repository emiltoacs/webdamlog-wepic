require 'yaml'
require 'active_support'

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
