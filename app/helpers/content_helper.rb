require 'yaml'

module ContentHelper
  include EngineHelper
  mattr_accessor :describedRules
  
  self.describedRules = DescribedRule.all.map{|drule| drule.wdlrule}
  
  def self.query_create
    if defined?(Conf)
      WLLogger.logger.debug "Query Samples for user : #{Conf.env['USERNAME']}"
      sample_content_file_name = Conf.peer['peer']['program']['query_sample']
      sample_content_file_name = "#{Rails.root}/#{sample_content_file_name}"
      if (File.exists?(sample_content_file_name))
        content = YAML.load(File.open(sample_content_file_name))
        # WLLogger.logger.debug 'Reseting described rules...' if DescribedRule.delete_all       
        if content['described_rules']
          content['described_rules'].values.each do |idrule|
            saved, err = add_to_described_rules(idrule['wdlrule'],idrule['description'],idrule['role'])
            unless saved
              WLLogger.logger.error err
            end 
          end
        end
      else
        error = "File #{sample_content_file_name} does not exist!"
        WLLogger.logger.error error 
      end
    else
      error =  "The Conf object has not been setup!"
      WLLogger.logger.error error   
    end
  end
  
  def self.add_to_described_rules(rule,description,role,skip=nil)
      drule = DescribedRule.new(:wdlrule => rule,:description => description, :role=> role)
      if drule.save(skip)
        WLLogger.logger.debug "Rule : #{drule.description.inspect[0..19]}...[#{drule.wdlrule.inspect[0..40]}] successfully added!"
        self.describedRules << drule.wdlrule
        return true, drule.id
      else
        error = "Rule : #{drule.description.inspect[0..15]}...[#{drule.wdlrule.inspect[0..40]}] was not saved because : #{drule.errors.messages}"
        WLLogger.logger.warn error
        return false, error
     end    
  end
  
  #Not done
  def self.already_exists?(rule)
    responses = WLENGINE.parse(rule)
    WLLogger.logger.debug "Parsed : #{responses.map {|e| e.class}}"
    unless responses.nil? or responses.empty?
      if responses.first.is_a?(StandardError)
        return true
      else
        responses.each do |response|
          self.describedRules.each do |statement|
            already_in = WLENGINE.parse(statement)
            already_in = if already_in and !already_in.empty? then already_in.first else nil end  
            about_to_add = response
            if already_in and already_in.show_wdl_format==response.show_wdl_format then return false end
          end
        end
        return true
      end
    else
      return true
    end    
  end
end