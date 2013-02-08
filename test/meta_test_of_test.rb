require 'test_helper'
require 'test/unit'

class MetaTestOfTest < Test::Unit::TestCase
  def test_1_path

    p Dir.getwd
    p "#{__FILE__} on #{__LINE__}"

    # it shows that exectuion is launched by something above the current directory
    assert_equal(File.expand_path("."), File.expand_path('../..',__FILE__))
    assert_equal(Dir.pwd, File.expand_path('../..',__FILE__))    
    assert($:.include?(File.dirname(__FILE__)))
    # see the current working directory
    assert Dir.getwd
    # see the current working file and line
    assert "#{__FILE__} on #{__LINE__}".includes? "meta_test_of_test.rb"
  end

  #Test the default path loaded by rails
  def test_2_default_path
    
    assert_not_nil($:.select { |path| path.include? Dir.getwd })

    assert_not_nil($:.select { |path| path.include? File.join(Dir.getwd, "lib") })
  end
end

