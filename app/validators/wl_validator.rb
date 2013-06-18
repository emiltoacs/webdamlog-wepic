require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
#    #Check all elements from response and check if there is an error.
#    collections = EngineHelper::WLENGINE.snapshot_collections
#    unless collections.include?(value)
#      record.errors[attribute] << (options[:message] || "#{value} : collection already exists!")
#      return false
#    end
#    value += ';' unless value.rstrip()[-1]==';'
#    response = EngineHelper::WLENGINE.parse(value)
#    WLLogger.logger.debug "Parsed : #{response.map {|e| e.class}}"
#    unless !response.first.is_a?(StandardError) or response.nil?
#      record.errors[attribute] << (options[:message] || if response and response.first and response.first.message then response.first.message.to_s else 'Unkown Error' end)
#      return false
#    end
    return true
  end
end


#WLrule model
#WLValidator