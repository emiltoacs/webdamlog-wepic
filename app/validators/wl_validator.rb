require 'webdamlog/wlbud'

class WlValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
    response = EngineHelper::WLHELPER.parse(value)
    #Check all elements from response and check if there is an error.
    unless true#response.is_a?(WLBud::WLVocabulary)
      record.errors[attribute] << (options[:message] || response.message)
    end
  end
end


#WLrule model
#WLValidator