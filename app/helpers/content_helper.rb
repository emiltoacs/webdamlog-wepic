require 'yaml'

module ContentHelper
  def self.query_create
    if defined?(Conf)
      WLLogger.logger.debug "Query Samples for user : #{Conf.env['USERNAME']}"
      sample_content_file_name = "#{Rails.root}/config/scenario/samples/query/sample.yml"
      if (File.exists?(sample_content_file_name))
        content = YAML.load(File.open(sample_content_file_name))
        WLLogger.logger.debug 'Reseting described rules...' if DescribedRule.delete_all
        content['described_rules'].values.each do |drule|
          drule = DescribedRule.new(:rule => drule['rule'],:description => drule['description'], :role=> drule['role'])
          if drule.save
            WLLogger.logger.debug "Rule : #{drule.description.inspect[0..9]}...[#{drule.rule.inspect[0..19]}] successfully added!"
          else
            error = "Rule : #{drule.description.inspect[0..9]}...[#{drule.rule.inspect[0..19]}] was not saved because :"
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