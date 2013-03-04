class Scenario
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  SCENARIO = ['sigmod']

  attr_reader :name

  def initialize(name)
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
    #SCENARIO.index @name
    @name
  end

  # override to-key from ActiveModel::Conversion
#  def to_key
#    SCENARIO.index @name
#  end

end
