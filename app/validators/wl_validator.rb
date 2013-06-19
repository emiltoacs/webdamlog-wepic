require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  include EngineHelper
  
  def validate_each(record, attribute, value)
    #Check all elements from responses and check if there is an error.
    # responses = WLENGINE.parse(value)
    # WLLogger.logger.debug "Parsed : #{responses.map {|e| e.class}}"
    # unless responses.nil? or responses.empty?
      # if responses.first.is_a?(StandardError)
        # record.errors[attribute] << (options[:message] || if responses and responses.first and responses.first.message then responses.first.message.to_s else 'Unkown Error' end)
      # else
        # @statements = DescribedRule.all.map {|dr| dr.wdlrule}
        # responses.each do |response|
          # @statements.each do |statement|
            # require 'debugger';debugger
            # already_in = WLENGINE.parse(statement)
            # already_in = if already_in and !already_in.empty? then already_in.first else nil end  
            # about_to_add = response
            # if already_in and already_in.show_wdl_format==response.show_wdl_format
              # record.errors[attribute] << (options[:message] || "#{value} : statement already exists!")
            # end
          # end
        # end
      # end
    # else
      # record.errors[attribute] << (options[:message] || "#{value} : parsing returned nothing or nil!")
    # end
  end
end


#WLrule model
#WLValidator