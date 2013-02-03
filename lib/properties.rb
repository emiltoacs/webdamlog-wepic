require 'yaml'

module Properties
  
  #Access general properties  
  def self.properties
    @properties = YAML.load_file('config/properties.yml') unless @properties
    @properties
  end
  
  def properties
    @properties = YAML.load_file('config/properties.yml') unless @properties
    @properties
  end  
end