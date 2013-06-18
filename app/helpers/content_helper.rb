require 'yaml'

module ContentHelper
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
  
  def self.add_to_described_rules (rule,description,role,skip=nil)
      drule = DescribedRule.new(:wdlrule => rule,:description => description, :role=> role)
      if drule.save(skip)
        WLLogger.logger.debug "Rule : #{drule.description.inspect[0..19]}...[#{drule.wdlrule.inspect[0..40]}] successfully added!"
        return true, {}
      else
        error = "Rule : #{drule.description.inspect[0..15]}...[#{drule.wdlrule.inspect[0..40]}] was not saved because :"
        drule.errors.messages.each do |msg_k,msg_v|
          error += "\n\t#{msg_k}:#{msg_v}"
        end
        WLLogger.logger.warn error
        return false, drule.errors.messages
     end    
  end
  
  def self.collections_same(cola, colb)
    
  end
end