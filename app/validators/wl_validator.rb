class WlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless true #Find better validator
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end