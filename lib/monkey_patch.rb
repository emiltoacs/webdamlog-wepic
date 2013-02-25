
class String
  def is_i?
    !!(self =~ /^[-+]?[0-9]+$/)
  end
end

class NilClass
  def is_i?
    false
  end
end
