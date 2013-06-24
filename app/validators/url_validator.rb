require 'open-uri'

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || "must be a valid URL") unless url_valid?(record,value)
  end

  # a URL may be technically well-formed but may 
  # not actually be valid, so this checks for both.
  def url_valid?(tuple,url)
    if url.nil? and tuple.is_a?(Picture) and !tuple.image.nil? #image_url not specified for Picture tuple
      true
    else
      url = URI.parse(url) rescue false
      url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
      if url.host!='localhost' #url is from the outside
        Net::HTTP.get_response(url).is_a?(Net::HTTPOK)
      else #url must be intra webdamlog don't check
        true
      end
    end
  end 
end
