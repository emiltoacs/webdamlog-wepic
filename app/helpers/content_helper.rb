require 'yaml'

module ContentHelper
  def self.query_create
    if defined?(Conf)
      WLLogger.logger.debug "Query Samples for user : #{Conf.env['USERNAME']}"
      sample_content_file_name = Conf.peer['peer']['program']['query_sample']
      if (File.exists?("#{Rails.root}/#{sample_content_file_name}"))
        content = YAML.load(File.open(sample_content_file_name))
        #WLLogger.logger.debug 'Reseting described rules...' if DescribedRule.delete_all
        content['described_rules'].values.each do |idrule|
          drule = DescribedRule.new(:wdlrule => idrule['wdlrule'],:description => idrule['description'], :role=> idrule['role'])
          if drule.save
            WLLogger.logger.debug "Rule : #{drule.description.inspect[0..19]}...[#{drule.wdlrule.inspect[0..40]}] successfully added!"
          else
            error = "Rule : #{drule.description.inspect[0..9]}...[#{drule.wdlrule.inspect[0..19]}] was not saved because :"
            drule.errors.messages.each do |msg_k,msg_v|
              error += "\n\t#{msg_k}:#{msg_v}"
            end
            WLLogger.logger.warn error
            raise error
          end
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