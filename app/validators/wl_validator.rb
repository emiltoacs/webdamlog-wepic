require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
    #Check all elements from response and check if there is an error.
    response = EngineHelper::WLENGINE.parse(value)
    WLLogger.logger.debug "Parsed : #{response.map {|e| e.class}}"
    unless !response.first.is_a?(StandardError) or response.nil?
      record.errors[attribute] << (options[:message] || if response and response.first and response.first.message then response.first.message.to_s else 'Unkown Error' end)
    end
  end
end


#WLrule model
#WLValidator