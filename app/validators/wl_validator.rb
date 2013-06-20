require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  include EngineHelper
  
  def validate_each(record, attribute, value)
    responses = WLENGINE.parse(value)
    WLLogger.logger.debug "Parsed : #{responses.map {|e| e.class}}"
    unless responses.nil? or responses.empty?
      if responses.first.is_a?(StandardError)
        record.errors[attribute] << (options[:message] || if responses and responses.first and responses.first.message then responses.first.message.to_s else 'Unkown Error' end)
      end
    else
      record.errors[attribute] << (options[:message] || "#{value} : parsing returned nothing : you probably forgot to put a ';' at the end of your statement... :(")
    end
  end
end


#WLrule model
#WLValidator