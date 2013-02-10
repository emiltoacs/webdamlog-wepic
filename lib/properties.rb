require 'yaml'

module Properties

  def self.read_prop_file
    return YAML.load_file('config/properties.yml')    
  end
  
  def properties
    @properties = read_prop_file unless @properties
    @properties
  end
end