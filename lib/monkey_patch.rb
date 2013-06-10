# monkey patch is_i? 

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

class Object
  def is_i?
    self.is_a? Integer
  end
end
