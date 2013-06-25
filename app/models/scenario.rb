# These model implements the basic scaffold needed to start a scenario which
# usually is a list of peer to launch to start a ready-to-play environment
require "#{Rails.root}/lib/webdamlog_wrapper/wl_launcher"

class Scenario
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  SCENARIO = ['sigmod']

  attr_reader :name
  attr_reader :errors

  def initialize(name)
    @errors = ActiveModel::Errors.new(self)
    @errors.add() unless SCENARIO.include? name
    @name = name.downcase
  end

  def self.all
    SCENARIO.map { |s| new(s) }
  end

  def self.find(param)
    all.detect { |l| l.to_param == param } || raise(ActiveRecord::RecordNotFound)
  end

  def to_param
    @name.downcase
  end

  #  def self.model_name
  #    ActiveModel::Name.new(self)
  #  end

  # Scenario are never persisted in the DB
  def persisted?
    false
  end

  # This override the needed method id for ActiveRecord classes that I choose to
  # not use here since I don't need a DB table
  def id
    @name
  end

  # The 3 following methods are needed to be minimally implemented for error source from:
  # http://api.rubyonrails.org/classes/ActiveModel/Errors.html
  # It allows to do:
  # 
  # p = Person.new
  # p.validate!             # => ["can not be nil"]
  # p.errors.full_messages  # => ["name can not be nil"]
  #
  def read_attribute_for_validation(attr)
    send(attr)
  end
  # Implemented thanks to "extend ActiveModel::Translation"
#  def self.human_attribute_name(attr, options = {})
#    attr
#  end
#  def self.lookup_ancestors
#    [self]
#  end

  # Dispatcher to run the currently selected scenario
  def run
    case @name
    when 'sigmod'
      self.extend SigmodScenario
      return start
    end
  end
end


module SigmodScenario

  PEERNAME = 'sigmod_peer'
  #CONF_DIR = File.expand_path('config/scenario/sigmod')
  CONF_DIR = Conf.peer['peer']['program']['sigmod_peer']
  YML_CONF = YAML.load(File.open("#{CONF_DIR}/sigmod_peer.yml"))

  # Run the sigmod scenario, i.e. needs to run a sigmod peer which centralize
  # the contacts
  def start
    return WLLauncher.create_peer(PEERNAME,YML_CONF,"#{CONF_DIR}")
  end
end