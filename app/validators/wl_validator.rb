require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  include EngineHelper
  
  def validate_each(record, attribute, value)
    #Check all elements from responses and check if there is an error.
    responses = WLENGINE.parse(value)
    unless responses.nil? or responses.empty?
      if responses.first.is_a?(StandardError)
        record.errors[attribute] << (options[:message] || if responses and responses.first and responses.first.message then responses.first.message.to_s else 'Unkown Error' end)
      else
        @statements = DescribedRule.all.map {|dr| dr.wdlrule} unless @statements
        responses.each do |response|
          @statements.each do |statement|
            if WLENGINE.parse(statement).show_wdl_format==response.show_wdl_format
              record.errors[attribute] << (options[:message] || "#{value} : statement already exists!")
            end
          end
        end
      end
    else
      record.errors[attribute] << (options[:message] || "#{value} : parsing returned nothing or nil!")
    end
    WLLogger.logger.debug "WlValidator accept DescribedRule #{self} : #{responses.map {|e| e.is_a?(WLBud::NamedSentence) ? e.show_wdl_format : e.to_s }}"
    return true
  end
end


#WLrule model
#WLValidator