require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
    #Check all elements from response and check if there is an error.
    response = EngineHelper::WLENGINE.parse(value)
    unless response.nil? or response.empty?
      if response.first.is_a?(StandardError)
        record.errors[attribute] << (options[:message] || if response and response.first and response.first.message then response.first.message.to_s else 'Unkown Error' end)
      else
        response.each do |statement|
          if statement==WLBud::WLCollection
            @collections = DescribedRule.where("role = ? or role = ?", 'intentional','extensional').map {|dr| dr.wdlrule} unless @collections
            @collections.each do |collection|
              if ContentHelper::collections_same(collection,statement)
                record.errors[attribute] << (options[:message] || "#{value} : collection already exists!")
              end
            end            
          end
        end
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