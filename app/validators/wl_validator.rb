require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
    #Check all elements from response and check if there is an error.
    value += ';' unless value.rstrip()[-1]==';' #parsing does not work well on strings not terminated by semi-colons
    response = EngineHelper::WLENGINE.parse(value)
    unless response.nil? or response.empty?
      unless response.first.is_a?(StandardError)
        response.each do |statement|
          require 'debugger';debugger
          if statement.class == WLBud::WLCollection
            @collections = EngineHelper::WLENGINE.snapshot_collections unless @collections 
            record.errors[attribute] << (options[:message] || "#{statement} : collection already exists!") if @collections.include?(statement)
          end
        end
      else
        record.errors[attribute] << (options[:message] || if response and response.first and response.first.message then response.first.message.to_s else 'Unkown Error' end)
      end
    else
      record.errors[attribute] << (options[:message] || "#{value} : parsing returned nothing or nil!")
    end
    WLLogger.logger.debug "Parsed : #{response.map {|e| e.class}}"
    return true
  end
end


#WLrule model
#WLValidator