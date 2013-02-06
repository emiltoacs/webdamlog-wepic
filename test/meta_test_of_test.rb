require 'test_helper'
require 'test/unit'

class MetaTestOfTest < Test::Unit::TestCase
  def test_1
    #it shows that exectuion is launched by something above the current directory
    assert_equal(File.expand_path("."), File.expand_path('../..',__FILE__))
    assert_equal(Dir.pwd, File.expand_path('../..',__FILE__))    
    assert($:.include?(File.dirname(__FILE__)))
  end
end

